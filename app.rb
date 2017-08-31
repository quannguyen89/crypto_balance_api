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
  balance = BlockchainInfo.btc_balance_at(params[:addr], time)
  json balance: balance, status: 1
end

get '/eth/:addr' do
  balance = EtherScan.eth_balance_at(params[:addr], time)
  json balance: balance, status: 1
end

def time
  params[:at].nil? ? Time.now : Time.parse(params[:at])
end