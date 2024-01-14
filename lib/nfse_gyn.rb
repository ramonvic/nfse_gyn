# frozen_string_literal: true

require 'ostruct'
require 'active_model'

require 'nfse_gyn/version'
require 'nfse_gyn/configuration'
require 'nfse_gyn/sanitizer'
require 'nfse_gyn/soap_client'
require 'nfse_gyn/response'
require 'nfse_gyn/gerar_nfse'
require 'nfse_gyn/consultar_nfse'

HTTPI.adapter = :net_http

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
