require 'httparty'

class BlockCypher
  include HTTParty
  API_URL = "http://api.blockcypher.com/v1"     
  TOKEN = '2c90188223118b6f0cc7c41ab1c84da7'
  SATOSHI_PER_BTC = 10**8 * 1.0
  WEI_PER_ETH = 10**18 * 1.0
  UNSPECIFIED_TIME = DateTime.parse("0001-01-01T00:00:00Z")
  base_uri "#{API_URL}/btc/main"


  class << self
    def btc_balance_at(address, time = DateTime.now)
      response = self.get("/addrs/#{address}?token=#{TOKEN}").parsed_response
      get_balance_from(response, time, address) / SATOSHI_PER_BTC
    end

    def eth_balance_at(address, time = DateTime.now) 
      balance = 0
      for_uri("#{API_URL}/eth/main") do
        response = self.get("/addrs/#{address}?token=#{TOKEN}").parsed_response
        balance = get_balance_from(response, time, address) / WEI_PER_ETH
      end
      balance
    end

    def get_balance_from(response, time, address)
      return 0 unless txrefs = response['txrefs']
      invalid_txref = -> (txref) {  DateTime.parse(txref['confirmed']) == UNSPECIFIED_TIME }
      txrefs = txrefs.reject(&invalid_txref)
      continued = true
      while continued do
        last_txref = txrefs.last
        puts last_txref
        if (last_txref && DateTime.parse(last_txref["confirmed"]) > time && response['hasMore'])
          response = self.get("/addrs/#{address}?before=#{last_txref['block_height']}").parsed_response
          txtrefs = response['txrefs'].present? ? response['txrefs'].reject(&invalid_txref) : []
        else
          continued = false
        end
      end
      return 0 unless latest_txref_to_time = txrefs.find { |txref| DateTime.parse(txref["confirmed"]) <= time }
      latest_txref_to_time['ref_balance']
    end

    def for_uri(uri)
      current_uri = self.base_uri
      self.base_uri uri
      yield
      self.base_uri current_uri
    end
  end
end