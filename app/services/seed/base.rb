module Seed
  class Base
    def initialize(settings)
      @settings = settings
    end

    def prefetch_currencies
    end

    def check_base_currency
      raise StandardError "Unsupported base currency"
    end
  end
end
