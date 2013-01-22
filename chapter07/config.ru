require 'sinatra/base'

require './main'
require './song'

map('/songs') { run SongController }
map('/') { run Website }