# frozen_string_literal: true

require 'open_api'

OpenApi::Config.class_eval do
  # Part 1: configs of this gem
  self.file_output_path = 'swagger/v1'
  self.model_base = ApplicationRecord

  # Part 2: config (DSL) for generating OpenApi info
  open_api :openapi, base_doc_classes: [ApplicationController, AppRegistrationController]
  info version: '1.0.0', title: 'API V1' # , description: ..
  # server 'http://localhost:3000', desc: 'Internal staging server for testing'
  # bearer_auth :Authorization

  # TODO: we should be able to remove this element, this is fixed in ZRO master branch
  # https://github.com/zhandao/zero-rails_openapi/pull/56
  global_security 'nil'
end
