require 'sinatra'
require 'sequel'

current_dir = ::File.dirname(::File.expand_path(__FILE__))
error_logger = ::File.new(::File.join(current_dir, 'log', 'error.log'), 'a+')
error_logger.sync = true

configure :development do
  set :db_path, File.expand_path('../db/development.db', __FILE__)
  set :host, 'localhost:9292'
end

configure :production do
  set :db_path, File.expand_path('../../../db/production.db', __FILE__)
  set :host, 'tosh.io'
end

DB = Sequel.connect("sqlite://#{Sinatra::Application.settings.db_path}")
DB.create_table? :urls do
  primary_key :id
  String :original, size: 500
  DateTime :created_at
end

# Manages urls
class Url < Sequel::Model
  BASE_36 = 36
  MY_URLS = {
    twitter: 'https://twitter.com/marciotoshio',
    facebook: 'https://www.facebook.com/marciotoshio',
    linkedin: 'http://br.linkedin.com/in/marciotoshio/',
    youtube: 'http://www.youtube.com/user/marciotoshioide',
    github: 'https://github.com/marciotoshio/',
    instagram: 'https://instagram.com/marciotoshioide',
    resume: 'https://docs.google.com/document/d/1APzK326NfXpNDTbhMEs5e1eBvau4yZrrDBNDH9fBo_s'
  }

  def self.get_url(key)
    return MY_URLS[key.to_sym] if MY_URLS.key?(key.to_sym)
    find(id: key.to_i(BASE_36))
  end

  def shorten
    "https://#{Sinatra::Application.settings.host}/#{id.to_s(BASE_36)}"
  end
end

before { env['rack.errors'] = error_logger }

get '/' do
  erb :index
end

get '/:url_key' do
  url = Url.get_url(params[:url_key])
  unless url.nil?
    redirect url.original
  else
    status 404
    @not_found = true
    erb :index
  end
end

post '/' do
  uri = URI.parse(params[:original_url])
  raise 'Invalid URL' unless (uri.is_a? URI::HTTP) || (uri.is_a? URI::HTTPS)
  @url = Url.find_or_create(original: uri.to_s)
  erb :index
end
