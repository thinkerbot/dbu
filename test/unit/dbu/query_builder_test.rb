#!/usr/bin/env ruby
require File.expand_path('../../helper.rb', __FILE__)
require 'dbu/query_builder'

class Dbu::QueryBuilderTest < Test::Unit::TestCase
  QueryBuilder = Dbu::QueryBuilder

  def test_query_builder_builds_query_with_name
    builder = QueryBuilder.new 'example'
    assert_equal('example', builder.to_query.name)
  end

  def test_query_builder_sets_desc_on_query
    builder = QueryBuilder.new
    builder.desc('example')
    assert_equal('example', builder.to_query.desc)
  end

  def test_query_builder_sets_help_on_query
    builder = QueryBuilder.new
    builder.help('example')
    assert_equal('example', builder.to_query.help)
  end

  def test_query_builder_sets_args_on_query
    builder = QueryBuilder.new
    builder.args(:a => nil, :b => nil)
    assert_equal({:a => nil, :b => nil}, builder.to_query.args)
  end

  def test_query_builder_sets_before_sql_on_query
    builder = QueryBuilder.new
    builder.before('example')
    assert_equal('example', builder.to_query.before_sql)
  end

  def test_query_builder_sets_sql_on_query
    builder = QueryBuilder.new
    builder.query('example')
    assert_equal('example', builder.to_query.sql)
  end

  def test_query_builder_sets_after_sql_on_query
    builder = QueryBuilder.new
    builder.after('example')
    assert_equal('example', builder.to_query.after_sql)
  end

  def test_query_builder_uses_nil_default_for_array_args
    builder = QueryBuilder.new
    builder.args(:a, :b)
    assert_equal({:a => nil, :b => nil}, builder.to_query.args)
  end

  def test_query_builder_sets_vars_on_query
    builder = QueryBuilder.new
    builder.vars(:a => nil, :b => nil)
    assert_equal({:a => nil, :b => nil}, builder.to_query.vars)
  end

  def test_query_builder_uses_nil_default_for_array_vars
    builder = QueryBuilder.new
    builder.vars(:a, :b)
    assert_equal({:a => nil, :b => nil}, builder.to_query.vars)
  end
end
