require 'json'
require 'net/http'

# the TinyChatGPT class is an API adapter for OpenAI's GPT-3 based ChatGPT
# model.  this class makes it easy to send prompts to the ChatGPT API and
# receive responses.
#
# usage:
#   chatbot = ChatGPT.new("davinci", "your_api_key")
#   puts chatbot.ask("Hello, how are you today?")
#
# if there is any non-200 HTTP response from the API then an instance of
# TinyChatGpt::APIError will be raised with a helpful error message.
#
# NOTE: this version does not maintain any context from one prompt to the next,
# so having a longer conversation with ChatGPT via this client is not yet
# supported. every use of the #ask method is sent as a separate API request,
# and does not include the context of previous prompts and replies. I do expect
# to add conversation support in the future, assuming the ChatGPT API endpoints
# support it (as of Feb. 2023 we're still waiting for the ChatGPT API to open up
# to the broader tech community).
class TinyChatGpt
  API_URL = "https://api.openai.com/v1/engines/davinci/jobs".freeze

  def initialize(model, api_key)
    @model = model
    @api_key = api_key
  end

  def ask(prompt)
    request = {
      prompt: prompt,
      max_tokens: 100,
      n: 1,
      stop: "",
      temperature: 0.5,
      model: @model
    }
    response = _send_request(request)

    if response.code == 200
      _parse_response(response)
    else
      raise TinyChatGpt::APIError.new("ERR: non-200 HTTP status to ChatGPT: #{response.code}")
    end
  end

  def _send_request(request)
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.basic_auth(@api_key, '')
    request.body = request.to_json
    http.request(request)
  end

  def _parse_response(response)
    response = JSON.parse(response)
    response["choices"].first["text"]
  end
end

class TinyChatGpt::APIError < RuntimeError; end
