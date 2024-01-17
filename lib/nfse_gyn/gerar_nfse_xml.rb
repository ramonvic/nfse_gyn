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
              '@Id' => raise_if_missing(@invoice[:identification_number], :identification_number),
              'IdentificacaoRps' => {
                'Numero' => @invoice[:identification_number],
                'Serie' => raise_if_missing(NfseGyn.configuration.rps_serie, :rps_serie),
                'Tipo' => raise_if_missing(NfseGyn.configuration.rps_tipo, :rps_tipo)
              },
              'DataEmissao' => raise_if_missing(@invoice[:data_emissao], :data_emissao),
              'Status' => 1
            },

            'Servico' => {
              'Valores' => {
                'ValorServicos' => raise_if_missing(@invoice[:total], :total),
                'Aliquota' => raise_if_missing(NfseGyn.configuration.valor_aliquota, :valor_aliquota)
              },

              'CodigoTributacaoMunicipio' => raise_if_missing(NfseGyn.configuration.codigo_tributacao_municipio, :codigo_tributacao_municipio),
              'Discriminacao' => raise_if_missing(clear(@invoice[:description]), :description),
              'CodigoMunicipio' => raise_if_missing(NfseGyn.configuration.codigo_municipio, :codigo_municipio)
            },

            'Prestador' => {
              'CpfCnpj' => {
                'Cnpj' => raise_if_missing(NfseGyn.configuration.cnpj, :prestador_cnpj)
              },
              'InscricaoMunicipal' => raise_if_missing(NfseGyn.configuration.inscricao_municipal, :prestador_inscricao_municipal)
            },

            'Tomador' => tomador
          }
        }
      )
    end

    private

    def raise_if_missing(param, param_name)
      throw "Param #{param_name} is missing" if param.blank?
      param
    end

    def sign(xml)
      return xml if NfseGyn.configuration.mock_mode || !certificate.present? || !private_key.present?
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
          'CpfCnpj' => { document_type => raise_if_missing(document_number, :tomador_document_number)}
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
