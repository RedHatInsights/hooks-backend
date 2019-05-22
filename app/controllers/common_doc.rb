# frozen_string_literal: true

require 'open_api'

# this class will be used to declare common documentation properties
class DocsController < ApplicationController
  include OpenApi::DSL

  components do
    header! RHIdentity: [:'X-RH-IDENTITY', String, { example: 'identity' }]
  end

  components do
    query Order: [:order, String, {
      desc: 'The ordering by which the returned collection should be sorted.',
      example: ' '
    }]
    query Limit: [:limit, Integer, {
      desc: 'The maximum number of records to return.',
      example: '10'
    }]
    query Offset: [:offset, Integer, {
      desc: 'The number of records to skip before returning.',
      example: '10'
    }]
  end

  components do
    schema :Relationship, type: {
      id: String,
      'type' => String
    }
    schema :Relationships, type: {
      data: [:Relationship]
    }
  end

  components do
    schema :Metadata, type: {
      total: {
        type: Integer,
        desc: 'The total number of available records.',
        example: 100
      },
      limit: {
        type: Integer,
        desc: 'The maximum number of records to return.',
        example: 10
      },
      offset: {
        type: Integer,
        desc: 'The number of records to skip before returning.',
        example: 20
      }
    }
  end

  components do
    schema :Links, type: {
      first: {
        type: 'uri',
        description: 'Link to the first page of records'
      },
      last: {
        type: 'uri',
        description: 'Link to the last page of records'
      },
      previous: {
        type: 'uri',
        description: 'Link to previous page of records, if such page exists'
      },
      next: {
        type: 'uri',
        description: 'Link to next page of records, if such page exists'
      }
    }
  end

  components do
    schema :Errors, type: {
      errors: [{
        id: String,
        status: String,
        code: String,
        title: String,
        detail: String,
        source: {
          pointer: String,
          parameter: String
        },
        meta: {}
      }]
    }
  end
end
