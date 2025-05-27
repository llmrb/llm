## About

llm.rb is a zero-dependency Ruby toolkit for Large Language Models that
includes OpenAI, Gemini, Anthropic, DeepSeek, Ollama, and LlamaCpp.
It's fast, simple and composable – with full support for chat,
streaming, tool calling, audio, images, files, and JSON Schema
generation.

## Features

#### General
- ✅ A single unified interface for multiple providers
- 📦 Zero dependencies outside Ruby's standard library
- 🚀 Optimized for performance and low memory usage

#### Chat, Agents
- 🧠 Stateless and stateful chat via completions and responses API
- 🤖 Tool calling and function execution
- 🗂️ JSON Schema support for structured, validated responses
- 📡 Streaming support for real-time response updates

#### Media
- 🗣️ Text-to-speech, transcription, and translation
- 🖼️ Image generation, editing, and variation support
- 📎 File uploads and prompt-aware file interaction
- 💡 Multimodal prompts (text, images, PDFs, URLs, files)

#### Miscellaneous
- 🧮 Text embeddings and vector support
- 🔌 Retrieve models dynamically for introspection and selection

## Demos

<details>
  <summary><b>1. Tools: "system" function</b></summary>
  <img src="https://github.com/llmrb/llm/raw/main/share/llm-shell/examples/toolcalls.gif">
</details>

<details>
  <summary><b>2. Files: import at runtime</b></summary>
  <img src="https://github.com/llmrb/llm/raw/main/share/llm-shell/examples/files-runtime.gif">
</details>

<details>
  <summary><b>3. Files: import at boot time</b></summary>
  <img src="https://github.com/llmrb/llm/raw/main/share/llm-shell/examples/files-boottime.gif">
</details>

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

##
# remote providers
llm = LLM.openai(key: "yourapikey")
llm = LLM.gemini(key: "yourapikey")
llm = LLM.anthropic(key: "yourapikey")
llm = LLM.deepseek(key: "yourapikey")
llm = LLM.voyageai(key: "yourapikey")

##
# local providers
llm = LLM.ollama(key: nil)
llm = LLM.llamacpp(key: nil)
```

### Conversations

#### Completions

> This example uses the stateless chat completions API that all
> providers support. A similar example for OpenAI's stateful
> responses API is available in the [docs/](docs/OPENAI.md#responses)
> directory.

The following example enables lazy mode for an instance of
[LLM::Bot](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html)
by entering into a conversation where messages are buffered and
sent to the provider on-demand. Both lazy and non-lazy conversations
maintain a message thread that can be reused as context throughout
a conversation. The example uses the stateless chat completions API
that all LLM providers support:

```ruby
#!/usr/bin/env ruby
require "llm"

llm  = LLM.openai(key: ENV["KEY"])
bot  = LLM::Bot.new(llm).lazy
msgs = bot.chat do |prompt|
  prompt.system File.read("./share/llm/prompts/system.txt")
  prompt.user "Tell me the answer to 5 + 15"
  prompt.user "Tell me the answer to (5 + 15) * 2"
  prompt.user "Tell me the answer to ((5 + 15) * 2) / 10"
end

# At this point, we execute a single request
msgs.each { print "[#{_1.role}] ", _1.content, "\n" }
```

#### Streaming

The following example streams the messages in a conversation
as they are generated in real-time. This feature can be useful
in case you want to see the contents of a message as it is
generated, or in case you want to avoid potential read timeouts
during the generation of a response.

The `stream` option can be set to an IO object, or the value `true`
to enable streaming &ndash; and at the end of the request, `bot.chat`
returns the same response as the non-streaming version which allows
you to process a response in the same way:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm).lazy
bot.chat(stream: $stdout) do |prompt|
  prompt.system "You are my math assistant."
  prompt.user "Tell me the answer to 5 + 15"
  prompt.user "Tell me the answer to (5 + 15) * 2"
  prompt.user "Tell me the answer to ((5 + 15) * 2) / 10"
end.to_a
```

### Schema

#### Structured

