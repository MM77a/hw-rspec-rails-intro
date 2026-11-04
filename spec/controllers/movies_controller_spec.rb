require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before(:each) do
      @search = { title: 'hardware', release_year: '1990', language: 'en' }
      @fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
    end

    it 'calls the model with the search fields' do
      expect(Movie).to receive(:find_in_tmdb).with(@search.stringify_keys)
      get :search_tmdb, params: @search
    end

    describe 'after valid search' do
      before(:each) { get :search_tmdb, params: @search }

      it 'selects the Search Results template' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the search results available to the template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    it 'opens the search form without calling TMDb or showing an error' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb
      expect(flash[:alert]).to be_nil
    end

    it 'rejects a blank title without calling TMDb' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb, params: @search.merge(title: '  ')
      expect(flash[:alert]).to eq('Please fill in all required fields!')
    end

    it 'allows a search without a release year' do
      get :search_tmdb, params: @search.except(:release_year)
      expect(assigns(:movies)).to eq(@fake_results)
    end

    it 'warns when there are no matching movies' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, params: @search
      expect(flash[:alert]).to eq('No movies found with given parameters!')
    end

    it 'shows service errors as warnings' do
      allow(Movie).to receive(:find_in_tmdb).and_raise(Movie::TMDbError, 'TMDb search failed. Please try again.')
      get :search_tmdb, params: @search
      expect(flash[:alert]).to eq('TMDb search failed. Please try again.')
    end
  end

  describe 'adding a search result' do
    it 'saves permitted fields and redirects to search with confirmation' do
      attributes = { title: 'Hardware', rating: 'R', release_date: '1990-09-14', description: 'A robot.' }
      movie = instance_double(Movie, title: 'Hardware')
      expect(Movie).to receive(:create!).with(ActionController::Parameters.new(attributes).permit!).and_return(movie)
      post :add_movie, params: { movie: attributes.merge(id: '123') }
      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:notice]).to eq('Hardware was successfully added to RottenPotatoes.')
    end
  end
end
