## Streaming

### Contents

* [API](#api)
  * [Introduction](#introduction)
  * [Flexibility](#flexibility)

### API

#### Introduction

The streaming API can be useful in case you want to see the contents
of a message as it is generated, or in case you want to avoid potential
read timeouts during the generation of a response.

The `stream` option can be set to an IO object, or the value `true`
to enable streaming &ndash; and at the end of the request, `bot.chat`
returns the same response as the non-streaming version which allows
you to process a response in the same way:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)
bot.chat(stream: $stdout) do |prompt|
  prompt.system "You are my math assistant."
  prompt.user "Tell me the answer to 5 + 15"
  prompt.user "Tell me the answer to (5 + 15) * 2"
  prompt.user "Tell me the answer to ((5 + 15) * 2) / 10"
end.to_a
```

#### Flexibility

* **Conversation-level** <br>
There are three different ways to use the streaming API. It can be
configured for the length of a conversation by passing the `stream`
through [`LLM::Bot#initialize`](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#initialize-instance_method):
```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm, stream: $stdout)
```

* **Block-level** <br>
The streaming API can be enabled for the duration of a block given to the
[`LLM::Bot#chat`](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#chat-instance_method)
method by passing the `stream` option to the
[chat](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#chat-instance_method)
method:
```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)
bot.chat(stream: $stdout) do |prompt|
  prompt.system "You are my math assistant."
  # ..
end
```

* **Single request** <br>
The streaming API can also be enabled for a single request by passing the
`stream` option to the [chat](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#chat-instance_method)
method without a block:
```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)
bot.chat "You are my math assistant.", role: :system, stream: $stdout
```
