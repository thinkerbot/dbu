require 'stringio'

module Dbu
  module Previewer
    attr_writer :io

    def io
      @io ||= StringIO.new
    end
  end
end
