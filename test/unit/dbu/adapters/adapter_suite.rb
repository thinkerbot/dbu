require File.expand_path('../../../helper.rb', __FILE__)
require 'dbu/config'
require 'stringio'

module AdapterSuite
  include AdapterHelper

  def setup
    super
    adapter.run('reset')
  end

  def environment
    raise NotImplementedError
  end

  #
  # exec
  #

  def test_exec_runs_sql_and_returns_enum
    res = adapter.exec('select * from kv;').to_a
    assert_equal [['a', '1'], ['b', '2'], ['c', '3']], res
  end

  def test_exec_makes_available_last_headers
    adapter.exec('select * from kv;')
    assert_equal ['k', 'v'], adapter.last_headers
  end

  #
  # prepare/exec_prepared
  #

  def test_prepare_exec_prepared_execs_prepared_statement
    signature = adapter.prepare("query",
      "select * from kv where v = %{v}\n" \
      "union\n" \
      "select * from kv where v > %{v};\n" \
    , [:v])

    argh = {:v => 2}
    args = signature.map {|key| argh[key] }

    res  = adapter.exec_prepared("query", args).to_a
    assert_equal [['b', '2'], ['c', '3']], res
  end
end
