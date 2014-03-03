require 'sinatra'
require 'data_mapper'

configure :development do
   DataMapper.setup(:default, 'sqlite:///Users/tosha/Projects/tosh.io/db/development.db')
   set :host, 'localhost:3000'
end

configure :production do
  DataMapper.setup(:default, 'sqlite:///var/www/tosh.io/db/production.db')
  set :host, 'tosh.io'
end

class Url
  include DataMapper::Resource
  property :id, Serial
  property :original, String
  property :created_at, DateTime

  @my_urls = {
    twitter: "https://twitter.com/marciotoshio",
    facebook: "https://www.facebook.com/marciotoshio",
    linkedin: "http://br.linkedin.com/in/marciotoshio/",
    youtube: "http://www.youtube.com/user/marciotoshioide"
  }

  def self.get_url(key)
    return @my_urls[key.to_sym] if @my_urls.has_key?(key.to_sym)
    self.get(key.to_i(36)).original
  end

  def shorten
    "http://#{Sinatra::Application.settings.host}/#{self.id.to_s(36)}"
  end
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the url table
Url.auto_upgrade!


get '/' do
  erb :index
end

get '/:url_key' do
  puts "#####"
  puts Url.get_url(params[:url_key])
  puts "#####"
  redirect Url.get_url(params[:url_key])
end

post '/' do
  uri = URI::parse(params[:original_url])
  raise "Invalid URL" unless uri.kind_of? URI::HTTP or uri.kind_of? URI::HTTPS
  @url = Url.first_or_create(:original => uri.to_s)
  erb :index
end