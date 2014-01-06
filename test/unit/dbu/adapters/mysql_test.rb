#!/usr/bin/env ruby
require File.expand_path('../adapter_suite.rb', __FILE__)

class Dbu::Adapters::MysqlTest < Test::Unit::TestCase
  include AdapterSuite

  def environment
    'mysql_test'
  end
end
