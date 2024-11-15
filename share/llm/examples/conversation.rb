#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["key"])
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
