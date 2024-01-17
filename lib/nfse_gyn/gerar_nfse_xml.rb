# frozen_string_literal: true

require 'signer'

module NfseGyn
  class GerarNfseXML
    def initialize(invoice_info)
      @invoice = invoice_info
    end

    def to_xml
      "<GerarNfseEnvio xmlns=\"http://nfse.goiania.go.gov.br/xsd/nfse_gyn_v02.xsd\">#{sign(body)}</GerarNfseEnvio>"
    end

    def body
      Gyoku.xml(
        'Rps' => {
          'InfDeclaracaoPrestacaoServico' => {
            '@xmlns' => 'http://nfse.goiania.go.gov.br/xsd/nfse_gyn_v02.xsd',
            'Rps' => {
              '@Id' => @invoice[:identification_number],
              'IdentificacaoRps' => {
                'Numero' => @invoice[:identification_number],
                'Serie' => NfseGyn.configuration.rps_serie,
                'Tipo' => NfseGyn.configuration.rps_tipo
              },
              'DataEmissao' => @invoice[:data_emissao],
              'Status' => 1
            },

            'Servico' => {
              'Valores' => {
                'ValorServicos' => @invoice[:total],
                'Aliquota' => NfseGyn.configuration.valor_aliquota
              },

              'CodigoTributacaoMunicipio' => NfseGyn.configuration.codigo_tributacao_municipio,
              'Discriminacao' => clear(@invoice[:description]),
              'CodigoMunicipio' => NfseGyn.configuration.codigo_municipio
            },

            'Prestador' => {
              'CpfCnpj' => {
                'Cnpj' => NfseGyn.configuration.cnpj
              },
              'InscricaoMunicipal' => NfseGyn.configuration.inscricao_municipal
            },

            'Tomador' => tomador
          }
        }
      )
    end

    def sign(xml)
      return xml if !certificate.present? || !private_key.present?
      signer = Signer.new(xml, canonicalize_algorithm: :c14n_1_0, wss: false)
      signer.cert = OpenSSL::X509::Certificate.new(certificate)
      signer.private_key = OpenSSL::PKey::RSA.new(private_key, NfseGyn.configuration.cert_key_password)
      signer.security_node = signer.document.root
      node = signer.document.dup.at_xpath("//*[@Id=#{@invoice[:identification_number]}]")
      signer.digest!(node, enveloped: true)
      signer.sign!(issuer_serial: true)
      signer.document.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
    end

    def certificate
      @certificate ||= File.read(NfseGyn.configuration.cert_path) if NfseGyn.configuration.cert_path.present?
    end

    def private_key
      @private_key ||= File.read(NfseGyn.configuration.cert_key_path) if NfseGyn.configuration.cert_key_path.present?
    end

    def clear(value)
      NfseGyn::Sanitizer.new(value).clear
    end

    def document_type
      @invoice[:customer][:document_type]
    end

    def document_number
      @invoice[:customer][:document_number]
    end

    def tomador
      xml = {}

      if document_type.present?
        xml['IdentificacaoTomador'] = {
          'CpfCnpj' => { document_type => document_number }
        }
      end

      if @invoice[:customer][:name].present?
        xml['RazaoSocial'] = clear(@invoice[:customer][:name])
      end

      if @invoice[:customer][:address].present?
        xml['Endereco'] = {
          'Endereco' => clear(@invoice[:customer][:address][:street]),
          'Numero' => clear(@invoice[:customer][:address][:number])
        }

        if @invoice[:customer][:address][:complement].present?
          xml['Endereco']['Complemento'] = clear(@invoice[:customer][:address][:complement])
        end

        xml['Endereco']['Bairro'] = clear(@invoice[:customer][:address][:neighborhood])
        xml['Endereco']['CodigoMunicipio'] = @invoice[:customer][:address][:city_ibge_code]
        xml['Endereco']['Uf'] = @invoice[:customer][:address][:state_code]
        xml['Endereco']['Cep'] = @invoice[:customer][:address][:zipcode].scan(/\d/).join
      end
      xml
    end
  end
end
