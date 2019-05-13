# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/swagger'

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      parameters: {
        RHIdentity: {
          name: :'X-RH-IDENTITY',
          in: :header,
          type: :string,
          required: true
        },
        order: {
          name: :order,
          in: :query,
          type: :string,
          required: false,
          description: 'The ordering by which the returned collection should be sorted.'
        },
        limit: {
          name: :limit,
          in: :query,
          type: :integer,
          required: false,
          minimum: 0,
          default: 10,
          description: 'The maximum number of records to return.'
        },
        offset: {
          name: :offset,
          in: :query,
          type: :integer,
          required: false,
          minimum: 0,
          default: 0,
          description: 'The number of records to skip before returning.'
        }
      },
      definitions: {
        relationship: {
          type: :object,
          properties: {
            type: {
              type: :string,
              example: 'endpoint',
              description: 'Type of the related resource'
            },
            id: {
              type: :string,
              example: '5',
              description: 'Identifier of the related resource'
            }
          }
        },
        relationships: {
          type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                '$ref' => '#/definitions/relationship'
              }
            }
          }
        },
        endpoint: {
          type: :object,
          properties: {
            id: {
              type: :string,
              description: 'Identifier of the endpoint',
              example: '6'
            },
            type: {
              type: :string,
              description: 'Type of the returned record',
              example: 'endpoint',
              enum: %w[endpoint]
            },
            attributes: {
              type: :object,
              properties: {
                name: {
                  type: :string,
                  description: 'Human readable description of the endpoint',
                  example: 'An endpoint'
                },
                active: {
                  type: :boolean,
                  description: 'A flag determining whether this endpoint should be used'
                },
                url: {
                  type: :string,
                  description: 'URL to which messages should be POSTed',
                  example: 'https://devnull-as-a-service.com/dev/null'
                },
                last_delivery_status: {
                  # Type cannot be defined, because it conflicts with a possible nil
                  # type: :string,
                  description: 'Status of the last delivery',
                  enum: [Endpoint::STATUS_SUCCESS, Endpoint::STATUS_FAILURE, nil]
                },
                last_delivery_time: {
                  # type: :string,
                  description: 'Timestamp of last delivery attempt',
                  format: 'date-time'
                },
                last_failure_time: {
                  # type: :string,
                  description: 'Timestamp of first failure. If the status is "failure", ' \
                              'this marks when the endpoint "went down"',
                  format: 'date-time'
                }
              }
            }
          }
        },
        app: {
          type: :object,
          properties: {
            id: {
              type: :string,
              description: 'Identifier of the application',
              example: '6'
            },
            type: {
              type: :string,
              description: 'Type of the returned record',
              example: 'app'
            },
            attributes: {
              type: :object,
              properties: {
                name: {
                  type: :string,
                  description: 'Name of the application, used to identify the sender in messages',
                  example: 'webhooks'
                },
                title: {
                  type: :string,
                  description: 'Title of the application, shown to the user when configuring filters',
                  example: 'Webhooks - The service that allows you to hook into stuff'
                }
              }
            },
            relationships: {
              type: :object,
              properties: {
                event_types: {
                  '$ref' => '#/definitions/relationships'
                }
              }
            }
          }
        },
        event_type: {
          type: :object,
          properties: {
            id: {
              type: :string,
              description: 'Identifier of the event type',
              example: '6'
            },
            type: {
              type: :string,
              description: 'Type of the returned record',
              example: 'event_type',
              enum: %w[event_type]
            },
            attributes: {
              type: :object,
              properties: {
                name: {
                  type: :string,
                  description: 'Identifier of the event type, used to identify the event type in messages',
                  example: 'something'
                },
                title: {
                  type: :string,
                  description: 'Human readable description of the event type, ' \
                               'shown to the user when configuring filters',
                  example: 'Something interesting happened'
                }
              }
            },
            relationships: {
              type: :object,
              properties: {
                levels: {
                  '$ref' => '#/definitions/relationships'
                }
              }
            }
          }
        },
        level: {
          type: :object,
          properties: {
            id: {
              type: :string,
              description: 'Identifier of the level',
              example: '6'
            },
            type: {
              type: :string,
              description: 'Type of the returned record',
              example: 'level',
              enum: %w[level]
            },
            attributes: {
              type: :object,
              properties: {
                name: {
                  type: :string,
                  description: 'Identifier of the level, used to identify the level in messages',
                  example: 'low'
                },
                title: {
                  type: :string,
                  description: 'Human readable description of the level, ' \
                               'shown to the user when configuring filters',
                  example: 'Low severity'
                }
              }
            }
          }
        },
        metadata: {
          type: :object,
          properties: {
            total: {
              type: :integer,
              description: 'The total number of available records.',
              example: '100'
            },
            limit: {
              type: :integer,
              description: 'The maximum number of records to return.',
              example: '10'
            },
            offset: {
              type: :integer,
              description: 'The number of records to skip before returning.',
              example: '20'
            }
          }
        },
        links: {
          type: :object,
          properties: {
            first: {
              # type: :string,
              description: 'Link to the first page of records'
            },
            last: {
              # type: :string
              description: 'Link to the last page of records'
            },
            previous: {
              # type: :string
              description: 'Link to previous page of records, if such page exists'
            },
            next: {
              # type: :string
              description: 'Link to next page of records, if such page exists'
            }
          }
        }
      }
    }
  }
end
# rubocop:enable Metrics/BlockLength
