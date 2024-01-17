require 'spec_helper'
require 'savon/mock/spec_helper'

RSpec.describe NfseGyn::GerarNfse do
  include Savon::SpecHelper

  subject { described_class.new(nota_fiscal_info) }

  let(:nota_fiscal_info) { {} }

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  describe '#to_xml' do
    it 'should call GerarNfseXML builder class' do
      expect_any_instance_of(NfseGyn::GerarNfseXML).to receive(:to_xml).once
      subject.to_xml
    end
  end

  describe '#execute!' do
    let(:response) { File.read(fixture_file_path('xmls/valid_gerar_nfse_response.xml')) }
    let(:xml_payload) { File.read(fixture_file_path('xmls/valid_gerar_nfse_request.xml')) }
    let(:request_payload) { "<ArquivoXML><![CDATA[#{xml_payload}]]></ArquivoXML>" }

    before do
      allow(subject).to receive(:to_xml).and_return(xml_payload)
    end

    context 'valid request' do
      before { savon.expects(:gerar_nfse).with(message: request_payload).returns(response) }

      it 'returns a valid response' do
        expect(subject.execute!).to be_successful
      end

      it 'response number is equals 370' do
        expect(subject.execute!.number).to eq('370')
      end

      it 'response verification_code is equals MB94-C3ZA' do
        expect(subject.execute!.verification_code).to eq('MB94-C3ZA')
      end

      it 'response municipal_registration is equals 1300687' do
        expect(subject.execute!.municipal_registration).to eq('1300687')
      end

      it 'response link is equals nf link' do
        expect(subject.execute!.link).to eq('https://www2.goiania.go.gov.br/sistemas/snfse/asp/snfse00200w0.asp?inscricao=1300687&nota=370&verificador=MB94-C3ZA')
      end
    end

    context 'invalid request' do
      let(:response) { File.read(fixture_file_path('xmls/invalid_gerar_nfse_response.xml')) }

      before { savon.expects(:gerar_nfse).with(message: request_payload).returns(response) }

      it 'returns a invalid response' do
        expect(subject.execute!).to_not be_successful
      end

      it 'returns a error message' do
        expect(subject.execute!.error_message).to eq('Para essa Inscrição Municipal/CNPJ já existe um RPS informado com o mesmo número, série e tipo.')
      end
    end

    context 'when mock data' do
      before do
        NfseGyn.configuration.mock_mode = true
        allow(NfseGyn::MockGerarNfseResponse).to receive(:new).and_return('mock response')
      end

      after { NfseGyn.configuration.mock_mode = false }

      it 'should return a MockConsultarNfseResponse' do
        expect(subject.execute!).to eq('mock response')
      end
    end
  end
end
