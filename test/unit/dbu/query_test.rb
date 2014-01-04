require File.expand_path('../../helper.rb', __FILE__)
require 'dbu/query'
require 'dbu/adapters/preview'

class Dbu::QueryTest < Test::Unit::TestCase
  Query = Dbu::Query
  PreviewAdapter = Dbu::Adapters::Preview

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
    assert_equal ["A B C"], adapter.target
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
    assert_equal adapter, query.unbind

    assert_equal ["A", "B", "B", "C"], adapter.target
  end

  def test_bind_with_vars_formats_sql_statements_before_use
    query = Query.new(
      :before_sql => "A%{one}",
      :sql        => "B%{one}%{two}",
      :after_sql  => "C%{one}",
      :vars  => {:one => nil},
      :args       => {:two => nil}
    )

    query.bind adapter, :one => 1
    query.exec :two => 2
    query.exec :two => 3
    assert_equal adapter, query.unbind

    assert_equal ["A1", "B12", "B13", "C1"], adapter.target
  end

  def test_bind_allows_rebind_with_different_vars
    query = Query.new(
      :before_sql => "A%{one}",
      :sql        => "B%{one}%{two}",
      :after_sql  => "C%{one}",
      :vars  => {:one => nil},
      :args       => {:two => nil}
    )

    query.bind adapter, :one => 1
    query.exec :two => 2
    query.exec :two => 3
    assert_equal adapter, query.unbind

    query.bind adapter, :one => 4
    query.exec :two => 5
    query.exec :two => 6
    assert_equal adapter, query.unbind

    assert_equal [
      "A1", "B12", "B13", "C1",
      "A4", "B45", "B46", "C4"
    ], adapter.target
  end
end
