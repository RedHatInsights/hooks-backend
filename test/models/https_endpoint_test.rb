# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class HttpsEndpointTest < HttpEndpointTest
  include Params

  let(:url) { 'https://httpsendpointtest.com' }
  let(:endpoint) do
    FactoryBot.create(:https_endpoint, :with_account, :with_certificate, url: url)
  end

  it 'Handles server ca certificate' do
    test_cert = %(-----BEGIN CERTIFICATE-----
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
    endpoint.server_ca_certificate = test_cert
    endpoint.save!

    endpoint.reload

    assert_equal test_cert, endpoint.server_ca_certificate
  end

  # rubocop:disable Metrics/BlockLength
  it 'Fails on bad server ca certificate' do
    test_cert = %(-----BEGIN CERTIFICATE-----
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
ERROR
-----END CERTIFICATE-----)
    endpoint.server_ca_certificate = test_cert

    assert_not endpoint.valid?
    assert_includes(
      endpoint.errors.full_messages,
      'Data attribute server_ca_certificate contains invalid certificate: nested asn1 error'
    )
  end
  # rubocop:enable Metrics/BlockLength

  it 'allows only storing server_ca_certificate in data' do
    params = ActionController::Parameters.new(
      endpoint: {
        type: 'Endpoints::HttpsEndpoint',
        data: {
          server_ca_certificate: 'TEST',
          foo: 'FAIL'
        }
      }
    )

    actual = Endpoints::HttpsEndpoint.new(endpoint_params(params))

    assert_not actual.valid?
    assert_nil actual.data[:foo]
    assert_equal 'TEST', actual.server_ca_certificate
  end

  it 'passes validation without server_ca_certificate key' do
    endpoint.account_id
    params = ActionController::Parameters.new(
      endpoint: {
        name: 'Endpoint',
        url: 'https://something.somewhere.com',
        type: '::Endpoints::HttpsEndpoint',
        data: {
          foo: 'FAIL'
        }
      }
    )

    actual = Endpoints::HttpsEndpoint.new(endpoint_params(params))
    actual.account = endpoint.account

    assert actual.valid?
    assert_nil actual.data[:foo]
    assert_nil actual.server_ca_certificate
  end
end
