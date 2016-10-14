class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movie_results= Tmdb::Movie.find(string)
     
      if movie_results == nil
        movie_results = []
        return movie_results
      else
        res = []
        movie_results.each do |movie| 
           description = Tmdb::Movie.detail(movie.id)['overview']
           rating = Movie.get_rating(movie.id)
           res.push({tmdb_id: movie.id, title: movie.title, rating: rating, release_date:  movie.release_date, description: description})
        end
        return res
        
      end
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.get_rating(id)
    countries = Tmdb::Movie.releases(id)['countries']
      if(countries != nil)
          ratingHash = countries.find_all {|m| m['iso_3166_1'] == 'US'  }
          if(ratingHash != nil)
            ratingHash.each do |rating|
              if(self.all_ratings.include?(rating['certification']))
                return rating['certification']
              end
            end
            return "NR"
          else
            return ''
          end
      end
  end
  
  def self.create_from_tmdb(id)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      details = Tmdb::Movie.detail(Integer(id))
      rating = Movie.get_rating(id)
      Movie.create!({title: details['title'], description: details['overview'], rating: rating, release_date: details['release_date']})
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
      
      
  
end
