require 'dm-core'
require 'dm-migrations'

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

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
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

helpers SongHelpers

get '/songs' do
  find_songs
  slim :songs
end

get '/songs/new' do
  protected!
  @song = Song.new
  slim :new_song
end

get '/songs/:id' do
  @song = find_song
  slim :show_song
end

get '/songs/:id/edit' do
  protected!
  @song = find_song
  slim :edit_song
end

post '/songs' do
  protected!
  if create_song
    flash[:notice] = "Song successfully added"
  end
  redirect to("/songs/#{@song.id}")
end

put '/songs/:id' do
  protected!
  song = find_song
  if song.update(params[:song])
    flash[:notice] = "Song successfully updated"
  end
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  protected!
  if find_song.destroy
    flash[:notice] = "Song deleted"
  end
  redirect to('/songs')
end

post '/songs/:id/like' do
  @song = find_song
  @song.likes = @song.likes.next
  @song.save
  redirect to"/songs/#{@song.id}" unless request.xhr?
  slim :like, :layout => false
end