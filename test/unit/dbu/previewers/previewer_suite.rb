require File.expand_path('../../../helper.rb', __FILE__)
require 'dbu/config'

module PreviewerSuite
  include AdapterHelper

  def setup
    super
    adapter.run('reset')
    adapter.extend config.previewer
  end

  def environment
    raise NotImplementedError
  end

  #
  # exec
  #

  def test_exec_in_preview_mode_prints_query_to_target_and_does_not_execute
    res = adapter.exec('select * from kv;')

    assert_equal [], res.to_a
    assert_equal [], adapter.last_headers
    assert_equal "select * from kv;\n", adapter.io.string
  end

  #
  # prepare/exec_prepared
  #

  def expected_prepare_sql
    raise NotImplementedError
  end

  def test_prepare_exec_prepared_in_preview_mode_prints_queries_to_target_and_does_not_execute
    signature = adapter.prepare("query",
      "select * from kv where v = %{v}\n" \
      "union\n" \
      "select * from kv where v > %{v};\n" \
    , [:v])

    argh = {:v => 2}
    args = signature.map {|key| argh[key] }

    res  = adapter.exec_prepared("query", args)

    assert_equal [], res.to_a
    assert_equal [], adapter.last_headers
    assert_equal expected_prepare_sql, adapter.io.string
  end
end
