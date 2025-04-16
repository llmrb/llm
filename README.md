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

### Conversations

#### Completions

The following example enables lazy mode for a
[LLM::Conversation](https://0x1eef.github.io/x/llm/LLM/Conversation.html)
object by entering into a "lazy" conversation where messages are buffered and
sent to the provider only when necessary.  Both lazy and non-lazy conversations
maintain a message thread that can be reused as context throughout a conversation.
The example uses the stateless chat completions API that all LLM providers support:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
convo = LLM::Conversation.new(llm).lazy
convo.chat File.read("./share/llm/prompts/system.txt"), :system
convo.chat "Tell me the answer to 5 + 15", :user
convo.chat "Tell me the answer to (5 + 15) * 2", :user
convo.chat "Tell me the answer to ((5 + 15) * 2) / 10", :user
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

#### Responses

The responses API is a recent addition
[provided by OpenAI](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses)
that lets a client store message state on their servers &ndash; and in turn
a client can avoid maintaining state manually as well as avoid sending
the entire conversation with each request that is made. Although it is
primarily supported by OpenAI at the moment, we might see other providers
support it in the future. For now
[llm.rb supports the responses API](https://0x1eef.github.io/x/llm/LLM/OpenAI/Responses.html)
for the OpenAI provider:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
convo = LLM::Conversation.new(llm).lazy
convo.respond File.read("./share/llm/prompts/system.txt"), :developer
convo.respond "Tell me the answer to 5 + 15", :user
convo.respond "Tell me the answer to (5 + 15) * 2", :user
convo.respond "Tell me the answer to ((5 + 15) * 2) / 10", :user
convo.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

##
# [developer] You are my math assistant.
#             I will provide you with (simple) equations.
#             You will provide answers in the format "The answer to <equation> is <answer>".
#             I will provide you a set of messages. Reply to all of them.
#             A message is considered unanswered if there is no corresponding assistant response.
#
# [user] Tell me the answer to 5 + 15
# [user] Tell me the answer to (5 + 15) * 2
# [user] Tell me the answer to ((5 + 15) * 2) / 10
#
# [assistant] The answer to 5 + 15 is 20.
#             The answer to (5 + 15) * 2 is 40.
#             The answer to ((5 + 15) * 2) / 10 is 4.
```

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
which will go on to generate a response:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
res = llm.embed(["programming is fun", "ruby is a programming language", "sushi is art"])
print res.class, "\n"
print res.embeddings.size, "\n"
print res.embeddings[0].size, "\n"

##
# LLM::Response::Embedding
# 3
# 1536
```

## API reference

The README tries to provide a high-level overview of the library. For everything
else there's the API reference. It covers classes and methods that the README glances
over or doesn't cover at all. The API reference is available at
[0x1eef.github.io/x/llm](https://0x1eef.github.io/x/llm).


## Install

llm.rb can be installed via rubygems.org:

	gem install llm.rb

## License

MIT. See [LICENSE.txt](LICENSE.txt) for more details
