#!/usr/bin/env ruby
require File.expand_path('../../helper.rb', __FILE__)
require 'dbu/query'

class Dbu::QueryTest < Test::Unit::TestCase
  Query = Dbu::Query

  class PreviewAdapter
    attr_reader :log

    def initialize(config = {}, logger = nil)
      @log = config.fetch(:log, [])
    end

    def prepare(*args)
      @log << [:prepare, *args]
      args.last
    end

    [:exec_prepared, :deallocate, :exec].each do |method_name|
      class_eval %{
        def #{method_name}(*args)
          @log << [:#{method_name}, *args]
        end
      }
    end

    def escape(str)
      str.to_s
    end

    def escape_literal(str)
      str.to_s
    end
  end

  def adapter
    @adapter ||= PreviewAdapter.new
  end

  #
  # Query.create
  #

  def test_create_builds_hash_args_from_array_args
    query = Query.create :args => [:a, :b]
    assert_equal({:a => nil, :b => nil}, query.args)
  end

  def test_create_builds_hash_vars_from_array_vars
    query = Query.create :vars => [:x, :y]
    assert_equal({:x => nil, :y => nil}, query.vars)
  end

  #
  # sql
  #

  def test_query_sql_method_formats_sql_with_args
    query = Query.new(
      :sql => "A %{b} C",
      :args => {:b => nil}
    )
    query.bind adapter
    assert_equal "A B C", query.sql(:b => 'B')
  end

  def test_query_sql_method_formats_sql_with_args_as_needed
    query = Query.new(
      :sql  => "A %{b} C %{d}",
      :args => {:b => 'X', :d => 'D'}
    )
    query.bind adapter
    assert_equal "A B C D", query.sql(:b => 'B')
  end

  #
  # bind, exec, unbind
  #

  def test_exec_calls_adapter_exec_with_query_sql
    query = Query.new(
      :sql => "A %{b} C",
      :args => {:b => nil}
    )
    query.bind adapter
    query.exec :b => 'B'
    assert_equal [[:exec, "A B C"]], adapter.log
  end

  def test_exec_with_array_input
    query = Query.new(
      :sql => "A %{b} C",
      :args => {:b => nil}
    )
    query.bind adapter
    query.exec ['B']
    assert_equal [[:exec, "A B C"]], adapter.log
  end

  def test_bind_calls_before_sql_and_unbind_calls_after_sql
    query = Query.new(
      :before_sql => "A",
      :sql        => "B",
      :after_sql  => "C"
    )

    query.bind adapter
    query.exec
    query.exec
    query.unbind

    assert_equal [
      [:exec, "A"],
      [:exec, "B"],
      [:exec, "B"],
      [:exec, "C"]
    ], adapter.log
  end

  def test_bind_with_vars_formats_sql_statements_before_use
    query = Query.new(
      :before_sql => "A%{one}",
      :sql        => "B%{one}%{two}",
      :after_sql  => "C%{one}",
      :vars       => {:one => nil},
      :args       => {:two => nil}
    )

    query.bind adapter, :one => 1
    query.exec :two => 2
    query.exec :two => 3
    query.unbind

    assert_equal [
      [:exec, "A1" ],
      [:exec, "B12"],
      [:exec, "B13"],
      [:exec, "C1"]
    ], adapter.log
  end

  def test_bind_allows_rebind_with_different_vars
    query = Query.new(
      :before_sql => "A%{one}",
      :sql        => "B%{one}%{two}",
      :after_sql  => "C%{one}",
      :vars       => {:one => nil},
      :args       => {:two => nil}
    )

    query.bind adapter, :one => 1
    query.exec :two => 2
    query.exec :two => 3
    query.unbind

    query.bind adapter, :one => 4
    query.exec :two => 5
    query.exec :two => 6
    query.unbind

    assert_equal [
      [:exec, "A1" ],
      [:exec, "B12"],
      [:exec, "B13"],
      [:exec, "C1" ],
      [:exec, "A4" ],
      [:exec, "B45"],
      [:exec, "B46"],
      [:exec, "C4"]
    ], adapter.log
  end

  #
  # prepare, exec_prepared
  #

  def test_prepare_and_exec_prepared_workflow
    query = Query.new(
      :before_sql => "A%{one}",
      :sql        => "B%{one}%{two}",
      :after_sql  => "C%{one}",
      :vars       => {:one => nil},
      :args       => {:two => nil}
    )

    query.bind adapter, :one => 1
    query.prepare
    query.exec_prepared :two => 2
    query.exec_prepared :two => 3
    query.deallocate
    query.unbind

    assert_equal [
      [:exec, "A1" ],
      [:prepare, "anon_query", "B1%{two}", [:two]],
      [:exec_prepared, "anon_query", [2]],
      [:exec_prepared, "anon_query", [3]],
      [:deallocate, "anon_query"],
      [:exec, "C1" ],
    ], adapter.log
  end

  def test_prepare_and_exec_prepared_with_array_inputs
    query = Query.new(
      :before_sql => "A%{one}",
      :sql        => "B%{one}%{two}",
      :after_sql  => "C%{one}",
      :vars       => {:one => nil},
      :args       => {:two => nil}
    )

    query.bind adapter, :one => 1
    query.prepare
    query.exec_prepared [2]
    query.exec_prepared [3]
    query.deallocate
    query.unbind

    assert_equal [
      [:exec, "A1" ],
      [:prepare, "anon_query", "B1%{two}", [:two]],
      [:exec_prepared, "anon_query", [2]],
      [:exec_prepared, "anon_query", [3]],
      [:deallocate, "anon_query"],
      [:exec, "C1" ],
    ], adapter.log
  end
end
