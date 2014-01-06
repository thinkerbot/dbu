#!/usr/bin/env ruby
require File.expand_path('../adapter_suite.rb', __FILE__)

class Dbu::Adapters::PostgresTest < Test::Unit::TestCase
  include AdapterSuite

  def environment
    'postgres_test'
  end
end
