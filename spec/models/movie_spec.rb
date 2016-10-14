require 'rails_helper'
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
      it 'should return empty array if the search term is not found in Tmdb' do
        expect(Tmdb::Movie).to receive(:find).with('asdfasdf').and_return(nil)
        result = Movie.find_in_tmdb('asdfasdf')
        expect(result).to eq([])
        
        
      end
      it 'should parse the information corectly' do  #NEED HELP HERE
        movieArray = [Tmdb::Movie.new({id:1, title: "Inception", release_date: "2010-07-16"})]
        
        expect(Tmdb::Movie).to receive(:find).with('Inception').and_return(movieArray)
        allow(Tmdb::Movie).to receive(:detail).with(1).and_return({ 'overview' => "Some Words"})
        allow(Movie).to receive(:get_rating).with(1).and_return('PG-13')
        result = Movie.find_in_tmdb('Inception')
        
        expect(result.count).to eq(1)
        expect(result[0][:tmdb_id]).to eq(1)
        expect(result[0][:rating]).to eq("PG-13")
        expect(result[0][:title]).to eq("Inception")
        expect(result[0][:description]).to eq("Some Words")
        expect(result[0][:release_date]).to eq("2010-07-16")
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'adding movie from Tmdb' do
    context 'with valid key' do
       before :each do
        expect(Tmdb::Movie).to receive(:detail).with(1).and_return(
          { 'overview' => "Some Words", "release_date" => "2010-07-16", "title" => "Inception" }  
        )
      end
      it 'should parse information corectly' do
        expect(Movie).to receive(:get_rating).with(1).and_return('PG-13')
        result = Movie.create_from_tmdb(1)
        
        expect(result[:rating]).to eq("PG-13")
        expect(result[:title]).to eq("Inception")
        expect(result[:description]).to eq("Some Words")
        expect(result[:release_date]).to eq("2010-07-16")
        
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:detail).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.create_from_tmdb(1) }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'get rating' do
    it 'should return a rating' do
      expect(Tmdb::Movie).to receive(:releases).with(1).and_return({'iso_3166_1' => 'US'})
      Movie.get_rating(1)
    end
    
  end
  
end
