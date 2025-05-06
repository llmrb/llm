#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(key: ENV["KEY"])
convo = llm.chat File.read("./share/llm/prompts/system.txt"), role: :system
convo.chat "Tell me the answer to 5 + 15", role: :user
convo.chat "Tell me the answer to (5 + 15) * 2", role: :user
convo.chat "Tell me the answer to ((5 + 15) * 2) / 10", role: :user
convo.messages.each { print "[#{_1.role}] ", _1.content, "\n" }

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
