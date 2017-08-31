require 'httparty'
require './constants'


class EtherScan
  include HTTParty
  base_uri 'https://api.etherscan.io'
  class << self
    def eth_balance_at(addr, time)
      addr = addr.downcase
      balance = eth_balance_at_with_type(addr, time, "txlist") + eth_balance_at_with_type(addr, time, "txlistinternal") 
      balance / Constants::WEI_PER_ETH
    end

    def eth_balance_at_with_type(addr, time, tx_type)
      time = time.to_i
      page = 1
      continued = true
      balance = 0
      while continued do
        response = self.get("/api/?module=account&action=#{tx_type}&address=#{addr}&offset=10000&page=#{page}", verify: false).parsed_response
        if response["status"] == "0"
          continued = false
          next
        end
        balance += response["result"].reduce(0) do |memo, tx|
          next memo if tx["timeStamp"].to_i > time
          value = tx["value"].to_i
          if tx["from"] == addr
            memo -= value if tx["isError"] == "0" 
            memo -= tx["gasPrice"].to_i * tx["gasUsed"].to_i
          end
          memo += value if tx["to"] == addr
          memo
        end
        page += 1
      end
      balance
    end
  end
end