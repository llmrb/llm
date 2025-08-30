## OpenAI

### Contents

* [Responses](#responses)
* [Moderations](#moderations)
* [Vector Stores](#vector_stores)
* [Headers: Project, Organization](#headers)

#### Responses

[OpenAI's responses API](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses)
is an alternative to the standard chat completions API and it has a number
of advantages over the standard chat completions API. Perhaps most notably,
it maintains message state on OpenAI's servers by default but that's not all.
It also provides access to remote tools, such as web search and file search tools,
and more.

The following example stores message state on OpenAI's servers &ndash;
and in turn a client can avoid maintaining state manually as well as avoid sending
the entire conversation on each turn in a conversation:

```ruby
#!/usr/bin/env ruby
require "llm"

llm  = LLM.openai(key: ENV["KEY"])
bot  = LLM::Bot.new(llm)
url  = "https://en.wikipedia.org/wiki/Special:FilePath/Cognac_glass.jpg"

bot.respond "Your task is to answer all user queries", role: :developer
bot.respond ["Tell me about this URL", URI(url)], role: :user
bot.respond ["Tell me about this PDF", File.open("handbook.pdf", "rb")], role: :user
bot.respond "Are the URL and PDF similar to each other?", role: :user

# At this point, we execute a single request
bot.messages.each { print "[#{_1.role}] ", _1.content, "\n" }
```

The next example performs a web search with OpenAI's web search tool &ndash;
and this is done on top of the responses API:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
res = llm.responses.create("Summarize today's news", tools: [{type: "web_search"]}])
print "[assistant] ", res.ouput_text, "\n"
```

#### Moderations

[OpenAI's moderations API](https://platform.openai.com/docs/api-reference/moderations/create)
offers a service that can determine if a piece of text, or an image URL
is considered harmful or not &ndash; across multiple categories. The interface
is similar to the one provided by the official OpenAI Python and JavaScript
libraries:

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
queries, with the option to apply filters to refine the results:

```ruby
#!/usr/bin/env ruby
require "llm"

pdfs = ["handbook.pdf"]
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
chunks = res.flat_map { _1["content"] }
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


#### Headers

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
