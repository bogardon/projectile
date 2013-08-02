Gem::Specification.new do |gem|
  gem.authors       = ["John Z Wu"]
  gem.email         = ["bogardon@gmail.com"]
  gem.description   = "Simple RubyMotion JSON model layer"
  gem.summary       = "Simple RubyMotion JSON model layer"
  gem.homepage      = "https://github.com/bogardon/projectile"
  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.name          = "projectile"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"
  gem.license       = 'MIT'
end
