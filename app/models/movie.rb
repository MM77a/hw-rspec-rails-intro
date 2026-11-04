class Movie < ApplicationRecord
  class TMDbError < StandardError; end

  def self.find_in_tmdb(search_terms, api_key = ENV['TMDB_API_KEY'])
    fields = search_terms.to_h.symbolize_keys
    query = { api_key: api_key, query: fields[:title] }
    query[:year] = fields[:release_year] if fields[:release_year].present?
    query[:language] = 'en' if fields[:language] == 'en'

    response = Faraday.get('https://api.themoviedb.org/3/search/movie', query) do |request|
      request.options.open_timeout = 5
      request.options.timeout = 10
    end
    raise TMDbError, 'Invalid TMDb API key.' if response.status == 401
    raise TMDbError, 'TMDb search failed. Please try again.' unless response.success?

    results = JSON.parse(response.body).fetch('results')
    results.select! { |movie| movie['original_language'] == 'en' } if fields[:language] == 'en'
    results.map do |movie|
      new(title: movie['title'], rating: 'R', description: movie['overview'], release_date: movie['release_date'])
    end
  rescue Faraday::Error, JSON::ParserError
    raise TMDbError, 'TMDb search failed. Please try again.'
  end

  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end
