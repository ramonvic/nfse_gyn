# frozen_string_literal: true

require 'ostruct'
require 'i18n'

require 'nfse_gyn/version'
require 'nfse_gyn/extensions'
require 'nfse_gyn/configuration'
require 'nfse_gyn/sanitizer'
require 'nfse_gyn/soap_client'
require 'nfse_gyn/response'
require 'nfse_gyn/gerar_nfse'
require 'nfse_gyn/consultar_nfse'
require 'nfse_gyn/mock_gerar_nfse_response'
require 'nfse_gyn/mock_consultar_nfse_response'

HTTPI.adapter = :net_http
I18n.config.available_locales = :en

module NfseGyn
  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= NfseGyn::Configuration.new
  end

  def self.reset!
    @configuration = nil
  end
end
