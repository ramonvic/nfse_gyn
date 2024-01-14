require 'spec_helper'

RSpec.describe NfseGyn::Configuration do
  context 'when not configured' do
    before do
      NfseGyn.configure do |config|
        config.test_mode = false
        config.cert_path         = nil
        config.ca_cert_path      = nil
        config.cert_key_path     = nil
        config.cert_key_password = nil
      end
    end

    after do
      NfseGyn.reset!
    end

    it { expect(NfseGyn.configuration.cert_path).to be_nil }
    it { expect(NfseGyn.configuration.ca_cert_path).to be_nil }
    it { expect(NfseGyn.configuration.cert_key_path).to be_nil }
    it { expect(NfseGyn.configuration.cert_key_password).to be_nil }
    it { expect(NfseGyn.configuration.wsdl).to eq 'https://nfse.goiania.go.gov.br/ws/nfse.asmx?wsdl' }
  end

  context 'when configured' do
    before do
      NfseGyn.configure do |config|
        config.test_mode = true

        config.cert_path         = '/my/string/path/to/certicate.pem'
        config.ca_cert_path      = '/my/string/path/to/ca/certicate.pem'
        config.cert_key_path     = '/my/string/path/to/certicate/key.pem'
        config.cert_key_password = 'very-secure-encrypted-password'
      end
    end

    after do
      NfseGyn.reset!
    end

    it { expect(NfseGyn.configuration.cert_path).to eq '/my/string/path/to/certicate.pem' }
    it { expect(NfseGyn.configuration.ca_cert_path).to eq '/my/string/path/to/ca/certicate.pem' }
    it { expect(NfseGyn.configuration.cert_key_path).to eq '/my/string/path/to/certicate/key.pem' }
    it { expect(NfseGyn.configuration.cert_key_password).to eq 'very-secure-encrypted-password' }
    it { expect(NfseGyn.configuration.wsdl).to eq 'https://nfse.goiania.go.gov.br/ws/nfse.asmx?wsdl' }
  end
end
