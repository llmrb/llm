## About

llm.rb is a lightweight library that provides a common interface
and set of functionality for multple Large Language Models (LLMs). It
is designed to be simple, flexible, and easy to use.

## Examples

### Providers

#### LLM::Provider

All providers inherit from [LLM::Provider](https://0x1eef.github.io/x/llm/LLM/Provider.html) &ndash;
they share a common interface and set of functionality. Each provider can be instantiated
using an API key (if required) and an optional set of configuration options via
[the singleton methods of LLM](https://0x1eef.github.io/x/llm/LLM.html). For example:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai("yourapikey")
llm = LLM.gemini("yourapikey")
llm = LLM.anthropic("yourapikey")
llm = LLM.ollama(nil)
```

### Completions

#### Conversation

The
[LLM::Provider#chat](https://0x1eef.github.io/x/llm/LLM/Provider.html#chat-instance_method)
method returns a
[LLM::LazyConversation](https://0x1eef.github.io/x/llm/LLM/LazyConversation.html)
object, and it allows for a "lazy" conversation where messages are batched and
sent to the provider only when necessary. The non-lazy counterpart is available via the
[LLM::Provider#chat!](https://0x1eef.github.io/x/llm/LLM/Provider.html#chat!-instance_method)
method.

Both lazy and non-lazy conversations maintain a message thread that can
be reused as context throughout a conversation. For the sake of brevity the system
prompt is loaded from
[a file](./share/llm/prompts/system.txt)
in the following example &ndash; all other prompts are "user" prompts &ndash;
and a single request is made to the provider when iterating over the messages
belonging to a lazy conversation:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
bot = llm.chat File.read("./share/llm/prompts/system.txt"), :system
bot.chat "What color is the sky?"
bot.chat "What color is an orange?"
bot.chat "I like Ruby"
bot.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

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
# [assistant] The sky is typically blue during the day. As for an orange,
#             it is usually orange in color—funny how that works, right?
#             I love Ruby too! Speaking of colors, why did the orange stop?
#             Because it ran out of juice! 🍊😂
```

#### Prompts

Both lazy and non-lazy conversations accept text as a prompt.
Depending on the provider, they may also accept a
[URI](https://docs.ruby-lang.org/en/master/URI.html)
or
[LLM::File](https://0x1eef.github.io/x/llm/LLM/File.html)
object. Generally a
[URI](https://docs.ruby-lang.org/en/master/URI.html)
object is used to reference an image on the web, and an
[LLM::File](https://0x1eef.github.io/x/llm/LLM/File.html)
object is used to reference a file on the local filesystem.
The following list shows the types of prompts that each
provider accepts:

* OpenAI &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; => &nbsp; String, URI
* Gemini &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; => &nbsp; String, LLM::File
* Anthropic &nbsp; => &nbsp; String, URI
* Ollama &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; => &nbsp; String, URI

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
#!/usr/bin/env ruby
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
