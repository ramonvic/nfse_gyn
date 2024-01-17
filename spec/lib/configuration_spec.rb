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

  describe '#from_h' do
    let(:hash) do
      {
        test_mode: true,
        cert_path: 'certicate.pem',
        ca_cert_path: 'ca/certicate.pem',
        cert_key_path: 'certicate/key.pem',
        cert_key_password: 'updated-password'
      }
    end

    before do
      NfseGyn.configuration.from_h(hash)
    end

    after do
      NfseGyn.reset!
    end

    it { expect(NfseGyn.configuration.test_mode).to be_truthy }
    it { expect(NfseGyn.configuration.cert_path).to eq 'certicate.pem' }
    it { expect(NfseGyn.configuration.ca_cert_path).to eq 'ca/certicate.pem' }
    it { expect(NfseGyn.configuration.cert_key_path).to eq 'certicate/key.pem' }
    it { expect(NfseGyn.configuration.cert_key_password).to eq 'updated-password' }
  end
end
