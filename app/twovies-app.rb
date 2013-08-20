require 'sinatra'
require 'bundler'
require 'haml'
require 'rottentomatoes'

Bundler.require
include RottenTomatoes

# setup your API key
Rotten.api_key = "5hb5muvr3bhth3gbzsr6xeqn"

get '/' do
  @movies = RottenList.find(:type => "in_theaters", :country => "in", :limit => 50, :expand_results => true)
  haml :index  
end

get '/loadPhotos' do
  type = params[:type].downcase
  puts type
  @movies_list = RottenList.find(:type => type, :country => "in", :limit => 50, :expand_results => true)
  puts "fetched movies :" + @movies_list.count.to_s
  haml :data , :layout => false
end

