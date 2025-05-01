## About

llm.rb is a lightweight library that provides a common interface
and set of functionality for multiple Large Language Models (LLMs). It
is designed to be simple, flexible, and easy to use &ndash; and it has been
implemented with zero dependencies outside Ruby's standard library. See the
[philosophy](#philosophy) section for more information on the design principles
behind llm.rb.

## Examples

### Providers

#### LLM::Provider

All providers inherit from [LLM::Provider](https://0x1eef.github.io/x/llm.rb/LLM/Provider.html) &ndash;
they share a common interface and set of functionality. Each provider can be instantiated
using an API key (if required) and an optional set of configuration options via
[the singleton methods of LLM](https://0x1eef.github.io/x/llm.rb/LLM.html). For example:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai("yourapikey")
llm = LLM.gemini("yourapikey")
llm = LLM.anthropic("yourapikey")
llm = LLM.ollama(nil)
llm = LLM.voyageai("yourapikey")
```

### Conversations

#### Completions

The following example enables lazy mode for a
[LLM::Chat](https://0x1eef.github.io/x/llm.rb/LLM/Chat.html)
object by entering into a "lazy" conversation where messages are buffered and
sent to the provider only when necessary.  Both lazy and non-lazy conversations
maintain a message thread that can be reused as context throughout a conversation.
The example captures the spirit of llm.rb by demonstrating how objects cooperate
together through composition, and it uses the stateless chat completions API that
all LLM providers support:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
bot = LLM::Chat.new(llm).lazy
bot.chat File.read("./share/llm/prompts/system.txt"), :system
bot.chat "Tell me the answer to 5 + 15", :user
bot.chat "Tell me the answer to (5 + 15) * 2", :user
bot.chat "Tell me the answer to ((5 + 15) * 2) / 10", :user
bot.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

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
[llm.rb supports the responses API](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Responses.html)
for the OpenAI provider:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
bot = LLM::Chat.new(llm).lazy
bot.respond File.read("./share/llm/prompts/system.txt"), :developer
bot.respond "Tell me the answer to 5 + 15", :user
bot.respond "Tell me the answer to (5 + 15) * 2", :user
bot.respond "Tell me the answer to ((5 + 15) * 2) / 10", :user
bot.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

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

### Schema

#### Structured

All LLM providers except Anthropic allow a client to describe the structure
of a response that a LLM emits according to a schema that is described by JSON.
The schema lets a client describe what JSON object (or value) an LLM should emit,
and the LLM will abide by the schema. See also: [JSON Schema website](https://json-schema.org/overview/what-is-jsonschema).

True to the llm.rb spirit of doing one thing well, and solving problems through the
composition of objects, the generation of a schema is delegated to another object
who is responsible for and an expert in the generation of JSON schemas. We will use
the
[llmrb/json-schema](https://github.com/llmrb/json-schema)
library  for the sake of the examples - it is an optional dependency that is loaded
on-demand. At least for the time being it is not necessary to install it separately.
The interface is designed so you could drop in any other library in its place:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
schema = llm.schema.object({os: llm.schema.string.enum("OpenBSD", "FreeBSD", "NetBSD")})
bot = LLM::Chat.new(llm, schema:)
bot.chat "You secretly love NetBSD", :system
bot.chat "What operating system is the best?", :user
bot.messages.find(&:assistant?).content! # => {os: "NetBSD"}

schema = llm.schema.object({answer: llm.schema.integer.required})
bot = LLM::Chat.new(llm, schema:)
bot.chat "Tell me the answer to ((5 + 5) / 2)", :user
bot.messages.find(&:assistant?).content! # => {answer: 5}

schema = llm.schema.object({probability: llm.schema.number.required})
bot = LLM::Chat.new(llm, schema:)
bot.chat "Does the earth orbit the sun?", :user
bot.messages.find(&:assistant?).content! # => {probability: 1}
```

### Tools

#### Functions

The OpenAI provider supports a powerful feature known as tool calling,
and although it is a little complex to understand at first, it can be
powerful for building agents. The following example demonstrates how we
can define a local function (which happens to be a tool), and OpenAI can
then detect when we should call the function. The following example
defines an agent that can run system commands based on natural language:


```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
tool = LLM.function(:system) do |fn|
  fn.description "Run a shell command"
  fn.params do |schema|
    schema.object(command: schema.string.required)
  end
  fn.define do |params|
    system(params.command)
  end
end

bot = LLM::Chat.new(llm, tools: [tool]).lazy
bot.chat "You are a shell command executor. You will run shell commands.", :system
bot.chat "What is the current date?", :user
bot.last_message.functions.each(&:call)
bot.chat "What operating system am I running? (short version please!)", :user
bot.last_message.functions.each(&:call)

##
# Thu May  1 10:01:02 UTC 2025
# FreeBSD
```

### Audio

#### Speech

Some but not all providers implement audio generation capabilities that
can create speech from text, transcribe audio to text, or translate
audio to text (usually English). The following example uses the OpenAI provider
to create an audio file from a text prompt. The audio is then moved to
`${HOME}/hello.mp3` as the final step. As always, consult the provider's
documentation for more information on how to use the audio generation API:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
res = llm.audio.create_speech(input: "Hello world")
IO.copy_stream res.audio, File.join(Dir.home, "hello.mp3")
```

#### Transcribe

The following example transcribes an audio file to text. The audio file
(`${HOME}/hello.mp3`) was theoretically created in the previous example,
and the result is printed to the console. The example uses the OpenAI
provider to transcribe the audio file. As always, consult the provider's
documentation for more information on how to use the audio transcription API:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
res = llm.audio.create_transcription(
  file: LLM::File(File.join(Dir.home, "hello.mp3"))
)
print res.text, "\n" # => "Hello world."
```

#### Translate

The following example translates an audio file to text. In this example
the audio file (`${HOME}/bomdia.mp3`) is theoretically in Portuguese,
and it is translated to English. The example uses the OpenAI provider,
and at the time of writing, it can only translate to English. As always,
consult the provider's documentation for more information on how to use 
the audio translation API:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
res = llm.audio.create_translation(
  file: LLM::File(File.join(Dir.home, "bomdia.mp3"))
)
print res.text, "\n" # => "Good morning."
```

### Images

#### Create

Some but not all LLM providers implement image generation capabilities that
can create new images from a prompt, or edit an existing image with a
prompt. The following example uses the OpenAI provider to create an
image of a dog on a rocket to the moon. The image is then moved to
`${HOME}/dogonrocket.png` as the final step:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(ENV["KEY"])
res = llm.images.create(prompt: "a dog on a rocket to the moon")
res.urls.each do |url|
  FileUtils.mv OpenURI.open_uri(url).path,
               File.join(Dir.home, "dogonrocket.png")
end
```

#### Edit

The following example is focused on editing a local image with the aid
of a prompt. The image (`/images/cat.png`) is returned to us with the cat
now wearing a hat. The image is then moved to `${HOME}/catwithhat.png` as
the final step.

Results and quality may vary, consider prompt adjustments if the results
are not as expected, and consult the provider's documentation
for more information on how to use the image editing API:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(ENV["KEY"])
res = llm.images.edit(
  image: LLM::File("/images/cat.png"),
  prompt: "a cat with a hat",
)
res.urls.each do |url|
  FileUtils.mv OpenURI.open_uri(url).path,
               File.join(Dir.home, "catwithhat.png")
end
```

#### Variations

The following example is focused on creating variations of a local image.
The image (`/images/cat.png`) is returned to us with five different variations.
The images are then moved to `${HOME}/catvariation0.png`, `${HOME}/catvariation1.png`
and so on as the final step. Consult the provider's documentation for more information
on how to use the image variations API:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(ENV["KEY"])
res = llm.images.create_variation(
  image: LLM::File("/images/cat.png"),
  n: 5
)
res.urls.each.with_index do |url, index|
  FileUtils.mv OpenURI.open_uri(url).path,
               File.join(Dir.home, "catvariation#{index}.png")
end
```

### Files

#### Create

Most LLM providers provide a Files API where you can upload files
that can be referenced from a prompt and llm.rb has first-class support
for this feature. The following example uses the OpenAI provider to describe
the contents of a PDF file after it has been uploaded. The file (an instance
of [LLM::Response::File](https://0x1eef.github.io/x/llm.rb/LLM/Response/File.html))
is passed directly to the chat method, and generally any object a prompt supports
can be given to the chat method:


```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
bot = LLM::Chat.new(llm).lazy
file = llm.files.create(file: LLM::File("/documents/openbsd_is_awesome.pdf"))
bot.chat(file)
bot.chat("What is this file about?")
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

##
# [assistant] This file is about OpenBSD, a free and open-source Unix-like operating system
#             based on the Berkeley Software Distribution (BSD). It is known for its
#             emphasis on security, code correctness, and code simplicity. The file
#             contains information about the features, installation, and usage of OpenBSD.
```

### Prompts

#### Multimodal

Generally all providers accept text prompts but some providers can
also understand URLs, and various file types (eg images, audio, video,
etc). The llm.rb approach to multimodal prompts is to let you pass `URI`
objects to describe links, `LLM::File` | `LLM::Response::File` objects
to describe files, `String` objects to describe text blobs, or an array
of the aforementioned objects to describe multiple objects in a single
prompt. Each object is a first class citizen that can be passed directly
to a prompt:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
bot = LLM::Chat.new(llm).lazy

bot.chat URI("https://example.com/path/to/image.png")
bot.chat "Describe the above image"
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

file = bot.files.create(file: LLM::File("/documents/openbsd_is_awesome.pdf"))
bot.chat file
bot.chat "What is this file about?"
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

bot.chat [LLM::File("/images/puffy.png"), "What is this image about?"]
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

bot.chat [LLM::File("/images/beastie.png"), "What is this image about?"]
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }
```

### Embeddings

#### Text

The
[`LLM::Provider#embed`](https://0x1eef.github.io/x/llm.rb/LLM/Provider.html#embed-instance_method)
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

### Models

#### List

Almost all LLM providers provide a models endpoint that allows a client to
query the list of models that are available to use. The list is dynamic,
maintained by LLM providers, and it is independent of a specific llm.rb release.
True to the llm.rb spirit of small, composable objects that cooperate with
each other, a
[LLM::Model](https://0x1eef.github.io/x/llm.rb/LLM/Model.html)
object can be used instead of a string that describes a model name (although
either works). Let's take a look at an example:

```ruby
#!/usr/bin/env ruby
require "llm"

##
# List all models
llm = LLM.openai(ENV["KEY"])
llm.models.all.each do |model|
  print "model: ", model.id, "\n"
end

##
# Select a model
model = llm.models.all.find { |m| m.id == "gpt-3.5-turbo" }
bot = LLM::Chat.new(llm, model:)
bot.chat "Hello #{model.id} :)"
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }
```

### Memory

#### Child process

When it comes to the generation of audio, images, and video memory consumption
can be a potential problem. There are a few strategies in place to deal with this,
and one lesser known strategy is to let a child process handle the memory cost
by delegating media generation to a child process.

Once a child process exits, any memory it had used is freed immediately and
the parent process can continue to have a small memory footprint. In a sense
it is similar to being able to use malloc + free from Ruby. The following example
demonstrates how that might look like in practice:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.gemini(ENV["KEY"])
fork do
  %w[dog cat sheep goat capybara].each do |animal|
    res = llm.images.create(prompt: "a #{animal} on a rocket to the moon")
    IO.copy_stream res.images[0], "#{animal}.png"
  end
end
Process.wait
```

## API reference

The README tries to provide a high-level overview of the library. For everything
else there's the API reference. It covers classes and methods that the README glances
over or doesn't cover at all. The API reference is available at
[0x1eef.github.io/x/llm.rb](https://0x1eef.github.io/x/llm.rb).


### See also

#### Gemini

* [LLM::Gemini](https://0x1eef.github.io/x/llm.rb/LLM/Gemini.html)
* [LLM::Gemini::Images](https://0x1eef.github.io/x/llm.rb/LLM/Gemini/Images.html)
* [LLM::Gemini::Audio](https://0x1eef.github.io/x/llm.rb/LLM/Gemini/Audio.html)

#### OpenAI

* [LLM::OpenAI](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI.html)
* [LLM::OpenAI::Images](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Images.html)
* [LLM::OpenAI::Audio](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Audio.html)

#### Anthropic
* [LLM::Anthropic](https://0x1eef.github.io/x/llm.rb/LLM/Anthropic.html)

#### Ollama
* [LLM::Ollama](https://0x1eef.github.io/x/llm.rb/LLM/Ollama.html)

## Install

llm.rb can be installed via rubygems.org:

	gem install llm.rb

## Philosophy

llm.rb was built for developers who believe that simplicity can be challenging
but it is always worth it. It provides a clean, dependency-free interface to
Large Language Models, treating Ruby itself as the primary platform &ndash;
not Rails or any other specific framework or library. There is no hidden
magic or complex metaprogramming.

Every part of llm.rb is designed to be explicit, composable, memory-safe,
and production-ready without compromise. No unnecessary abstractions,
no global configuration, no global state, and no dependencies that aren't
part of standard Ruby. It has been inspired in part by other languages such
as Python, but it is not a port of any other library.

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
