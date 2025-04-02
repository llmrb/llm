## About

llm.rb is a lightweight library that provides a common interface
and set of functionality for multiple Large Language Models (LLMs). It
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
method returns a lazy-variant of a
[LLM::Conversation](https://0x1eef.github.io/x/llm/LLM/Conversation.html)
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
convo = llm.chat File.read("./share/llm/prompts/system.txt"), :system
convo.chat "Tell me the answer to 5 + 15"
convo.chat "Tell me the answer to (5 + 15) * 2"
convo.chat "Tell me the answer to ((5 + 15) * 2) / 10"
convo.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

##
# [system] You are my math assistant.
#          I will provide you with (simple) equations.
#          You will provide answers in the format "The answer to <equation> is <answer>".
#          I will provide you a set of messages. Reply to all of them.
#          A message is considered unanswered if there is no corresponding assistant response.
#
# [user] Tell me the answer to 5 + 15
# [user] Tell me the answer to (5 + 15) * 2
# [user] Tell me the answer to ((5 + 15) * 2) / 10
#
# [assistant] The answer to 5 + 15 is 20.
#             The answer to (5 + 15) * 2 is 40.
#             The answer to ((5 + 15) * 2) / 10 is 4.
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
method generates a vector representation of one or more chunks
of text. Embeddings capture the semantic meaning of text &ndash;
a common use-case for them is to store chunks of text in a
vector database, and then to query the database for *semantically
similar* text. These chunks of similar text can then support the
generation of a prompt that is used to query a large language model,
which will go on to generate a response.

For example, a user query might find similar text that adds important
context to the prompt that informs the large language model in how to respond.
The chunks of text may also carry metadata that can be used to further filter
and contextualize the search results. This technique is popularly known as
retrieval-augmented generation (RAG). Embeddings can also be used for
other purposes as well &ndash; RAG is just one of the most popular use-cases.

Let's take a look at an example that generates a couple of vectors
for two chunks of text:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
res = llm.embed(["programming is fun", "ruby is a programming language"])
print res.class, "\n"
print res.embeddings.size, "\n"
print res.embeddings[0].size, "\n"

##
# LLM::Response::Embedding
# 2
# 1536
```

### LLM

#### Timeouts

When running the ollama provider locally it might take a while for
the language model to reply &ndash; depending on hardware and the
size of the model. The following example demonstrates how to wait
a longer period of time for a response through the use of the
`timeout` configuration option with the `qwq` model. The following
example waits up to 15 minutes for a response:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.ollama(nil, timeout: 60*15)
llm.chat "What is the meaning of life ?", model: "qwq"
llm.last_message.tap { print "[assistant] ", _1.content, "\n" }
```

#### Models

Generally each Large Language Model provides multiple models to choose
from, and each model has its own set of capabilities and limitations.
The following example demonstrates how to query the list of models
through the
[LLM::Provider#models](http://0x1eef.github.io/x/llm/LLM/Provider.html#models-instance_method)
method &ndash; the example happens to use the ollama provider but
this can be done for any provider:

```ruby
#!/usr/bin/env ruby
require "llm"

##
# List models
llm = LLM.ollama(nil)
llm.models.each { print "#{_2.name}: #{_2.description}", "\n" }

##
# Select a model
llm.chat "Hello, world!", model: llm.models["qwq"]

##
# This also works
llm.chat "Hello, world!", model: "qwq"
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

llm.rb can be installed via rubygems.org:

	gem install llm.rb

## License

MIT. See [LICENSE.txt](LICENSE.txt) for more details
