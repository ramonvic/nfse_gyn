require 'spec_helper'
require 'savon/mock/spec_helper'

RSpec.describe NfseGyn::ConsultarNfse do
  include Savon::SpecHelper

  subject { described_class.new(invoice_number, invoice_serie, invoice_type) }

  let(:invoice_number) { 1 }
  let(:invoice_serie) { 'UNICA' }
  let(:invoice_type) { 1 }

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  describe '#execute!' do
    let(:xml_payload) { File.read(fixture_file_path('xmls/valid_consultar_nfse_request.xml')) }
    let(:request_payload) { "<ArquivoXML><![CDATA[#{xml_payload}]]></ArquivoXML>" }

    before do
      allow(subject).to receive(:to_xml).and_return(xml_payload)
      savon.expects(:consultar_nfse_rps).with(message: request_payload).returns(response)
    end

    context 'valid request' do
      let(:response) { File.read(fixture_file_path('xmls/valid_consultar_nfse_response.xml'))}

      it 'returns a valid response' do
        expect(subject.execute!).to be_successful
      end
    end

    context 'invalid request' do
      let(:response) { File.read(fixture_file_path('xmls/invalid_consultar_nfse_response.xml'))}

      it 'returns a invalid response' do
        expect(subject.execute!).to_not be_successful
      end

      it 'returns a error message' do
        expect(subject.execute!.error_message).to eq('RPS NAO ENCONTRADO')
      end
    end
  end
end
