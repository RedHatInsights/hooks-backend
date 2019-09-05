# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :endpoint, :class => ::Endpoint do
    sequence(:name) { |i| "endpoint#{i}" }
    sequence(:url) { |i| "http://something.somewhere.com?foo=#{i}" }
    type { ::Endpoint.name }

    trait :with_account do
      association :account, :factory => :account
    end

    factory :http_endpoint, class: Endpoints::HttpEndpoint do
      type { Endpoints::HttpEndpoint.name }
    end

    factory :https_endpoint, class: Endpoints::HttpsEndpoint do
      type { Endpoints::HttpsEndpoint.name }
      sequence(:url) { |i| "https://something.somewhere.com?foo=#{i}" }

      trait :with_certificate do
        server_ca_certificate do
          %(-----BEGIN CERTIFICATE-----
MIIDBzCCAe+gAwIBAgIUcW0AqsAhIuhkXQ+7vTiP3TTOAVAwDQYJKoZIhvcNAQEL
BQAwEzERMA8GA1UEAwwIZW5kcG9pbnQwHhcNMTkwNDIyMTExMzMwWhcNMjAwNDIx
MTExMzMwWjATMREwDwYDVQQDDAhlbmRwb2ludDCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAMsmIBDNLCF69qJW6oMvO2XAaz3INTS/kXpOjH+26rFTfhiC
OHVY4v0GBk32vCkPh+BWi7jztH4two/XWBN6EXUl7LFhH1KmXH1i9IBowaaeLJ01
gw7oz5NlSw8nJH/v5RDOzQ/ld7XaiRRcPeMK+lMe86DsrGVD1ZODChlqwom6VkM+
rth/xDFKTEe198bA5KQOe3QeaYXtaVNpNolMk88oX6b+TqRZs3Mb0+KYjvfHTtXM
UdvlzGhq4fheYzj99LWjnXqqMz0vTxfp5uPymCE6skLAePi0iwv1bz321DSsSDMM
xhO13DbsMW5LeRThIK9td6dr9s9ElvvTyUeubo0CAwEAAaNTMFEwHQYDVR0OBBYE
FPEunEw24jYbERLMltEM0mvaPBC4MB8GA1UdIwQYMBaAFPEunEw24jYbERLMltEM
0mvaPBC4MA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAHLbSFXf
X3Iqh+MyENpeqx7R0NDOsj/loMvQt0f4tmkp/CKOFEY9cdza8J9a5A3h4HQqVOrj
9nRh5AtC5EYjCzkIDPG84H0iUMg4laoEgK7T8TRME29oerihXkvMfu0QRcdrEykm
tyI9IoTBGW6Kf6l/AkFL88qoPN8Hapft2SbjFQyPRKNDeDXPz7ruLfERbGJ0XrQ5
iJzmz4fwB1E67sIomo4afClj2o6Yvxv9XyhD/RlVrjS7dxvPbx0FmoZJ/v+3ulyA
ok42kgec8b8Ft+he1KbjmAToCWA/1EfiO6e3BpASO5nBaNvn4pkbmBrxQipKfBSi
6ngtpYfSDcEQIj8=
-----END CERTIFICATE-----)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
