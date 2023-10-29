Gem::Specification.new do |s|
  s.name        = "tiny_chat_gpt"
  s.version     = "1.2.0"
  s.description = "a tiny ChatGPT client"
  s.summary     = "this library provides a ChatGPT client in Ruby that can be used to interact with ChatGPT programmatically"
  s.authors     = ["Jeff Lunt"]
  s.email       = "jefflunt@gmail.com"
  s.files       = ["lib/tiny_chat_gpt.rb"]
  s.homepage    = "https://github.com/jefflunt/tiny_chat_gpt"
  s.license     = "MIT"

  s.add_runtime_dependency 'tiny_color', [">= 0"]
  s.add_runtime_dependency 'tty-markdown', [">= 0"]
end
