## About

A lightweight Ruby library for interacting with multiple LLM providers

## Examples

### LazyConversation

The
[`LLM::Provider#chat`](https://0x1eef.github.io/x/llm/LLM/Provider.html#chat-instance_method)
method returns a
[`LLM::LazyConversation`](https://0x1eef.github.io/x/llm/LLM/LazyConversation.html)
object
that can maintain a "lazy" conversation where input prompts are sent to the
provider only when needed. Once a conversation is initiated it will maintain a
thread of messages that provide the LLM with a certain amount of extra context
that can be re-used within the conversation:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai("yourapikey")
bot = llm.chat "keep the answer concise", :system
bot.chat URI("https://upload.wikimedia.org/wikipedia/commons/b/be/Red_eyed_tree_frog_edit2.jpg")
bot.chat "What is the frog's name?"
bot.chat "What is the frog's habitat?"
bot.chat "What is the frog's diet?"

##
# At this point a single request is made to the provider
# See 'LLM::LazyThread#each' for more details
bot.thread.each do |message|
  print "[#{message.role}] ", message.content, "\n"
end

##
# [system] keep the answer concise
# [user] [{:type=>:image_url, :image_url=>{:url=>"https://upload.wikimedia.org/wikipedia/commons/b/be/Red_eyed_tree_frog_edit2.jpg"}}]
# [user] What is the frog's name?
# [user] What is the frog's habitat?
# [user] What is the frog's diet?
# [assistant] The frog in the image is likely a Red-eyed Tree Frog.
#
#  #### Habitat:
#  - Typically found in tropical rainforests, especially in Central America.
#
#  #### Diet:
#   - Primarily insectivorous, feeding on insects like crickets and moths.
```

### Conversation

The
[`LLM::Provider#chat`](https://0x1eef.github.io/x/llm/LLM/Provider.html#chat!-instance_method)
method returns a
[`LLM::Conversation`](https://0x1eef.github.io/x/llm/LLM/Conversation.html)
object that can maintain a conversation with a LLM provider but unlike
[`LLM::LazyConversation`](https://0x1eef.github.io/x/llm/LLM/LazyConversation.html)
each call to `chat!` / `chat` corresponds to a HTTP request to the provider:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.openai("yourapikey")
bot = llm.chat! "be a helpful assistant", :system
bot.chat "keep the answers short and sweet", :system
bot.chat "help me choose a good book"
bot.chat "books of poetry"
bot.thread.each do |message|
  print "[#{message.role}] ", message.content, "\n"
end

##
# [system] be a helpful assistant
# [assistant] Of course! How can I assist you today?
# [system] keep the answers short and sweet
# [assistant] Got it! What do you need help with?
# [user] help me choose a good book
# [assistant] Sure! What genre are you interested in?
# [user] books of poetry
# [assistant] Here are a few great poetry collections:
#
# 1. **"The Sun and Her Flowers" by Rupi Kaur**
# 2. **"The Carrying" by Ada Limón**
# 3. **"Milk and Honey" by Rupi Kaur**
# 4. **"Ariel" by Sylvia Plath**
# 5. **"The Poetry of Pablo Neruda"**
#
# Happy reading!
```

## Providers

- [x] [Anthropic](https://www.anthropic.com/)
- [x] [OpenAI](https://platform.openai.com/docs/overview)
- [x] [Gemini](https://ai.google.dev/gemini-api/docs)
- [x] [Ollama](https://github.com/ollama/ollama#readme)
- [ ] Hugging Face
- [ ] Cohere
- [ ] AI21 Labs
- [ ] Replicate
- [ ] Mistral AI

## Documentation

A complete API reference is available at [0x1eef.github.io/x/llm](https://0x1eef.github.io/x/llm)

## Install

LLM has not been published to RubyGems.org yet. Stay tuned

## License

MIT. See [LICENSE.txt](LICENSE.txt) for more details
