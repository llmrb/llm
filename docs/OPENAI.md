## OpenAI

### Contents

* [API](#api)
  * [Responses](#responses)
  * [Moderations](#moderations)
  * [Vector Stores](#vector_stores)
* [Headers](#headers)
  * [Project, Organization](#project-organization)

### API

#### Responses

[OpenAI's responses API](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses)
is similar to the chat completions API, but unlike the chat completions API it
can maintain conversation state for you.

The following example stores message state on OpenAI's servers &ndash;
and in turn a client can avoid maintaining state manually as well as avoid sending
the entire conversation on each turn in a conversation. See also:
[LLM::OpenAI::Responses](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Responses.html).

```ruby
#!/usr/bin/env ruby
require "llm"

llm  = LLM.openai(key: ENV["KEY"])
bot  = LLM::Bot.new(llm)
msgs = bot.respond do |prompt|
  prompt.developer File.read("./share/llm/prompts/system.txt")
  prompt.user "Tell me the answer to 5 + 15"
  prompt.user "Tell me the answer to (5 + 15) * 2"
  prompt.user "Tell me the answer to ((5 + 15) * 2) / 10"
end

# At this point, we execute a single request
msgs.each { print "[#{_1.role}] ", _1.content, "\n" }
```

#### Moderations

[OpenAI's moderations API](https://platform.openai.com/docs/api-reference/moderations/create)
offers a service that can determine if a piece of text, or an image URL
is considered harmful or not &ndash; across multiple categories. The interface
is similar to the one provided by the official OpenAI Python and JavaScript
libraries.
See also: [LLM::OpenAI::Moderations](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Moderations.html):

```ruby
#!/usr/bin/env ruby
require "llm"

# Text
llm = LLM.openai(key: ENV["KEY"])
mod = llm.moderations.create input: "I hate you"
print "categories: ", mod.categories, "\n"
print "category scores: ", mod.scores, "\n"

# Image
llm = LLM.openai(key: ENV["KEY"])
mod = llm.moderations.create input: URI("https://example.com/image.png")
print "categories: ", mod.categories, "\n"
print "category scores: ", mod.scores, "\n"
```

#### Vector Stores

[OpenAI's Vector Stores API](https://platform.openai.com/docs/api-reference/vector_stores/create)
offers a vector database as a managed service. It allows a client to store a set
of files, which are automatically indexed and made searchable through vector
queries, with the option to apply filters to refine the results.
See also: [LLM::OpenAI::VectorStores](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/VectorStores.html).

```ruby
#!/usr/bin/env ruby
require "llm"

pdfs = ["spec/fixtures/documents/freebsd.sysctl.pdf"]
llm  = LLM.openai(key: ENV["OPENAI_SECRET"])
files = pdfs.map { llm.files.create(file: _1) }
store = llm.vector_stores.create(name: "PDF Store", file_ids: files.map(&:id))

while store.status != "completed"
  puts "Wait for vector store to come online"
  store = llm.vector_stores.get(vector: store)
  sleep 5
end
puts "Vector store is online"

puts "Search the vector store"
res = llm.vector_stores.search(vector: store, query: "What is FreeBSD?")
chunks = res.data.flat_map { _1["content"] }
puts "Found #{chunks.size} chunks"
files.each { llm.files.delete(file: _1) }
llm.vector_stores.delete(vector: store)

##
# Wait for vector store to come online
# Wait for vector store to come online
# Vector store is online
# Search the vector store
# Found 10 chunks
```


### Headers

#### Project, Organization


The
[`LLM::Provider#with`](https://0x1eef.github.io/x/llm.rb/LLM/Provider.html#with-instance_method)
method can add client headers to all requests, and it works for all providers but might
be especially useful for OpenAI &ndash; since it allows the client to set the
`OpenAI-Organization` and `OpenAI-Project` headers.

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
llm.with(headers: {"OpenAI-Project" => ENV["PROJECT"]})
   .with(headers: {"OpenAI-Organization" => ENV["ORG"]})
```
