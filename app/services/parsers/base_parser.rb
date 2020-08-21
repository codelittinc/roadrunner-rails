module Parsers
  class BaseParser
    def initialize(json)
      @json = json
    end

    def can_parse?
      false
    end

    def parse!; end

    def method_missing(m, *args, &block); end
  end
end
