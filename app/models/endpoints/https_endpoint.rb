# frozen_string_literal: true

require 'net/http'
require 'uri'

module Endpoints
  class HttpsEndpoint < Endpoints::HttpEndpoint
    validate :server_ca_certificate_is_a_valid_chain

    def self.stored_parameters
      super + [:server_ca_certificate]
    end

    def server_ca_certificate
      data&.fetch('server_ca_certificate', nil)
    end

    def server_ca_certificate=(value)
      self.data ||= {}
      self.data['server_ca_certificate'] = value
    end

    protected

    def http_request
      Net::HTTP.start(
        address.host,
        address.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        cert_store: ca_cert_store
      ) do |connection|
        yield(connection)
      end
    end

    private

    def ca_cert_store
      store = OpenSSL::X509::Store.new
      if server_ca_certificate.blank?
        store.set_default_paths
      else
        certificates_chain&.each do |cert|
          store.add_cert(cert)
        end
      end
      store
    end

    def server_ca_certificate_is_a_valid_chain
      certificates_chain
      true
    rescue OpenSSL::X509::CertificateError => e
      errors.add(:data, "attribute server_ca_certificate contains invalid certificate: #{e.message}")
    end

    def certificates_chain
      server_ca_certificate&.split(/(?=-----BEGIN)/)&.map do |cert|
        OpenSSL::X509::Certificate.new(cert)
      end
    end
  end
end
