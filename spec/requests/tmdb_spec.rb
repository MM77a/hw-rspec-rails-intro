require 'rails_helper'

RSpec.describe 'TMDb search and import', type: :request do
  it 'searches, posts a result, and shows the saved movie on the home page' do
    stub_request(:get, /api\.themoviedb\.org/).to_return(body: {
      results: [{ title: 'Hardware', release_date: '1990-09-14', overview: 'A robot.', original_language: 'en' }]
    }.to_json)

    get movies_path
    expect(response.body).to include('href="/search"')
    get search_tmdb_path
    expect(response.body).to include('id="tmdb_form"')
    expect(response.body).not_to include('id="search_movies"')

    get search_tmdb_path, params: { title: 'Hardware', language: 'en' }
    expect(response.body).to include('id="search_movies"', 'Hardware', 'action="/add_movie"', 'method="post"')
    fields = Nokogiri::HTML(response.body).at_css('#search_movies form').css('input[name^="movie["]').to_h do |field|
      [field['name'][/\Amovie\[(.*)\]\z/, 1], field['value']]
    end

    expect { post add_movie_path, params: { movie: fields } }.to change(Movie, :count).by(1)
    follow_redirect!
    expect(response.body).to include('Hardware was successfully added to RottenPotatoes.')
    get movies_path
    expect(response.body).to include('Hardware')
    expect(Movie.last).to have_attributes(title: 'Hardware', rating: 'R', description: 'A robot.')
  end

  it 'shows warnings without a results table and clears them on the next visit' do
    get search_tmdb_path, params: { title: '' }
    expect(response.body).to include('alert-warning', 'Please fill in all required fields!')
    expect(response.body).not_to include('id="search_movies"')
    get search_tmdb_path
    expect(response.body).not_to include('Please fill in all required fields!')
  end
end
