Write a ruby script using nokogiri to parse an HTML document, tag by tag,
according to the algorithm below.

First create two stacks, called 'headings' and 'content'. Each stack will
contain HTML documents.

In the algorithm below, 'flush' means to create a new HTML document from each
document in the 'content' stack, and then to empty the 'content' stack. Write
the new HTML document to stdout, for now.

```
find heading
    headings.push(heading)
    content.push(heading)
find sibling
begin
    if heading
        content.flush
        if <
            headings.pop until headings.count = heading.level - 1 or headings.count = 0
            headings.push(heading)
        if =
            headings.pop
            headings.push(heading)
        if >
            headings.push(heading)
        content.push(headings)
    otherwise
        content.push(tag)
end
```
