#!/opt/sensu-plugins-ruby/embedded/bin/ruby
require 'sensu-handler'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# Define class, get settings from config files and conf.d to set required variables for posting to Mattermost
class Show < Sensu::Handler
  def handle
    uri = URI.parse(ENV['URI'])
    username = ENV['USERNAME']
    icon_url = ENV['ICON_URL']

    # Case statement to detect Exit status code of alert
    # Exit status code indicates state

    case @event['check']['status']
      when 0
        status = ':sunglasses: OK :sunglasses:'
      when 1
        status = ':fearful: WARNING :fearful:'
      when 2
        status = ':scream: CRITICAL :scream:'
      else
        status = ':thinking: UNKNOWN :thinking:'
    end

    if (@event['check']['proxy_entity_name'] != "")
      host = @event['check']['proxy_entity_name']
    else
      host = @event['entity']['metadata']['name']
    end

    # Format Message displayed in mattermost and body of JSON sent to Mattermost.
    body = { text: "
  | entity  | #{host}                                 |
  |--------:|:----------------------------------------|
  | check   | #{@event['check']['metadata']['name']}  |
  | output  | #{@event['check']['output'].gsub("|"," ").gsub("\n"," ")} |
  | status  | #{status} |
", username: username , icon_url: icon_url}

    # HTTP POST Message to Mattermost.
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(
      uri.request_uri,
      'Content-Type' => 'application/json'
    )

    request.body = body.to_json

    response = https.request(request)
  end
end
