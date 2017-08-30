require 'httparty'
require './constants'
require 'fast_blank'
require 'byebug'

class BlockchainInfo
  include HTTParty
  base_uri 'https://blockchain.info/'
  class << self
    def btc_balance_at(addr, time)
      time = time.to_i
      response = self.get("/rawaddr/#{addr}?limit=50").parsed_response
      n_tx = response["n_tx"]
      page = n_tx / 50 
      page += 1 if n_tx % 50 != 0
      balance = 0
      page.times do |page|
        next unless txs = response["txs"]
        balance += txs.reduce(0) do |memo, tx|
          next if time > tx["time"]
          if tx["inputs"]
            tx["inputs"].each do |input|
              next unless prev_out = input["prev_out"]
              memo -= prev_out["value"] if prev_out["addr"] == addr
            end
          end

          if tx["out"]
            tx["out"].each do |o|
              memo += o["value"] if o["addr"] == addr
            end
          end
          response = self.get("/rawaddr/#{addr}?limit=50&offset=#{50 * (page+1)}").parsed_response
          memo
        end
      end
      balance / Constants::SATOSHI_PER_BTC
    end
  end
end