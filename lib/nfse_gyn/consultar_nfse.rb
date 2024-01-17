module NfseGyn
  class ConsultarNfse
    attr_reader :invoice_number
    attr_reader :invoice_serie
    attr_reader :invoice_type

    def initialize(invoice_number, invoice_serie, invoice_type)
      @client = NfseGyn::SoapClient.new
      @invoice_number = invoice_number
      @invoice_serie = invoice_serie
      @invoice_type = invoice_type
    end

    def execute!
      if NfseGyn.configuration.mock_mode
        NfseGyn::MockConsultarNfseResponse.new(invoice_number, invoice_serie, invoice_type)
      else
        @client.call(:consultar_nfse_rps, self)
      end
    end

    def to_xml
      Gyoku.xml(
        'ConsultarNfseRpsEnvio' => {
          '@xmlns' => 'http://nfse.goiania.go.gov.br/xsd/nfse_gyn_v02.xsd',

          'IdentificacaoRps' => {
            'Numero' => invoice_number,
            'Serie' => invoice_serie,
            'Tipo' => invoice_type
          },
          'Prestador' => {
            'CpfCnpj' => {
              'Cnpj' => NfseGyn.configuration.cnpj
            },
            'InscricaoMunicipal' => NfseGyn.configuration.inscricao_municipal
          }
        }
      )
    end

    private

    class Response < NfseGyn::Response
      def content
        @content ||= output['ConsultarNfseRpsResposta']
      end

      def body
        content['CompNfse']
      end

      def error?
        !body || content['ListaMensagemRetorno']['MensagemRetorno']['Codigo'] != 'L000'
      end
    end
  end
end
