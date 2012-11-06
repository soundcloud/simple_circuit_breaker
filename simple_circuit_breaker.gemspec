require './lib/simple_circuit_breaker'

Gem::Specification.new do |s|
  s.name         = 'simple_circuit_breaker'
  s.version      = SimpleCircuitBreaker::VERSION
  s.platform     = Gem::Platform::RUBY
  s.summary      = 'Ruby Circuit Breaker implementation'
  s.description  = 'Simple Ruby implementation of the Circuit Breaker design pattern'
  s.authors      = ['Julius Volz', 'Tobias Schmidt']
  s.email        = 'julius@soundcloud.com ts@soundcloud.com'
  s.homepage     = 'http://github.com/soundcloud/simple_circuit_breaker'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- test/*`.split("\n")
  s.require_path = 'lib'

  s.required_ruby_version = '>= 1.9'
end
