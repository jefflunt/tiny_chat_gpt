require 'json'
require 'uri'
require 'net/http'
require 'tiny_color'
require 'tty-markdown'

# TinyChatGpt provides an interface to OpenAI GPT API - every instance of this
# class starts a new conversation, which is necessary in order to carry on a
# conversation.
#
# usage:
#
#   api_key = 'your_api_key'
#   model = TinyChatGpt::MODEL_3_5_TURBO
#   chat = TinyChatGpt.new(model, api_key)
#   response = chat.prompt('Hello, how are you?')
#   puts response
class TinyChatGpt
  URI = URI('https://api.openai.com/v1/chat/completions')
  MODEL_3_5_TURBO = 'gpt-3.5-turbo'
  MODEL_4 = 'gpt-4-0613'

  attr_reader :prompt_tokens,
              :completion_tokens

  def initialize(model, api_key)
    @model = model
    @api_key = api_key
    @msgs = []

    @prompt_tokens = 0
    @completion_tokens = 0
  end

  def total_tokens
    prompt_tokens + completion_tokens
  end

  def prompt(prompt)
    @msgs << {
      role: 'user',
      content: prompt
    }

    request = {
      model: @model,
      messages: @msgs
    }

    response = _send_request(request)

    if response.code == '200'
      resp = _parse_ok(response)
      completion = resp["choices"].first.dig('message', 'content')
      @msgs << {
        role: 'assistant',
        content: completion
      }

      @prompt_tokens += resp.dig('usage', 'prompt_tokens')
      @completion_tokens += resp.dig('usage', 'completion_tokens')

      TTY::Markdown.parse(completion)
    else
      "#{'ERR'.light_red}: HTTP status code #{response.code}, #{_parse_error(response)}"
    end
  end

  def _send_request(request)
    Net::HTTP.post(
      URI,
      request.to_json,
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{KEY}"
      }
    )
  end

  def _parse_ok(response)
    JSON.parse(response.body)
  end

  def _parse_error(response)
    JSON
      .parse(response.body)
      .dig('error', 'message')
  end
end

class TinyChatGpt::APIError < RuntimeError; end
