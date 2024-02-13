# frozen_string_literal: true

require 'nfse_gyn'
require 'pry'

def fixture_file_path(filename)
  File.join(File.dirname(__FILE__), 'fixtures', filename)
end

Dir[File.join(File.dirname(__FILE__), '/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.before do
    NfseGyn.configure do |nfse|
      nfse.test_mode = true
      nfse.cnpj = '46034125000133'
      nfse.inscricao_municipal = '5671485'
      nfse.codigo_tributacao_municipio = '791120000'
    end
  end

  # config.disable_monkey_patching!

  config.profile_examples = 5

  config.order = :random

  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
