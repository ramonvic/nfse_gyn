require 'spec_helper'
require 'savon/mock/spec_helper'

RSpec.describe NfseGyn::GerarNfseXML do
  subject { described_class.new(invoice_info) }

  let(:zipcode) { '74672680' }
  let(:description) { 'Teste de RPS' }
  let(:invoice_info) do
    {
      identification_number: '3033',
      description: description,
      data_emissao: '2024-01-11T23:33:22',
      total: 100.10,
      customer: {
        document_type: 'Cnpj',
        document_number: '98924674000187',
        name: 'XPTO Tecnologia Ltda',
        phone_number: '34051727',
        email: 'customer@example.com',
        address: {
          street: 'Rua das Rosas',
          number: '111',
          complement: 'Sobre Loja',
          neighborhood: 'Centro',
          city_ibge_code: '0025300',
          state_code: 'GO',
          zipcode: zipcode
        }
      }
    }
  end

  describe '#initialize' do
    it 'initializes with invoice_info' do
      expect(subject.instance_variable_get(:@invoice)).to eq(invoice_info)
    end
  end

  describe '#certificate' do
    context 'when has not certificate in configuration' do
      it 'shoud certificate is nil' do
        expect(subject.send(:certificate)).to be_nil
      end
    end

    context 'when a certificate exists in configuration' do
      before do
        NfseGyn.configuration.cert_path = fixture_file_path('ssl/cert.pem')
      end

      after do
        NfseGyn.reset!
      end

      it 'shoud certificate not nil' do
        expect(subject.send(:certificate)).to_not be_nil
      end
    end
  end

  describe '#private_key' do
    context 'when has not private_key in configuration' do
      it 'shoud private_key is nil' do
        expect(subject.send(:private_key)).to be_nil
      end
    end

    context 'when a private_key exists in configuration' do
      before do
        NfseGyn.configuration.cert_key_path = fixture_file_path('ssl/key.pem')
      end

      after do
        NfseGyn.reset!
      end

      it 'shoud private_key not nil' do
        expect(subject.send(:private_key)).to_not be_nil
      end
    end
  end

  describe '#to_xml' do
    context 'when everything is fine' do
      it 'contains correct identification number' do
        expect(subject.to_xml).to include %(<Numero>3033</Numero>)
      end

      it 'contains correct description' do
        expect(subject.to_xml).to include %(<Discriminacao>Teste de RPS)
      end

      it 'contains correct description' do
        expect(subject.to_xml).to include %(<ValorServicos>100.1</ValorServicos>)
      end

      it 'contains correct provider information' do
        expect(subject.to_xml).to include %(<Prestador><CpfCnpj><Cnpj>#{NfseGyn.configuration.cnpj}</Cnpj></CpfCnpj><InscricaoMunicipal>#{NfseGyn.configuration.inscricao_municipal}</InscricaoMunicipal></Prestador>)
      end

      it 'contains correct customer information' do
        expect(subject.to_xml).to include %(<IdentificacaoTomador><CpfCnpj><Cnpj>98924674000187</Cnpj></CpfCnpj></IdentificacaoTomador>)
        expect(subject.to_xml).to include %(<RazaoSocial>XPTO Tecnologia Ltda</RazaoSocial>)
        expect(subject.to_xml).to include %(<Endereco><Endereco>Rua das Rosas</Endereco><Numero>111</Numero><Complemento>Sobre Loja</Complemento><Bairro>Centro</Bairro><CodigoMunicipio>0025300</CodigoMunicipio><Uf>GO</Uf><Cep>74672680</Cep></Endereco>)
      end
    end

    context 'when zipcode is wrong format' do
      context 'when number is 05116-050' do
        let(:zipcode) { '05116-050' }

        it { expect(subject.to_xml).to include %(<Cep>05116050</Cep>) }
      end
    end

    context 'when description has especial characters' do
      let(:description) { 'Descrição do Serviço' }

      it { expect(subject.to_xml).to include %(<Discriminacao>Descricao do Servico) }
    end

    context 'when has certificate to sign request' do
      before do
        NfseGyn.configuration.cert_path = fixture_file_path('ssl/cert.pem')
        NfseGyn.configuration.cert_key_path = fixture_file_path('ssl/key.pem')
        NfseGyn.configuration.cert_key_password = 'test'
      end

      after do
        NfseGyn.reset!
      end

      it 'should include signature node' do
        expect(subject.to_xml).to include('<Signature')
      end
    end

    context 'when has not certificate' do
      it 'should not include signature node' do
        expect(subject.to_xml).to_not include('<Signature')
      end
    end
  end
end
