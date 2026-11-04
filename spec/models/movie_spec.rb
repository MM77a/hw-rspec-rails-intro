require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe '.find_in_tmdb' do
    before(:each) do
      @search = { title: 'This Life + 10', release_year: '2007', language: 'en' }
      @results = [
        { title: 'This Life + 10', release_date: '2007-01-02', overview: 'A reunion.', original_language: 'en' },
        { title: 'Another film', release_date: '', overview: '', original_language: 'fr' }
      ]
      @response = { status: 200, body: { results: @results }.to_json }
      @request = stub_request(:get, 'https://api.themoviedb.org/3/search/movie').with(
        query: { api_key: 'test-key', query: 'This Life + 10', year: '2007', language: 'en' }
      ).to_return { @response }
    end

    it 'calls Faraday with the encoded title, optional year, language, and API key' do
      expect(Faraday).to receive(:get).and_call_original
      Movie.find_in_tmdb(@search, 'test-key')
      expect(@request).to have_been_requested.once
    end

    it 'returns unsaved Movie objects with an R rating' do
      expect {
        movies = Movie.find_in_tmdb(@search, 'test-key')
        expect(movies.map(&:title)).to eq(['This Life + 10'])
        expect(movies.first).to have_attributes(rating: 'R', description: 'A reunion.', release_date: Time.zone.parse('2007-01-02'))
        expect(movies).to all(be_new_record)
      }.not_to change(Movie, :count)
    end

    it 'keeps all original languages and handles a missing release date' do
      request = stub_request(:get, 'https://api.themoviedb.org/3/search/movie').with(
        query: { api_key: 'test-key', query: 'This Life + 10' }
      ).to_return(body: { results: @results }.to_json)
      movies = Movie.find_in_tmdb({ title: 'This Life + 10', release_year: '', language: 'all' }, 'test-key')
      expect(movies.size).to eq(2)
      expect(movies.last.release_date).to be_nil
      expect(request).to have_been_requested.once
    end

    it 'returns an empty list when there are no matches' do
      @response[:body] = { results: [] }.to_json
      expect(Movie.find_in_tmdb(@search, 'test-key')).to eq([])
    end

    it 'reports an invalid API key' do
      @response[:status] = 401
      expect { Movie.find_in_tmdb(@search, 'test-key') }.to raise_error(Movie::TMDbError, /API key/)
    end

    it 'reports a service failure' do
      @response[:status] = 503
      expect { Movie.find_in_tmdb(@search, 'test-key') }.to raise_error(Movie::TMDbError)
    end

    it 'reports a timeout' do
      stub_request(:get, /api\.themoviedb\.org/).to_timeout
      expect { Movie.find_in_tmdb(@search, 'test-key') }.to raise_error(Movie::TMDbError)
    end

    it 'reports malformed JSON' do
      @response[:body] = 'not JSON'
      expect { Movie.find_in_tmdb(@search, 'test-key') }.to raise_error(Movie::TMDbError)
    end
  end
end
