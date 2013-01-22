require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'slim'
require 'sass'
require 'sinatra/flash'
require './sinatra/auth'

class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  property :likes, Integer, :default => 0
  
  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

DataMapper.finalize

module SongHelpers
  def find_songs
    @songs = Song.all
  end

  def find_song
    Song.get(params[:id]) 
  end
  
  def create_song
    @song = Song.create(params[:song])
  end
end

class SongController < Sinatra::Base
  enable :sessions
  enable :method_override
  register Sinatra::Flash
  register Sinatra::Auth

  helpers SongHelpers
  
  configure do
    enable :sessions
    set :username, 'frank'
    set :password, 'sinatra'
  end
  
  configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  end
  
  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
  end
  
  before do
    set_title
  end
  
  def css(*stylesheets)
    stylesheets.map do |stylesheet| 
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end
  
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end
  
  def set_title
    @title ||= "Songs By Sinatra"
  end
  
  get '/' do
    find_songs
    slim :songs
  end
  
  get '/new' do
    protected!
    @song = Song.new
    slim :new_song
  end
  
  get '/:id' do
    @song = find_song
    slim :show_song
  end
  
  get '/:id/edit' do
    protected!
    @song = find_song
    slim :edit_song
  end
  
  post '/' do
    protected!
    create_song
    if create_song
      flash[:notice] = "Song successfully added"
    end
    redirect to("/#{@song.id}")
  end
  
  put '/:id' do
    protected!
    song = find_song
    if song.update(params[:song])
      flash[:notice] = "Song successfully updated"
    end
    redirect to("/#{song.id}")
  end
  
  delete '/:id' do
    protected!
    if find_song.destroy
      flash[:notice] = "Song deleted"
    end
    redirect to('/')
  end
  
  post '/:id/like' do
    @song = find_song
    @song.likes = @song.likes.next
    @song.save
    redirect to("/#{@song.id}") unless request.xhr?
    slim :like, :layout => false
  end
end