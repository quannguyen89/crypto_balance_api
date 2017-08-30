require 'sinatra'
require "sinatra/json"
require './block_cypher'
require './blockchain_info'
require 'fast_blank'

get '/' do
  'Hello world!'
end

get '/btc/:addr' do
  # Time.parse(params[:at])
  time = params[:at].nil? ? Time.parse("2000-01-01") : Time.parse(params[:at])
  balance = BlockchainInfo.btc_balance_at(params[:addr], time)
  json balance: balance
end

get '/eth/:addr' do
  balance = BlockCypher.eth_balance_at(params[:addr])
  json balance: balance
end