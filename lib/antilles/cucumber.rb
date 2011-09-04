require 'rubygems'
require 'antilles'

Before('@mimic') do
  Antilles.start
end

After('@mimic') do
  Antilles.clear
end

at_exit do
  server = Antilles.server
  server.stop if server
end
