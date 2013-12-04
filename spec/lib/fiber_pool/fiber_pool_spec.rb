# encoding: utf-8

require 'spec_helper'

require 'rack/fiber_pool'

describe Rack::FiberPool do
  class TestBuggyApp
    attr_accessor :result
    def call(env)
      env['async.fiberpool_callback'] = proc { |result| @result = result }
      fail Exception, 'I\'m buggy! Please fix me.'
    end
  end

  class TestApp
    attr_accessor :result
    def call(env)
      env['async.fiberpool_callback'] = proc { |result| @result = result }
      [200, { 'Content-Type' => 'text/plain' }, ['Hello world!']]
    end
  end

  class OriginalSyncApp
    attr_accessor :result

    def call(env)      
      env['async.callback'] = proc { |result| @result = result }
      [200, { 'Content-Type' => 'text/plain' }, ['Hello world!']]
    end
  end

  subject { app.result }
  let(:options) { {} }
  before do
    catch :async do
      Rack::MockRequest.new(Rack::FiberPool.new(app, options)).get('/')
    end
  end

  describe 'usage' do
    let(:app) { TestApp.new }
    it { should eql [200, { 'Content-Type' => 'text/plain' }, ['Hello world!']] }
  end

  describe 'size' do
    let(:app) { TestApp.new }
    let(:options) { { size: 5 } }
    it { should eql [200, { 'Content-Type' => 'text/plain' }, ['Hello world!']] }
  end

  describe 'remove_async_callback' do
    let(:app) { OriginalSyncApp.new }
    let(:options) { { remove_async_callback: false } }
    it { should eql [200, { 'Content-Type' => 'text/plain' }, ['Hello world!']] }
  end

  describe 'exception' do
    let(:app) { TestBuggyApp.new }
    it { should eql [500, {}, ['Exception: I\'m buggy! Please fix me.']] }
  end

  describe 'custom rescue exception' do
    let(:app) { TestBuggyApp.new }
    let(:rescue_exception) do
      proc { |env, exception| [503, {}, [exception.message]] }
    end
    let(:options) { { rescue_exception: rescue_exception } }
    it { should eql [503, {}, ['I\'m buggy! Please fix me.']] }
  end
end
