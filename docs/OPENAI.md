## OpenAI

### Contents

* [API](#api)
  * [Responses](#responses)
  * [Moderations](#moderations)
* [Headers](#headers)
  * [Project, Organization](#project-organization)

### API

#### Responses

llm.rb has first-class support for
[OpenAI's responses API](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses).
The responses API allows a client to store message state on OpenAI's servers &ndash;
and in turn a client can avoid maintaining state manually as well as avoid sending
the entire conversation on each turn in a conversation. See also:
[LLM::OpenAI::Responses](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Responses.html).

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
bot = LLM::Chat.new(llm).lazy
log = bot.respond do |prompt|
  prompt.developer File.read("./share/llm/prompts/system.txt")
  prompt.user "Tell me the answer to 5 + 15"
  prompt.user "Tell me the answer to (5 + 15) * 2"
  prompt.user "Tell me the answer to ((5 + 15) * 2) / 10"
end
log.each { print "[#{_1.role}] ", _1.content, "\n" }

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

#### Moderations

llm.rb has first-class support for
[OpenAI's moderations API](https://platform.openai.com/docs/api-reference/moderations/create)
that allows a client to determine if a piece of text, or an image URL
is considered harmful or not &ndash; across multiple categories. The interface
is similar to the one provided by the official OpenAI Python and JavaScript
libraries. See also: [LLM::OpenAI::Moderations](https://0x1eef.github.io/x/llm.rb/LLM/OpenAI/Moderations.html).

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
