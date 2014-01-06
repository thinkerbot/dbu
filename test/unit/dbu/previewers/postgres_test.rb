#!/usr/bin/env ruby
require File.expand_path('../previewer_suite.rb', __FILE__)

class Dbu::Previewers::PostgresTest < Test::Unit::TestCase
  include PreviewerSuite

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
