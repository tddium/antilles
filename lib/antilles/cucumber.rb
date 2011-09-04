require 'rubygems'
require 'antilles'

Before('@mimic') do
  MimicServer.start
end

After('@mimic') do
  MimicServer.clear
end

at_exit do
  server = MimicServer.server
  server.stop if server
end
