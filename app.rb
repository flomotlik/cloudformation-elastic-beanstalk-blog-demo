require 'sinatra'

get '/' do
  logger.info Time.now.to_s
  'Hello world!'
end
