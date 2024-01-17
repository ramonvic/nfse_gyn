require 'nfse_gyn/gerar_nfse_xml'

module NfseGyn
  class GerarNfse
    def initialize(invoice)
      @invoice = invoice
      @client = NfseGyn::SoapClient.new
    end

    def execute!
      if NfseGyn.configuration.mock_mode
        NfseGyn::MockGerarNfseResponse.new(@invoice)
      else
        @client.call(:gerar_nfse, self)
      end
    end

    def to_xml
      GerarNfseXML.new(@invoice).to_xml
    end

    private

    class Response < NfseGyn::Response
      def content
        @content ||= output['GerarNfseResposta']
      end

      def number
        content['ListaNfse']['CompNfse']['Nfse']['InfNfse']['Numero'] if successful?
      end

      def verification_code
        content['ListaNfse']['CompNfse']['Nfse']['InfNfse']['CodigoVerificacao'] if successful?
      end

      def error?
        !content['ListaNfse'] || content['ListaMensagemRetorno']['MensagemRetorno']['Codigo'] != 'L000'
      end

      def errors
        if error?
          message = content['ListaMensagemRetorno']['MensagemRetorno']
          message = [message] if message.is_a?(Hash)

          message
        end
      rescue StandardError
        content
      end
    end
  end
end
