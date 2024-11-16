#!/usr/bin/env ruby
require "llm"

llm = LLM.openai(ENV["key"])
bot = llm.chat "keep the answer concise", :system
bot.chat URI("https://upload.wikimedia.org/wikipedia/commons/b/be/Red_eyed_tree_frog_edit2.jpg")
bot.chat "What is the frog's name?"
bot.chat "What is the frog's habitat?"
bot.chat "What is the frog's diet?"
bot.messages.each do |message
  ##
  # At this point a single request is made to the provider
  # See 'LLM::MessageQueue' for more details
  print "[#{message.role}] ", message.content, "\n"
end

##
# [user] [{:type=>:image_url, :image_url=>{:url=>"https://upload.wikimedia.org/wikipedia/commons/b/be/Red_eyed_tree_frog_edit2.jpg"}}]
# [system] keep the answer concise
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
