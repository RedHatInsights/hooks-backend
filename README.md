# README

## Architecture

This is a microservice responsible for dispatching preformatted notifications to
different _endpoints_.

### Components

*Message*: A JSON payload with predefined fields: `Application`, `Event type`,
`Severity`, `Message` and `Timestamp`.

*Dispatcher*: Component that is responsible for receiving incoming _messages_ and
deciding (based on _filters_) which _endpoint_ should receive the message.

*Filter*: A combination of `Application`, `Event type` and `Severity` sets that
will be compared against the _message_ received. Once there is a match,
_endpoints_ associated with this filter record would be triggered.

*Endpoint*: A set of properties that would be enough to initiate a web request
to a URL (which is also part of the properties) of a notification service. Good
examples for such services would be slack, sms senders e.t.c.

### Basic flow
The process starts when a message arrives on `notifications.outbox` Kafka topic.
This message is passed to a *dispatcher*.

Dispatcher is responsible to find out
which _endpoints_ should be triggered. Once the _endpoints_ were identified,
an ActiveJob is fired for each _endpoint_ with details of the message to
send and _endpoint_ properties.

The job is responsible to initiate a web request with _endpoint_'s details,
format the _message_ to fit into _endpoint_'s API and make sure the message has
arrived to the recipient (_endpoint_).
