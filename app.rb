require 'sinatra'
require 'data_mapper'

current_dir = ::File.dirname(::File.expand_path(__FILE__))
error_logger = ::File.new(::File.join(current_dir, 'log', 'error.log'), 'a+')
error_logger.sync = true

configure :development do
  DataMapper.setup(:default, 'sqlite::memory:')
  set :host, 'localhost:9292'
end

configure :production do
  db_path = File.expand_path('../../../db/production.db', __FILE__)
  db_url = "sqlite://#{db_path}"
  DataMapper.setup(:default, db_url)
  set :host, 'tosh.io'
end

# Manages urls
class Url
  include DataMapper::Resource
  property :id, Serial
  property :original, String, length: 500
  property :created_at, DateTime

  @my_urls = {
    twitter: 'https://twitter.com/marciotoshio',
    facebook: 'https://www.facebook.com/marciotoshio',
    linkedin: 'http://br.linkedin.com/in/marciotoshio/',
    youtube: 'http://www.youtube.com/user/marciotoshioide',
    github: 'https://github.com/marciotoshio/'
  }

  def self.get_url(key)
    return @my_urls[key.to_sym] if @my_urls.key?(key.to_sym)
    get(key.to_i(36)).original
  end

  def shorten
    "http://#{Sinatra::Application.settings.host}/#{id.to_s(36)}"
  end
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the url table
Url.auto_upgrade!

before { env['rack.errors'] = error_logger }

get '/' do
  erb :index
end

get '/:url_key' do
  puts 'url key: ' + params[:url_key]
  redirect Url.get_url(params[:url_key])
end

post '/' do
  uri = URI.parse(params[:original_url])
  raise 'Invalid URL' unless (uri.is_a? URI::HTTP) || (uri.is_a? URI::HTTPS)
  @url = Url.first_or_create(original: uri.to_s)
  erb :index
end
