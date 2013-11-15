# encoding: utf-8

require 'spec_helper'
require 'rack/fiber_pool'

def make_request(url)
  f = Fiber.current
  Fiber.new do
    http = EventMachine::HttpRequest.new(url).get
    http.errback { |r| f.resume(r) }
    http.callback { f.resume(http) }
  end.resume
  Fiber.yield
end

require 'sinatra'
class RecursionApp < Sinatra::Base
  use Rack::FiberPool

  set :show_exceptions, false
  set :raise_errors, true

  get '/:id' do
    halt 404 unless (id = params[:id].to_i)
    halt 404 if id == 0

    r = make_request("#{settings.loop_url}/#{id - 1}")
    fail r.error if r.error

    content_type 'text/plain'
    if r.response_header.status == 200
      body r.response
      status 200
    elsif r.response_header.status == 404
      body "ID #{id} not found"
      status 404
    else
      body r.response
      status r.response_header.status
    end
  end
end

describe 'recursion scenario' do
  let(:thin_app) { RecursionApp }
  let(:thin_url) { "http://#{thin_address}:#{thin_port}" }
  before { RecursionApp.set :loop_url, thin_url }

  include_context 'thin server'

  it 'should hit the fiber pool limit' do
    r = make_request "#{thin_url}/100"
    r.response_header.status.should eq 503
    r.response.should eq 'Server is at capacity'
  end

  it 'should hit the fiber pool limit twice' do
    r = make_request "#{thin_url}/100"
    r.response_header.status.should eq 503
    r.response.should eq 'Server is at capacity'

    r = make_request "#{thin_url}/100"
    r.response_header.status.should eq 503
    r.response.should eq 'Server is at capacity'
  end

end
