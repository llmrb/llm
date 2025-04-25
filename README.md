## About

llm.rb is a lightweight library that provides a common interface
and set of functionality for multiple Large Language Models (LLMs). It
is designed to be simple, flexible, and easy to use &ndash; and it has been
implemented with no dependencies outside Ruby's standard library.

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
```

### Conversations

#### Completions

The following example enables lazy mode for a
[LLM::Chat](https://0x1eef.github.io/x/llm.rb/LLM/Chat.html)
object by entering into a "lazy" conversation where messages are buffered and
sent to the provider only when necessary.  Both lazy and non-lazy conversations
maintain a message thread that can be reused as context throughout a conversation.
The example uses the stateless chat completions API that all LLM providers support:

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

### Audio

#### Speech

Some but not all providers implement audio generation capabilities that
can create text from speech, transcribe audio to text, or translate
audio to text (usually English). The following example uses the OpenAI provider
to create an audio file from a text prompt. The audio is then moved to
`${HOME}/hello.mp3` as the final step. As always, consult the provider's
documentation (eg [OpenAI docs](https://platform.openai.com/docs/api-reference/audio/create))
for more information on how to use the audio generation API:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(ENV["KEY"])
res = llm.audio.create_speech(input: "Hello world")
File.binwrite File.join(Dir.home, "hello.mp3"),
	          res.audio.string
```

#### Transcribe

The following example transcribes an audio file to text. The audio file
(`${HOME}/hello.mp3`) was theoretically created in the previous example,
and the result is printed to the console. The example uses the OpenAI
provider to transcribe the audio file. As always, consult the provider's
documentation (eg [OpenAI docs](https://platform.openai.com/docs/api-reference/audio/createTranscription))
for more information on how to use the audio transcription API:

```ruby
#!/usr/bin/env ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(ENV["KEY"])
res = llm.audio.create_transcription(
  file: LLM::File(File.join(Dir.home, "hello.mp3"))
)
print res.text, "\n" # => "Hello world."
```

#### Translate

The following example translates an audio file to text. In this example
the audio file (`${HOME/bomdia.mp3}`) is theoretically in Portuguese,
and it is translated to English. The example uses the OpenAI provider,
and at the time of writing, it can only translate to English. As always,
consult the provider's documentation (eg
[OpenAI docs](https://platform.openai.com/docs/api-reference/audio/createTranslation),
[Gemini docs](https://ai.google.dev/gemini-api/docs/image-generation))
for more information on how to use the audio translation API:

```ruby
require "llm"
require "open-uri"
require "fileutils"

llm = LLM.openai(ENV["KEY"])
res = llm.audio.create_translation(
  file: LLM::File(File.join(Dir.home, "bomdia.mp3"))
)
print res.text, "\n" # => "Good morning."
```

### Images

#### Create

Some but all LLM providers implement image generation capabilities that
can create new images from a prompt, or edit an existing image with a
prompt. The following example uses the OpenAI provider to create an
image of a dog on a rocket to the moon. The image is then moved to
`${HOME}/dogonrocket.png` as the final step.

Please note that there are subtle differences between Gemini and OpenAI
in regards to image generation &ndash; see
[LLM::Gemini::Images](https://0x1eef.github.io/x/llm.rb/LLM/Gemini/Images.html)
for more information:

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
are not satisfactory, and consult the provider's documentation
(eg
[OpenAI docs](https://platform.openai.com/docs/api-reference/images/createEdit),
[Gemini docs](https://ai.google.dev/gemini-api/docs/image-generation))
for more information on how to use the image editing API.

Please note that there are subtle differences between Gemini and OpenAI
in regards to image generation &ndash; see
[LLM::Gemini::Images](https://0x1eef.github.io/x/llm.rb/LLM/Gemini/Images.html)
for more information:

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
and so on as the final step. Consult the provider's documentation
(eg [OpenAI docs](https://platform.openai.com/docs/api-reference/images/createVariation))
for more information on how to use the image variations API:

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
    File.binwrite "#{animal}.png", res.images[0].binary
  end
end
Process.wait
```

## API reference

The README tries to provide a high-level overview of the library. For everything
else there's the API reference. It covers classes and methods that the README glances
over or doesn't cover at all. The API reference is available at
[0x1eef.github.io/x/llm.rb](https://0x1eef.github.io/x/llm.rb).


## Install

llm.rb can be installed via rubygems.org:

	gem install llm.rb

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
