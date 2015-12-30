require 'sinatra'

get '/' do
  logger.info 'Hello World!'
  'Hello world!'
end
