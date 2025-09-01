## About

llm.rb is a zero-dependency Ruby toolkit for Large Language Models that
includes OpenAI, Gemini, Anthropic, xAI (Grok), DeepSeek, Ollama, and
LlamaCpp. The toolkit includes full support for chat, streaming, tool calling,
audio, images, files, and structured outputs (JSON Schema).

## Quick start

#### Demo

This cool demo writes a new [llm-shell](https://github.com/llmrb/llm-shell#readme) command
with the help of AI. Similar-ish to GitHub Copilot but for the terminal.

<details>
  <summary>Pair programmer</summary>
  <img src="https://github.com/llmrb/llm/blob/main/share/llm-shell/examples/demo.gif?raw=true" alt="llm-shell demo" />
</details>

#### Reviews

I supplied both Gemini and DeepSeek with the contents of [lib/](https://github.com/llmrb/llm/tree/main/lib)
and [README.md](https://github.com/llmrb/llm#readme) via [llm-shell](https://github.com/llmrb/llm-shell#readme).
Their feedback was way more positive than I could have imagined 😅 These are genuine responses though, with no
special prompting or engineering. I just provided them with the source code and asked for their opinion.

<details>
  <summary>Review by Gemini</summary>
  <img src="https://github.com/llmrb/llm/blob/main/share/llm-shell/examples/gemini.png?raw=true" alt="Gemini review" />
</details>

<details>
  <summary>Review by DeepSeek</summary>
  <img src="https://github.com/llmrb/llm/blob/main/share/llm-shell/examples/deepseek.png?raw=true" alt="DeepSeek review" />
</details>

#### Guides

* [An introduction to RAG](https://0x1eef.github.io/posts/an-introduction-to-rag-with-llm.rb/) &ndash;
  a blog post that implements the RAG pattern
* [How to estimate the age of a person in a photo](https://0x1eef.github.io/posts/age-estimation-with-llm.rb/) &ndash;
  a blog post that implements an age estimation tool
* [How to edit an image with Gemini](https://0x1eef.github.io/posts/how-to-edit-images-with-gemini/) &ndash;
  a blog post that implements image editing with Gemini

#### Ecosystem

* [llm-shell](https://github.com/llmrb/llm-shell) &ndash; a developer-oriented console for Large Language Model communication
* [llm-spell](https://github.com/llmrb/llm-spell) &ndash; a utility that can correct spelling mistakes with a Large Language Model

## Features

#### General
- ✅ A single unified interface for multiple providers
- 📦 Zero dependencies outside Ruby's standard library
- 🚀 Smart API design that minimizes the number of requests made

#### Chat, Agents
- 🧠 Stateless and stateful chat via completions and responses API
- 🤖 Tool calling and function execution
- 🗂️ JSON Schema support for structured, validated responses
- 📡 Streaming support for real-time response updates

#### Media
- 🗣️ Text-to-speech, transcription, and translation
- 🖼️ Image generation, editing, and variation support
- 📎 File uploads and prompt-aware file interaction
- 💡 Multimodal prompts (text, documents, audio, images, videos, URLs, etc)

#### Embeddings
- 🧮 Text embeddings and vector support
- 🧱 Includes support for OpenAI's vector stores API

#### Miscellaneous
- 📜 Model management and selection
- 🔧 Includes support for OpenAI's responses, moderations, and vector stores APIs

## Matrix

While the Features section above gives you the high-level picture, the table below
breaks things down by provider, so you can see exactly what’s supported where.


| Feature / Provider                  | OpenAI | Anthropic | Gemini | DeepSeek | xAI (Grok) | Ollama | LlamaCpp |
|--------------------------------------|:------:|:---------:|:------:|:--------:|:----------:|:------:|:--------:|
| **Chat Completions**                 | ✅     | ✅        | ✅     | ✅       | ✅         | ✅     | ✅       |
| **Streaming**                        | ✅     | ✅        | ✅     | ✅       | ✅         | ✅     | ✅       |
| **Tool Calling**                     | ✅     | ✅        | ✅     | ✅       | ✅         | ✅     | ✅       |
| **JSON Schema / Structured Output**  | ✅     | ❌        | ✅     | ❌       | ✅         | ✅*    | ✅*      |
| **Embeddings**                       | ✅     | ✅        | ✅     | ✅       | ❌         | ✅     | ✅       |
| **Multimodal Prompts** *(text, documents, audio, images, videos, URLs, etc)* | ✅     | ✅        | ✅     | ✅       | ✅         | ✅     | ✅       |
| **Files API**                        | ✅     | ✅        | ✅     | ❌       | ❌         | ❌     | ❌       |
| **Models API**                       | ✅     | ✅        | ✅     | ✅       | ✅         | ✅     | ✅       |
| **Audio (TTS / Transcribe / Translate)** | ✅  | ❌        | ✅     | ❌       | ❌         | ❌     | ❌       |
| **Image Generation & Editing**       | ✅     | ❌        | ✅     | ❌       | ✅         | ❌     | ❌       |
| **Local Model Support**              | ❌     | ❌        | ❌     | ❌       | ❌         | ✅     | ✅       |
| **Vector Stores (RAG)**               | ✅     | ❌        | ❌     | ❌       | ❌         | ❌     | ❌       |
| **Responses**                        | ✅     | ❌        | ❌     | ❌       | ❌         | ❌     | ❌       |
| **Moderations**                      | ✅     | ❌        | ❌     | ❌       | ❌         | ❌     | ❌       |

\* JSON Schema support in Ollama/LlamaCpp depends on the model, not the API.


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
llm = LLM.xai(key: "yourapikey")
llm = LLM.deepseek(key: "yourapikey")

##
# local providers
llm = LLM.ollama(key: nil)
llm = LLM.llamacpp(key: nil)
```

### Conversations

#### Completions

> This example uses the stateless chat completions API that all
> providers support. A similar example for OpenAI's stateful
> responses API is available in the [docs/](https://0x1eef.github.io/x/llm.rb/file.OPENAI.html#responses)
> directory.

The following example creates an instance of
[LLM::Bot](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html)
and enters into a conversation where messages are buffered and
sent to the provider on-demand. The implementation is designed to
buffer messages by waiting until an attempt to iterate over
[LLM::Bot#messages](https://0x1eef.github.io/x/llm.rb/LLM/Bot.html#messages-instance_method)
is made before sending a request to the LLM:

```ruby
#!/usr/bin/env ruby
require "llm"

llm  = LLM.openai(key: ENV["KEY"])
bot  = LLM::Bot.new(llm)
url  = "https://en.wikipedia.org/wiki/Special:FilePath/Cognac_glass.jpg"

bot.chat "Your task is to answer all user queries", role: :system
bot.chat ["Tell me about this URL", URI(url)], role: :user
bot.chat ["Tell me about this PDF", File.open("handbook.pdf", "rb")], role: :user
bot.chat "Are the URL and PDF similar to each other?", role: :user

# At this point, we execute a single request
bot.messages.each { print "[#{_1.role}] ", _1.content, "\n" }
```

#### Streaming

> There Is More Than One Way To Do It (TIMTOWTDI) when you are
> using llm.rb &ndash; and this is especially true when it
> comes to streaming. See the streaming documentation in
> [docs/](https://0x1eef.github.io/x/llm.rb/file.STREAMING.html#scopes)
> for more details.

The following example streams the messages in a conversation
as they are generated in real-time. The `stream` option can
be set to an IO object, or the value `true` to enable streaming
&ndash; and at the end of the request, `bot.chat` returns the
same response as the non-streaming version which allows you
to process a response in the same way:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)
url = "https://en.wikipedia.org/wiki/Special:FilePath/Cognac_glass.jpg"
bot.chat(stream: $stdout) do |prompt|
  prompt.system "Your task is to answer all user queries"
  prompt.user ["Tell me about this URL", URI(url)]
  prompt.user ["Tell me about this PDF", File.open("handbook.pdf", "rb")]
  prompt.user "Are the URL and PDF similar to each other?"
end.to_a
```

### Schema

#### Structured

All LLM providers except Anthropic and DeepSeek allow a client to describe
the structure of a response that a LLM emits according to a schema that is
described by JSON. The schema lets a client describe what JSON object (or value)
an LLM should emit, and the LLM will abide by the schema:

```ruby
#!/usr/bin/env ruby
require "llm"

##
# Objects
llm = LLM.openai(key: ENV["KEY"])
schema = llm.schema.object(probability: llm.schema.number.required)
bot = LLM::Bot.new(llm, schema:)
bot.chat "Does the earth orbit the sun?", role: :user
bot.messages.find(&:assistant?).content! # => {probability: 1.0}

##
# Enums
schema = llm.schema.object(fruit: llm.schema.string.enum("Apple", "Orange", "Pineapple"))
bot = LLM::Bot.new(llm, schema:)
bot.chat "Your favorite fruit is Pineapple", role: :system
bot.chat "What fruit is your favorite?", role: :user
bot.messages.find(&:assistant?).content! # => {fruit: "Pineapple"}

##
# Arrays
schema = llm.schema.object(answers: llm.schema.array(llm.schema.integer.required))
bot = LLM::Bot.new(llm, schema:)
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
and potentially repopulated on the next message:

```ruby
#!/usr/bin/env ruby
require "llm"

llm  = LLM.openai(key: ENV["KEY"])
tool = LLM.function(:system) do |fn|
  fn.description "Run a shell command"
  fn.params do |schema|
    schema.object(command: schema.string.required)
  end
  fn.define do |command:|
    ro, wo = IO.pipe
    re, we = IO.pipe
    Process.wait Process.spawn(command, out: wo, err: we)
    [wo,we].each(&:close)
    {stderr: re.read, stdout: ro.read}
  end
end

bot = LLM::Bot.new(llm, tools: [tool])
bot.chat "Your task is to run shell commands via a tool.", role: :system

bot.chat "What is the current date?", role: :user
bot.chat bot.functions.map(&:call) # report return value to the LLM

bot.chat "What operating system am I running? (short version please!)", role: :user
bot.chat bot.functions.map(&:call) # report return value to the LLM

##
# {stderr: "", stdout: "Thu May  1 10:01:02 UTC 2025"}
# {stderr: "", stdout: "FreeBSD"}
```

#### Tools

The
[LLM::Function](https://0x1eef.github.io/x/llm.rb/LLM/Function.html)
class can define a local function that can be called by a provider on your behalf,
and the
[LLM::Tool](https://0x1eef.github.io/x/llm.rb/LLM/Tool.html)
class represents a tool that is defined and implemented by a provider, and we can
request that the provider call the tool on our behalf. That's the primary difference
between a function implemented locally and a tool implemented by a provider. The
available tools depend on the provider, and the following example uses the
OpenAI provider to execute Python code on OpenAI's servers:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
res = llm.responses.create "Run: 'print(\"hello world\")'", tools: [llm.tool(:code_interpreter)]
print res.output_text, "\n"
```

#### Web Search

A common tool among all providers is the ability to perform a web search, and
the following example uses the OpenAI provider to search the web using the
Web Search tool. This can also be done with the Anthropic and Gemini providers:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
res = llm.web_search(query: "summarize today's news")
print res.output_text, "\n"
```

### Files

#### Create

The OpenAI and Gemini providers provide a Files API where a client can upload files
that can be referenced from a prompt, and with other APIs as well. The following
example uses the OpenAI provider to describe the contents of a PDF file after
it has been uploaded. The file (a specialized instance of
[LLM::Response](https://0x1eef.github.io/x/llm.rb/LLM/Response.html)
) is given as part of a prompt that is understood by llm.rb:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)
file = llm.files.create(file: "/books/goodread.pdf")
bot.chat ["Tell me about this file", file]
bot.messages.select(&:assistant?).each { print "[#{_1.role}] ", _1.content, "\n" }
```

### Prompts

#### Multimodal

It is generally a given that an LLM will understand text but they can also
understand and generate other types of media as well: audio, images, video,
and even URLs. The object given as a prompt in llm.rb can be a string to
represent text, a URI object to represent a URL, an LLM::Response object
to represent a file stored with the LLM, and so on. These are objects you
can throw at the prompt and have them be understood automatically.

A prompt can also have multiple parts, and in that case, an array is given
as a prompt. Each element is considered to be part of the prompt:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Bot.new(llm)

bot.chat ["Tell me about this URL", URI("https://example.com/path/to/image.png")]
[bot.messages.find(&:assistant?)].each { print "[#{_1.role}] ", _1.content, "\n" }

file = llm.files.create(file: "/books/goodread.pdf")
bot.chat ["Tell me about this PDF", file]
[bot.messages.find(&:assistant?)].each { print "[#{_1.role}] ", _1.content, "\n" }

bot.chat ["Tell me about this image", File.open("/images/nemothefish.png", "r")]
[bot.messages.find(&:assistant?)].each { print "[#{_1.role}] ", _1.content, "\n" }
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
# LLM::Response
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
bot = LLM::Bot.new(llm, model: model.id)
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

* [An introduction to RAG](https://0x1eef.github.io/posts/an-introduction-to-rag-with-llm.rb/) &ndash;
  a blog post that implements the RAG pattern
* [How to estimate the age of a person in a photo](https://0x1eef.github.io/posts/age-estimation-with-llm.rb/) &ndash;
  a blog post that implements an age estimation tool
* [How to edit an image with Gemini](https://0x1eef.github.io/posts/how-to-edit-images-with-gemini/) &ndash;
  a blog post that implements image editing with Gemini
* [docs/](docs/) &ndash; the docs directory contains additional guides

## Install

llm.rb can be installed via rubygems.org:

	gem install llm.rb

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
