## Memory

### Child process

When it comes to the generation of audio, images, and video memory consumption
can be a potential problem. There are a few strategies in place to deal with this,
and one lesser known strategy is to let a child process handle the memory cost
by delegating media generation to a child process.

Once a child process exits, any memory it had used is freed immediately and
the parent process can continue to have a small memory footprint. In a sense
it is similar to being able to use malloc + free from Ruby. The following example
demonstrates how that might look like in practice:

```ruby
#!/usr/bin/env ruby
require "llm"

llm = LLM.gemini(key: ENV["KEY"])
fork do
  %w[dog cat sheep goat capybara].each do |animal|
    res = llm.images.create(prompt: "a #{animal} on a rocket to the moon")
    IO.copy_stream res.images[0], "#{animal}.png"
  end
end
Process.wait
```
