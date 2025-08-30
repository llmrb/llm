## Streaming

### Contents

* [Introduction](#introduction)
* [Scopes](#scopes)

#### Introduction

The streaming API can be useful when you want to stream a
conversation in real time, or when you want to avoid potential
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

#### Scopes

* **Conversation-level** <br>
There are three different ways to use the streaming API. It can be
configured for the length of a conversation by passing the `stream`
through [`LLM::Bot#initialize`](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#initialize-instance_method).
Note that in this case, we call
[`LLM::Buffer#drain`](https://0x1eef.github.io/x/llm.rb/LLM/Buffer.html#drain-instance_method)
to start the request:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm, stream: $stdout)
bot.chat "Hello", role: :user
bot.messages.drain
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
  prompt.user "Tell me the answer to 5 + 15"
end.to_a
```

* **Single request** <br>
The streaming API can also be enabled for a single request by passing the
`stream` option to the [chat](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#chat-instance_method)
method without a block. Note that in this case, we call
[`LLM::Buffer#drain`](https://0x1eef.github.io/x/llm.rb/LLM/Buffer.html#drain-instance_method)
to start the request:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)
bot.chat "You are my math assistant.", role: :system, stream: $stdout
bot.chat "Tell me the answer to 5 + 15", role: :user
bot.messages.drain
```
