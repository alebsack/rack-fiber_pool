# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name = "rack-fiber_pool"
  spec.version = '1.0.0.beta.1'
  spec.authors = ["Mike Perham", 'Adam Lebsack']
  spec.date = Time.now.utc.strftime("%Y-%m-%d")
  spec.email = %w(mperham@gmail.com alebsack@gmail.com)
  spec.homepage = "http://github.com/alebsack/rack-fiber_pool"
  spec.rdoc_options = ["--charset=UTF-8"]
  spec.require_paths = ["lib"]
  spec.summary = spec.description = "Rack middleware to run each request within a Fiber"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'fiberpool'

  spec.add_development_dependency 'thin', '~> 1.6.1'
  spec.add_development_dependency 'em-synchrony'
  spec.add_development_dependency 'em-http-request'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'spork'
  spec.add_development_dependency 'simplecov'
end

