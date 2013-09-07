require 'sinatra'
require 'bundler'
require 'haml'
require 'rottentomatoes'
require 'twitter'
require 'data_mapper'
require './movie_and_cast.rb'

Bundler.require
include RottenTomatoes

# setup your API key
Rotten.api_key = "5hb5muvr3bhth3gbzsr6xeqn"
Twitter.configure do |config|
  config.consumer_key = "e756IwG9nog9CtllDZ9tkQ"
  config.consumer_secret = "yG3NNjC9rbipWGPavvhDiipYI5qpMRX7JL6JigZDB8"
  config.oauth_token = "18181559-uVQ2Kf1pvrsoAhBR3aNRkbsPEHbUmtVOi5t9U06M8"
  config.oauth_token_secret = "ICF43ycm2nIqKHWyhEpbWIMFEjkh9uJIikyoavH5eI"
end



get '/' do
  week_no = Time.now.strftime('%U').to_i
  movie_count = Movie.count(:week_no=> week_no,:type=>"in_theaters")

begin
  
  if(movie_count == 0)
    @movies = RottenList.find(:type => "in_theaters", :country => "in", :limit => 50, :expand_results => true)
    
    @movies.each do |mov|
     movie = Movie.new
     movie.movie_name = mov.title
     movie.week_no = week_no
     movie.img_url = mov.posters.profile
     movie.movie_url = mov.links.alternate
     movie.movie_id = mov.id
     movie.type ="in_theaters"
    
     cs = mov.abridged_cast
     if(cs != nil)
      cs.each do |ca|
       cast = Cast.new
       cast.name = ca.name
       movie.casts << cast
      end
     end

     if movie.save
      puts "inserted into database"
     else
      puts "failed"
     end

    end #end of each loop
   
   previous_week_movies = Movie.all(:week_no => week_no-1)
   #delete records for previous week
   if(previous_week_movies != nil)
     previous_week_movies.each do |prev_mov|
       prev_mov.destroy
     end
   end
      
  end #end of if

rescue Exception => ex
  haml:error
end
  
  @movies = Movie.all(:week_no=> week_no,:type=>"in_theaters")
  haml :index  

end #end of method



#method to load photos depending upon the type{in theaters, upcoming,opening}
get '/loadPhotos' do
  type = params[:type].downcase
  puts type
  week_no = Time.now.strftime('%U').to_i
  movie_count = Movie.count(:week_no=> week_no,:type=>type)

begin
  
  if(movie_count == 0)
    @movies_list = RottenList.find(:type => type, :country => "in", :limit => 50, :expand_results => true)
   
    @movies_list.each do |mov|
      movie = Movie.new
      movie.movie_name = mov.title
      movie.week_no = week_no
      movie.img_url = mov.posters.profile
      movie.movie_url = mov.links.alternate
      movie.movie_id = mov.id
      movie.type = type
    
      cs = mov.abridged_cast
      if(cs != nil)
        cs.each do |ca|
          cast = Cast.new
          cast.name = ca.name
          movie.casts << cast
        end
      end
  
      if !movie.save
        raise "Error saving to database"
      end
    end #end the iteration
  
  end # end if

rescue Exception => ex
  haml:error
end

  @movies_list = Movie.all(:type => type,:week_no => week_no)
  haml :data , :layout => false

end


# method to fetch the movie from database and 
# then fetch relevant tweets using twitter api 

get '/load_tweets/:movieId' do
  id = params[:movieId]
  @movie_by_id = Movie.first(:movie_id => id)
  @movie_cast = ""
  #@movie_directors =""

begin
 
  if @movie_by_id != nil
    @movie_by_id.casts.each do |cast|
      @movie_cast = @movie_cast + cast.name + ","
    end
      @movie_cast = @movie_cast.chop
  end
 
  search_term = @movie_by_id.movie_name  
  if(search_term.index(" ") == nil )
    search_term = "#" + search_term
  end

  puts "fetching tweets"

  search_term = search_term + " " + "movie"  
  @tweets = Twitter.search(search_term, :result_type => "recent", :count => "500") 

  puts "tweets fetched"  
  if @tweets == nil || @tweets.count==0
   puts "tweets nil" 
   raise "no tweets found"
  end
  
rescue Exception => ex
  haml:error
end

  haml :tweets

end

