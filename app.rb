require 'sinatra'
require "sinatra/json"
require './block_cypher'
require './ether_scan'
require './blockchain_info'
require 'fast_blank'

get '/' do
  'Hello world!'
end

get '/btc/:addr' do
  begin
    balance = BlockchainInfo.btc_balance_at(params[:addr], time)
    json balance: balance, status: 1
  rescue 
    json status: 0
  end
end

get '/eth/:addr' do
  begin
    balance = EtherScan.eth_balance_at(params[:addr], time)
    json balance: balance, status: 1
  rescue
    json status: 0
  end
end

def time
  params[:at].nil? ? Time.now : (Time.parse(params[:at]))
end