All LLM providers except Anthropic and DeepSeek allow a client to describe
the structure of a response that a LLM emits according to a schema that is
described by JSON. The schema lets a client describe what JSON object (or value)
an LLM should emit, and the LLM will abide by the schema.
See also: [JSON Schema website](https://json-schema.org/overview/what-is-jsonschema).
We will use the
[llmrb/json-schema](https://github.com/llmrb/json-schema)
library for the sake of the examples &ndash; the interface is designed so you
could drop in any other library in its place:

```ruby
#!/usr/bin/env ruby
require "llm"

##
# Objects
llm = LLM.openai(key: ENV["KEY"])
schema = llm.schema.object(answer: llm.schema.integer.required)
bot = LLM::Bot.new(llm, schema:).lazy
bot.chat "Does the earth orbit the sun?", role: :user
bot.messages.find(&:assistant?).content! # => {probability: 1}

##
# Enums
schema = llm.schema.object(fruit: llm.schema.string.enum("Apple", "Orange", "Pineapple"))
bot = LLM::Bot.new(llm, schema:).lazy
bot.chat "Your favorite fruit is Pineapple", role: :system
bot.chat "What fruit is your favorite?", role: :user
bot.messages.find(&:assistant?).content! # => {fruit: "Pineapple"}

##
# Arrays
schema = llm.schema.object(answers: llm.schema.array(llm.schema.integer.required))
bot = LLM::Bot.new(llm, schema:).lazy
bot.chat "Answer all of my questions", role: :system
bot.chat "Tell me the answer to ((5 + 5) / 2)", role: :user
bot.chat "Tell me the answer to ((5 + 5) / 2) * 2", role: :user
bot.chat "Tell me the answer to ((5 + 5) / 2) * 2 + 1", role: :user
bot.messages.find(&:assistant?).content! # => {answers: [5, 10, 11]}
```

### Tools

#### Functions

All providers support a powerful feature known as tool calling, and although
it is a little complex to understand at first, it can be powerful for building
agents. The following example demonstrates how we can define a local function
(which happens to be a tool), and a provider (such as OpenAI) can then detect
when we should call the function.

The
[LLM::Bot#functions](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#functions-instance_method)
method returns an array of functions that can be called after sending a message and
it will only be populated if the LLM detects a function should be called. Each function
corresponds to an element in the "tools" array. The array is emptied after a function call,
and potentially repopulated on the next message.

The following example defines an agent that can run system commands based on natural language,
and it is only intended to be a fun demo of tool calling - it is not recommended to run
arbitrary commands from a LLM without sanitizing the input first :) Without further ado:

```ruby
#!/usr/bin/env ruby
require "llm"

llm  = LLM.openai(key: ENV["KEY"])
tool = LLM.function(:system) do |fn|
  fn.description "Run a shell command"
  fn.params do |schema|
    schema.object(command: schema.string.required)
  end
  fn.define do |params|
    ro, wo = IO.pipe
    re, we = IO.pipe
    Process.wait Process.spawn(params.command, out: wo, err: we)
    [wo,we].each(&:close)
    {stderr: re.read, stdout: ro.read}
  end
end

bot = LLM::Bot.new(llm, tools: [tool]).lazy
bot.chat "Your task is to run shell commands via a tool.", role: :system

bot.chat "What is the current date?", role: :user
bot.chat bot.functions.map(&:call) # report return value to the LLM

bot.chat "What operating system am I running? (short version please!)", role: :user
bot.chat bot.functions.map(&:call) # report return value to the LLM

##
# {stderr: "", stdout: "Thu May  1 10:01:02 UTC 2025"}
# {stderr: "", stdout: "FreeBSD"}
```

### Audio

#### Speech

Some but not all providers implement audio generation capabilities that
can create speech from text, transcribe audio to text, or translate
audio to text (usually English). The following example uses the OpenAI provider
to create an audio file from a text prompt. The audio is then moved to
`${HOME}/hello.mp3` as the final step:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
res = llm.audio.create_speech(input: "Hello world")
IO.copy_stream res.audio, File.join(Dir.home, "hello.mp3")
```

#### Transcribe

The following example transcribes an audio file to text. The audio file
(`${HOME}/hello.mp3`) was theoretically created in the previous example,
and the result is printed to the console. The example uses the OpenAI
provider to transcribe the audio file:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
res = llm.audio.create_transcription(
  file: File.join(Dir.home, "hello.mp3")
)
print res.text, "\n" # => "Hello world."
```

#### Translate

The following example translates an audio file to text. In this example
the audio file (`${HOME}/bomdia.mp3`) is theoretically in Portuguese,
and it is translated to English. The example uses the OpenAI provider,
and at the time of writing, it can only translate to English:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
res = llm.audio.create_translation(
  file: File.join(Dir.home, "bomdia.mp3")
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

llm = LLM.openai(key: ENV["KEY"])
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
the final step:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(key: ENV["KEY"])
res = llm.images.edit(
  image: "/images/cat.png",
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
and so on as the final step:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(key: ENV["KEY"])
res = llm.images.create_variation(
  image: "/images/cat.png",
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

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm).lazy
file = llm.files.create(file: "/documents/openbsd_is_awesome.pdf")
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

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm).lazy

bot.chat [URI("https://example.com/path/to/image.png"), "Describe the image in the link"]
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

file = llm.files.create(file: "/documents/openbsd_is_awesome.pdf")
bot.chat [file, "What is this file about?"]
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

bot.chat [LLM.File("/images/puffy.png"), "What is this image about?"]
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }

bot.chat [LLM.File("/images/beastie.png"), "What is this image about?"]
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

llm = LLM.openai(key: ENV["KEY"])
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
[LLM::Model](https://0x1eef.github.io/x/llm.rb/LLM/Model.html)
objects can be used instead of a string that describes a model name (although
either works). Let's take a look at an example:

```ruby
#!/usr/bin/env ruby
require "llm"

##
# List all models
llm = LLM.openai(key: ENV["KEY"])
llm.models.all.each do |model|
  print "model: ", model.id, "\n"
end

##
# Select a model
model = llm.models.all.find { |m| m.id == "gpt-3.5-turbo" }
bot = LLM::Bot.new(llm, model:)
bot.chat "Hello #{model.id} :)"
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }
```

## Documentation

### API

The README tries to provide a high-level overview of the library. For everything
else there's the API reference. It covers classes and methods that the README glances
over or doesn't cover at all. The API reference is available at
[0x1eef.github.io/x/llm.rb](https://0x1eef.github.io/x/llm.rb).


### Guides

The [docs/](docs/) directory contains some additional documentation that
didn't quite make it into the README. It covers the design guidelines that
the library follows, some strategies for memory management, and other
provider-specific features.

## See also

**[llmrb/llm-shell](https://github.com/llmrb/llm-shell)**

An extensible, developer-oriented command line utility that is powered by
llm.rb and serves as a demonstration of the library's capabilities. The
[demo](https://github.com/llmrb/llm-shell#demos) section has a number of GIF
previews might be especially interesting.

## Install

llm.rb can be installed via rubygems.org:

	gem install llm.rb

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
