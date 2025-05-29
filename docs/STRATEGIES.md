## Strategies

### Contents

* [Memory](#memory)
  * [Temporary memory](#temporary-memory)

### Memory

#### Temporary memory

When it comes to the generation of audio, images, and video &ndash;
memory consumption can be a potential problem. Although llm.rb tries
to optimize how it handles media content; there is another relatively
straight-forward technique that can be implemented by users of the
library.

We can avoid inheriting a process with high memory usage by letting a
child process handle the generation of media content. Once the child
process exits, the memory it had used is freed immediately and the
parent process can continue to have a small memory footprint.

In a sense it is similar to being able to use malloc + free from Ruby. The
following example demonstrates how that might look like in practice:

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
