# frozen_string_literal: true

require_relative 'lib/nfse_gyn/version'

Gem::Specification.new do |spec|
  spec.name = 'nfse_gyn'
  spec.version = NfseGyn::VERSION
  spec.authors = ['Ramon Vicente']
  spec.email = ['ramonvic@me.com']

  spec.summary = 'Gem para realizar a geração de NFSE em Goiânia'
  spec.homepage = 'https://github.com/ramonvic/nfse_gyn'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '~> 3.0'
  spec.add_dependency 'activesupport', '~> 3.0'
  spec.add_dependency 'savon', '~> 2.9'
  spec.add_dependency 'signer', '~> 1.10'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
