module NfseGyn
  class Configuration
    attr_accessor :wsdl,
                  :test_mode,
                  :mock_mode,
                  :log_level,
                  :ca_cert_path,
                  :cert_key_path,
                  :cert_path,
                  :cert_key_password,
                  :cnpj,
                  :inscricao_municipal,
                  :codigo_municipio,
                  :rps_tipo,
                  :valor_aliquota,
                  :codigo_tributacao_municipio

    def initialize
      @test_mode = false
      @mock_mode = false
      @log_level = :debug
      @wsdl = 'https://nfse.goiania.go.gov.br/ws/nfse.asmx?wsdl'

      @codigo_municipio = '0025300'
      @rps_tipo = 1

      @valor_aliquota = 2

      @codigo_tributacao_municipio = ''
    end

    def rps_serie
      return 'TESTE' if test_mode
      'A'
    end
  end
end
