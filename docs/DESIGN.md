## Design

> **Foreword** <br>
> This part of the documentation primarily serves as a reminder to myself
> and others about the design guidelines that llm.rb follows &ndash; it is
> not intended to be a criticism of any other library or approach to software
> development.

llm.rb aims to provide a clean, simple, and dependency-free interface to
Large Language Models (LLMs). It follows the spirit of the Unix philosophy:
_do one thing well_ &ndash; and it is designed around composable parts
that can be injected as dependencies that all quack the same way &ndash;
which allows alternative implementations to easily replace the defaults.
It does not aim to be a monolith that is hard to extend or change.

The library does not aim to be or try to be an "everything" library &ndash;
instead it tries to be just one tool in your toolbox, and you should use
the right tool for the task at hand. It embraces a general-purpose,
object-oriented design that prioritizes explicitness, composability,
and clarity. The library is intentionally simple and won't compromise
on being a simple library &ndash; even if that means saying no to certain features.

Each part of llm.rb is designed to be conscious of memory, ready for production,
and free from global state or non-standard dependencies. While inspired by ideas
from other ecosystems (especially Python, and JavaScript) it is not a port of
any other library — it is a Ruby library written by Ruby programmers who value
borrowing good ideas from other languages and ecosystems.
