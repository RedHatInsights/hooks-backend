# frozen_string_literal: true

Rswag::Ui.configure do |c|
  c.swagger_endpoint(
    "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/api-docs/v1/openapi.json",
    'API V1 OpenAPI v3 Docs'
  )
  c.swagger_endpoint(
    "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/api-docs/v1/swagger.json",
    'API V1 Swagger Docs'
  )
end
