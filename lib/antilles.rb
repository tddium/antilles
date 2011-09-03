require 'rubygems'
require 'mimic'
require 'timeout'
require 'daemons'
require 'httparty'

class Antilles
  attr_accessor :port
  attr_accessor :log

  def initialize(port=nil, log=nil)
    @port = port || 8080
    @pid_list = []
    @log = log
  end

  def start
    pid = Kernel.fork
    if pid.nil? then
      args = {:fork => false,
              :host => 'localhost',
              :port => @port,
              :remote_configuration_path => '/api'}
      args[:log] = @log if @log
      Mimic.mimic(args) do
        [:INT, :TERM].each { |sig| trap(sig) { Kernel.exit!(0) } }
      end
      Kernel.exit!(0)
    end
    @pid_list.push(pid)
    wait
  end

  def stop
    @pid_list.each do |pid|
      Process.kill("TERM", pid)
    end
    @pid_list = []
  end

  def wait
    (0...5).each do |i|
      if ping then
        break
      end
      Kernel.sleep(0.1)
    end
  end

  def ping
    begin
      http = call_api(:get,  '/api/ping')
    rescue Exception, Timeout::Error
      return false
    end
    return http.code == 200
  end

  def clear
    http = call_api(:post,  '/api/clear')
    return http
  end

  def install(verb, path, body, options={})
    api_headers = options.delete(:api_headers)
    params = { 'path' => path, 'body' => body.to_json }.merge(options)
    http = call_api(:post,  "/api/#{verb}", params.to_json, api_headers)
    return http
  end

  def call_api(method, path, params = {}, headers = {})
    tries = 0
    retries = 7
    done = false
    while (tries <= retries) && !done
      begin
        http = HTTParty.send(method, "http://localhost:#{@port}#{path}",
                             :body => params, :headers => headers)
        done = true
      rescue SystemCallError
        Kernel.sleep(0.5)
      rescue Timeout::Error
        Kernel.sleep(0.5)
      ensure
        tries += 1
      end
    end
    raise Timeout::Error if tries > retries && retries >= 0
    return http
  end

  class << self
    def configure(&block)
      yield server 
    end

    def start
      return server if server.started?
      server.start
      server
    end

    def server
      @server ||= Antilles.new
      @server
    end

    def clear
      @server.clear rescue nil
    end
  end
end

