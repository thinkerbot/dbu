#!/usr/bin/env ruby
require File.expand_path('../adapter_suite.rb', __FILE__)

class Dbu::Adapters::MysqlTest < Test::Unit::TestCase
  include AdapterSuite

  def environment
    'mysql_test'
  end

  def expected_prepare_sql
%{
prepare query from '
select * from kv where v = ?
union
select * from kv where v > ?;
';
set @v1 = '2';
set @v2 = '2';
execute query using @v1, @v2;
}.lstrip
  end
end
