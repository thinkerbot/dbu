#!/usr/bin/env ruby
require File.expand_path('../adapter_suite.rb', __FILE__)

class Dbu::Adapters::PostgresTest < Test::Unit::TestCase
  include AdapterSuite

  def environment
    'postgres_test'
  end

  def expected_prepare_sql
%{
prepare query as
select * from kv where v = $1
union
select * from kv where v > $1;
execute query('2');
}.lstrip
  end
end
