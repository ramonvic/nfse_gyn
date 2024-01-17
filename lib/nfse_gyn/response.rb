module NfseGyn
  class Response
    def initialize(payload)
      @payload = payload
    end

    def class_name
      self.class.to_s.split('::')[1]
    end

    def successful?
      !error?
    end

    def link
      <<-URL.squish
        https://www2.goiania.go.gov.br/sistemas/snfse/asp/snfse00200w0.asp?inscricao=#{municipal_registration}&nota=#{number}&verificador=#{verification_code}
      URL
    end

    def municipal_registration
      p = body['Nfse']['InfNfse']['DeclaracaoPrestacaoServico']['Prestador']
      p['IdentificacaoPrestador']['InscricaoMunicipal'] if successful?
    end

    def number
      body['Nfse']['InfNfse']['Numero'] if successful?
    end

    def verification_code
      body['Nfse']['InfNfse']['CodigoVerificacao'] if successful?
    end

    def error?
      content['ListaMensagemRetorno'].present?
    end

    def error_message
      if error? && content['ListaMensagemRetorno']['MensagemRetorno'].present?
        content['ListaMensagemRetorno']['MensagemRetorno']['Correcao'].try(:strip)
      end
    end

    def output
      response = @payload.body.try(:values).try(:first)
      @output ||= Nori.new.parse(response.try(:values).try(:first) || response)
    end
  end
end
