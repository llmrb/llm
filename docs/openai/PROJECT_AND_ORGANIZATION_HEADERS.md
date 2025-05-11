## OpenAI

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
