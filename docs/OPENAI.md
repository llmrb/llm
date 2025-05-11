## OpenAI

### Contents

* [API](#api)
  * [Responses](#responses)
* [Headers](#headers)
  * [Project, Organization](#project-organization)

### API

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


### Headers

#### Project, Organization


The `LLM::Provider#with` method allows the caller to add
their own headers to all subsequent requests, and it works
for all providers but might be especially useful for
OpenAI &ndash; since it allows the caller to set the
`OpenAI-Organization` and `OpenAI-Project` headers:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
llm.with(headers: {"OpenAI-Project" => ENV["PROJECT"]})
   .with(headers: {"OpenAI-Organization" => ENV["ORG"]})
```
