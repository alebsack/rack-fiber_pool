# encoding: utf-8

module Rack
  # Rack::FiberPool is a Rack Middleware which runs each request in its own
  # fiber.  Fibers are reused for each request.  This middleware is suitable
  # for Thin servers.
  class FiberPool
    VERSION = '1.0.0.beta.1'
    SIZE = 100

    # Initializer for Rack::FiberPool
    # @param [Hash] opts the options to configure the fiber pool
    # @option opts [Fixnum] :size Size of the fiber pool (concurrent requests)
    # @option opts [String] :rescue_exception your custom exception handler
    def initialize(app, options = {})
      @app = app
      @fibers = []
      @count = options[:size] || SIZE
      @count.times do
        @fibers << Fiber.new { |block| loop { block = fiber_loop(block) } }
      end
      @rescue_exception = options[:rescue_exception] || proc do |env, e|
        [500, {}, ["#{e.class.name}: #{e.message.to_s}"]]
      end
      yield @fiber_pool if block_given?
    end

    def call(parent_env)
      env = parent_env.dup
      fail 'Server is at capacity' unless (fiber = @fibers.shift)
      fiber.resume ->{ request(env) }
      throw :async
    rescue => exception
      [503, {}, [exception.message]]
    end

    private

    def request(env)
      env['async.orig_callback'] = env.delete('async.callback')
      result = @app.call(env)
      env['async.orig_callback'].call result
    rescue Exception => exc
      env['async.orig_callback'].call @rescue_exception.call(env, exc)
    end

    def fiber_loop(block)
      block.call
      @fibers.unshift Fiber.current
      Fiber.yield
    end
  end
end
