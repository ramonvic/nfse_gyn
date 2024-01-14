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

    def error?
      binding.pry
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
