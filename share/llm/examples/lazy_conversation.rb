#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["KEY"])
conversation = llm.chat File.read("./share/llm/prompts/system.txt"), :system
conversation.chat "What color is the sky?"
conversation.chat "What color is an orange?"
conversation.chat "I like Ruby"
conversation.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

##
# [system] You are a friendly chatbot. Sometimes, you like to tell a joke.
#          But the joke must be based on the given inputs.
#          I will provide you a set of messages. Reply to all of them.
#          A message is considered unanswered if there is no corresponding assistant response.
#
# [user] What color is the sky?
# [user] What color is an orange?
# [user] I like Ruby
#
# [assistant] The sky is typically blue during the day, but it can have beautiful
#             hues of pink, orange, and purple during sunset! As for an orange,
#             it is usually orange in color—funny how that works, right?
#             I love Ruby too! Did you know that a Ruby is not only a beautiful
#             gemstone but also a programming language? So, you could say it's both
#             precious and powerful! Speaking of colors, why did the orange stop?
#             Because it ran out of juice! 🍊😂
