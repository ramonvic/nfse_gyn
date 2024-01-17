require 'savon'

module NfseGyn
  class SoapClient
    def call(method, object)
      xml = "<ArquivoXML><![CDATA[#{object.to_xml}]]></ArquivoXML>"
      payload = client.call(method, message: xml)
      object.class::Response.new payload
    end

    private

    def client
      log = NfseGyn.configuration.log_level != :none
      @client ||= Savon.client(
        wsdl: NfseGyn.configuration.wsdl,
        env_namespace: :soap,
        namespace_identifier: nil,
        element_form_default: :unqualified,
        ssl_verify_mode: :none,
        ssl_cert_file: NfseGyn.configuration.cert_path,
        ssl_cert_key_file: NfseGyn.configuration.cert_key_path,
        ssl_ca_cert_file: NfseGyn.configuration.ca_cert_path,
        ssl_cert_key_password: NfseGyn.configuration.cert_key_password,
        log_level: log ? NfseGyn.configuration.log_level : nil,
        log: log,
        open_timeout: 120,
        read_timeout: 120
      )
    end
  end
end
