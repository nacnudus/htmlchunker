# Repeat higher headings alongside subheadings

RAG search works well with text that has been split into small chunks. Splitting at headings and subheadings seems natural, but important context can be lost. lost. Some context can be regained by repeating higher headings alongside the subheading of each chunk.

## Usage

```ruby
require './htmlchunker'

html = %{<h1>How to lose a guy in 10 days</h1>
Tips for how to get dumped, deliberately.
<h2>Dating tips</h2>
Make him miss seeing his team's final, winning shot.}

HTMLChunker.new(html).chunk.chunks
```

```text
=> ["<h1>How to lose a guy in 10 days</h1>\nTips for how to get dumped, deliberately.\n",
 "<h1>How to lose a guy in 10 days</h1><h2>Dating tips</h2>\nMake him miss seeing his team's final, winning shot."]
```

## If you don't use this

The chunks would be as below. The second chunk would omit crucial context.

```html
<h1>How to lose a guy in 10 days</h1>

Tips for how to get dumped, deliberately.
```

```html
<h2>Dating tips</h2>

Make him miss seeing his team's final, winning shot.
```

htmlchunker repeats the `<h1>` heading alongside the `<h2>` heading so that some of the context is retained in the second chunk.

```html
<h1>How to lose a guy in 10 days</h1>
<h2>Dating tips</h2>

Make him miss seeing his team's final, winning shot.
```

## Algorithm

Create a stack for headings and a stack for content. Each stack will contain HTML fragments.

### Loop

1. Initialise the heading level to 0.
2. Find the next node.
3. If it is a heading node, then
   1. Flush the content stack.
   2. Pop the headings stack until it contains only ancestors of the found node.
   3. Push a clone of each item in the headings stack onto the content stack.

   Otherwise, push the node onto the content stack.
4. Repeat until there are no more nodes.
5. Flush the content stack.

### Flush

1. Concatenate each HTML fragement in the content stack into a new HTML fragment.
2. Emit the fragment (to STDOUT, for example).
3. Empty the content stack.
