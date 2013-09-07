require 'data_mapper'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class Movie
  include DataMapper::Resource  
  property :id,           Serial
  property :movie_id,     Integer
  property :week_no,      Integer
  property :type,         String
  property :img_url,      URI
  property :movie_url,    URI
  property :movie_name,   String
  has n, :casts
  has n, :directors        
end

class Cast
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String
  belongs_to :movie
end 

class Director
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String
  belongs_to :movie
end

DataMapper.finalize.auto_upgrade!
