## About

A lightweight Ruby library for interacting with multiple LLM providers

## Examples

### Providers

#### LLM::Provider

All providers inherit from [`LLM::Provider`](https://0x1eef.github.io/x/llm/LLM/Provider.html) &ndash;
they share a common interface and set of functionality. Each provider can be instantiated
using an API key (if required) and an optional set of configuration options via
[the singleton methods of LLM](https://0x1eef.github.io/x/llm/LLM.html). For example:

```ruby
require "llm"
llm = LLM.openai("yourapikey")
llm = LLM.anthropic("yourapikey")
llm = LLM.ollama(nil)
```

### Completions

#### Conversation

The
[`LLM::Provider#chat`](https://0x1eef.github.io/x/llm/LLM/Provider.html#chat-instance_method)
method returns a
[`LLM::LazyConversation`](https://0x1eef.github.io/x/llm/LLM/LazyConversation.html)
object, and it allows for a "lazy" conversation where messages are batched and
sent to the provider only when necessary. The non-lazy counterpart is available via
[`LLM::Provider#chat!`](https://0x1eef.github.io/x/llm/LLM/Provider.html#chat!-instance_method).
Both lazy and non-lazy conversations maintain a message thread that can be reused 
as context throughout the conversation:

```ruby
require "llm"
llm = LLM.openai(ENV["KEY"])
bot = llm.chat(<<~SYSTEM, :system)
You are a friendly chatbot. Sometimes, you like to tell a joke.
But the joke must be based on the given inputs.

I will provide you a set of messages. Reply to all of them.
A message is considered unanswered if there is no corresponding assistant response.
SYSTEM
bot.chat "What color is the sky?"
bot.chat "What color is an orange?"
bot.chat "I like Ruby"
bot.messages.each do |message|
  # At this point a single request is made to the provider
  # See 'LLM::MessageQueue' for more details
  print "[#{message.role}] ", message.content, "\n"
end

##
# [system] You are a friendly chatbot. Sometimes, you like to tell a joke.
#          But the joke must be based on the given inputs.
#          I will provide you a set of messages. Reply to all of them.
#          A message is considered unanswered if there is no corresponding assistant response.
#
# [user] What color is the sky?
# [user] What color is an orange?
# [user] I like Ruby
#
# [assistant] The sky is typically blue during the day, but it can have beautiful
#             hues of pink, orange, and purple during sunset! As for an orange,
#             it is usually orange in color—funny how that works, right?
#             I love Ruby too! Did you know that a Ruby is not only a beautiful
#             gemstone but also a programming language? So, you could say it's both
#             precious and powerful! Speaking of colors, why did the orange stop?
#             Because it ran out of juice! 🍊😂
```

### Embeddings

#### Text

The
[`LLM::Provider#embed`](https://0x1eef.github.io/x/llm/LLM/Provider.html#embed-instance_method)
method generates a vector representation of a given piece of text.
Embeddings capture the semantic meaning of text, and they are
commonly used in tasks such as text similarity comparison (e.g., finding related documents),
semantic search in vector databases, and the clustering and classification
of text-based data:

```ruby
require "llm"
llm = LLM.openai(ENV["KEY"])
res = llm.embed("Hello, world!")
print res.class, "\n"
print res.embeddings.size, "\n"
print res.embeddings[0].size, "\n"

##
# LLM::Response::Embedding
# 1
# 1536
```

## Providers

- [x] [Anthropic](https://www.anthropic.com/)
- [x] [OpenAI](https://platform.openai.com/docs/overview)
- [x] [Gemini](https://ai.google.dev/gemini-api/docs)
- [x] [Ollama](https://github.com/ollama/ollama#readme)
- [ ] Hugging Face
- [ ] Cohere
- [ ] AI21 Labs
- [ ] Replicate
- [ ] Mistral AI

## Documentation

A complete API reference is available at [0x1eef.github.io/x/llm](https://0x1eef.github.io/x/llm)

## Install

LLM has not been published to RubyGems.org yet. Stay tuned

## License

MIT. See [LICENSE.txt](LICENSE.txt) for more details
