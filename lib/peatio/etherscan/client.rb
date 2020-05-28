# frozen_string_literal: true

module Etherscan
  class Client
    API_SUCCESS_STATUS = "1"

    NETWORKS_URLS = {
        mainnet: "https://api.etherscan.io/",
        rinkeby: "https://api-rinkeby.etherscan.io/",
        ropsten: "https://api-ropsten.etherscan.io/",
        kovan:   "https://api-kovan.etherscan.io/",
        goerli:  "https://api-goerli.etherscan.io/",
        ewc:     "https://api-ewc.etherscan.io/"
    }.freeze

    DEFAULT_NETWORK = :mainnet

    attr_accessor :headers, :endpoint

    def initialize(options={})
      @endpoint = options[:endpoint]
      @endpoint ||= options.fetch(:network, DEFAULT_NETWORK)
                        .to_sym
                        .yield_self { |n| NETWORKS_URLS[n] }

      @api_key = options.fetch(:api_key, ETHERSCAN_API_KEY)
      @idle_timeout = options.fetch(:idle_timeout, 5)
      @headers = {"Accept"       => "application/json",
                  "Content-Type" => "application/json"}
    end

    def get(params={})
      api_suffix = "api"
      merged_params = params.merge(apikey: @api_key)
      response = connection.get(api_suffix) do |req|
        req.headers = headers
        req.params  = merged_params.as_json
      end

      JSON(response.body).deep_symbolize_keys.yield_self do |body|
        raise Etherscan::APIError, body if body[:status] != API_SUCCESS_STATUS || body[:result].blank?

        body[:result]
      end
    end

    private

    def connection
      @connection ||= Faraday.new(@endpoint) do |f|
        f.response :raise_error
        f.adapter :net_http_persistent, pool_size: 5, idle_timeout: @idle_timeout
      end
    end
  end
end
