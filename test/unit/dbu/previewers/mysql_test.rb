#!/usr/bin/env ruby
require File.expand_path('../previewer_suite.rb', __FILE__)

class Dbu::Previewers::MysqlTest < Test::Unit::TestCase
  include PreviewerSuite

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
