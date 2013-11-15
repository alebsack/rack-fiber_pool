# encoding: utf-8

shared_context 'thin server' do
  before(:all) do
    require 'thin'
    require 'em-synchrony'
    require 'sinatra'
    require 'em-http-request'
  end

  let(:thin_address) { '127.0.0.1' }
  let(:thin_port) { ENV['PORT'] || 42_678 }
  around(:each) do |example|
    require 'em-synchrony'
    EventMachine.error_handler do |e|
      puts "Error in Eventmachine: #{e.inspect}"
      puts e.backtrace.join("\n")
      EventMachine.stop
    end
    EventMachine.synchrony do
      options = { signals: false }
      Thin::Logging.silent = true
      server = Thin::Server.new(thin_address, thin_port, options)
      server.maximum_connections = 1024
      server.app = thin_app
      server.start!
      example.run
      server.stop
      EventMachine.stop
    end
  end
end
