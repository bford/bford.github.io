---
title: "MinML: concise but general markup syntax"
date: 2022-12-28
url: /2022/12/28/minml/
topics:
- Syntax
- Programming Languages
---

style[
table	{ width:75%;padding:10pt;margin-left:auto;margin-right:auto }
tr	{ text-align:left }
]

Could you use a markup syntax
that supports the full expressive power and richness of HTML or XML,
but is more terse, easier to type, and less frankly ugly?
To em[emphasize] text, for example,
would it be nice just to write code[+[em[emphasize]]]
instead of code[+[<em>emphasize</em>]]?
If so, pleae read on.


h2[The tussle between generality and writer-friendliness]

Markup languages derived from SGML, like HTML and XML,
are powerful and have many uses
but are verbose and often a pain to write or edit manually.
While XML was substantially a reaction to the complexity and bloat of SGML,
terseness was always considered of
a{href=https://www.schematron.com/document/467.html}[>
	minimal importance]
in XML.

p[]
Reactions to the verbosity and awkwardness of SGML-style markup
brought us formats like
a{href=[https://www.json.org/json-en.html]}[JSON]
and 
a{href=[https://en.wikipedia.org/wiki/Markdown]}[Markdown].
But while JSON is useful for automated data interchange,
it is not a markup language.
Its strict and minimal syntax demanded further extensions like
a{href=https://yaml.org}[YAML],
a{href=https://github.com/toml-lang/toml}[TOML], or
a{href=https://json5.org}[JSON5]
even to get, say, a way to write comments.

p[]
Markdown em[is] a markup language,
and vastly improves terseness and quick typeability
for the most common and simple markup constructs.
But its expressiveness is limited to a small subset of HTML.
Further,
the quirky special-case syntax it uses for each construct
makes its syntax difficult to "[scale] to richer functionality
without getting into a mess of syntax conflicts and ambiguities.
It is not easy to standardize, or even to specify rigorously [ndash]
not to say that this
a{href=[https://commonmark.org]}[hasn't been tried].
To see just how fragile Markdown syntax is,
try to understand [--] or correctly implement [--]
a{href=https://spec.commonmark.org/0.30/#emphasis-and-strong-emphasis}[>
	the 17 rules for parsing emphasis
	and the 131 associated examples] in Commonmark.

p[]
There are numerous extensions and alternative variants of Markdown-style syntax
to choose from, of course: e.g.,
a{href=https://github.github.com/gfm/}[GitHub flavor],
a{href=https://docutils.sourceforge.io/rst.html}[i[re]Structured <i[Text]],
a{href=https://perldoc.perl.org/perlpod}[POD],
a{href=https://orgmode.org}[Org Mode],
a{href=https://asciidoc.org}[AsciiDoc],
a{href=https://www.promptworks.com/textile}[Textile],
a{href=https://leanpub.com/markua/read}[Markua],
a{href=https://txt2tags.org}[txt2tags],
etc.
Each of these variants supports a i[different] small subset of HTML,
each with its own syntactic quirks for the markup author to learn afresh.
Further, each flavor's limitations present expressiveness barriers
that an author may encounter at any moment:
"[oh, but now can I do i[that]?]
These barriers can lead the frustrated author
to seek escape routes [ndash]
back to HTML,
or to another existing Markdown flavor,
or to create em[yet another] new flavor themselves
with ever-more-devilishly clever and brittle syntax
with another new and different set of limitations.

p[]
On a{href=[/]}[my web site],
I used to embed HTML tags in code[.md] files
in order to escape Markdown's limitations.
But when an "[upgrade]
to a{href=[https://gohugo.io]}[Hugo]
silently corrupted the entire website
by suddenly disabling all markdown-embedded HTML,
I realized the essential fragility of this solution.
Even if markdown-embedded HTML 
a{href=[https://flaviocopes.com/hugo-embed-html-markdown/]}[can be re-enabled],
I do not want all my past writing being silently corrupted on a regular basis
by the latest evolution in the markdown parser or its default configuration.
Markdown and em[all] its flavors are risky dead-ends in the long term.
There em[is] real value in relying on stable, highly-standardized,
general-purpose markup formats like HTML or XML.
But do I em[really] have to keep typing all those stupid start and end tags?


h2[Introducing MinML]

MinML 
(which I pronounce like "[minimal])
is a more concise or "[minified] syntax
for markup languages like HTML and XML.
It is designed to be automatically cross-convertible
both to and from the base markup syntax,
and to preserve the full expressiveness of the underlying markup language.
Unlike Markdown, there is nothing you can write in HTML but not in MinML.

p[]
In effect,
MinML might be described as
merely a new "[skin] for a general markup language like HTML or XML.
It changes em[only] the way you write element tags,
attributes, or character references,
without generally affecting (or even knowing or caring about)
em[which] element tags, attributes, or references you use.
MinML therefore not only supports the expressive richness of HTML now,
but its expressiveness will continue growing
as HTML evolves in the future.

p[]
Let us start with a brief tour of MinML syntax.


h3[Basic markup elements]

In place of start/end tag pairs,
MinML uses the basic syntax code[var[tag][var[content]]],
as illustrated in the following table:

table{}[
	tr[
		th[HTML]
		th[MinML]
		th[Output]
	]
	tr[
		td[code[<em>emphasis</em>]]
		td[code[+[em[emphasis]]]]
		td[em[emphasis]]
	]
	tr[
		td[code[<kbd>typewriter</kbd>]]
		td[code[+[kbd[typewriter]]]]
		td[kbd[typewriter]]
	]
	tr[
		td[code[<var>x</var><sup>2</sup>]]
		td[code[+[var[x]sup[2]]]]
		td[var[x]sup[2]]
	]
]

An element with no content,
like code[<hr>] in HRML or code[<hr/>] in XML,
becomes code[+[hr[]]] in MinML.


h3[Elements with attributes]

In MinML, we attach attributes to elements
by inserting them in curly braces between the tag
and square-bracketed content, like this:

table[
	tr[
		th[MinML]
		th[Output]
	]
	tr[
		td[code[+[hr{width=100%}[]]]]
		td[hr{width=100%}[]]
	]
	tr[
		td[code[+[img{src=cat.jpg height=40}[]]]]
		td[img{src=cat.jpg height=40}[]]
	]
	tr[
		td[code[+[a{href=http://bford.info/}[my home page]]]]
		td[a{href=http://bford.info/}[my home page]]
	]
]

If an attribute value in an element needs to contain spaces,
we quote the value with square brackets, like this:

pre[+[	img{src=cat.jpg alt=[a cute cat photo]}[]
]]


h3[Character references]

MinML uses square brackets
in place of SGML's bizarre code[&][hellip]code[;] syntax
to delimit character references.
Thus,
you write code[+[[reg]]] in MinML
instead of code[+[&reg;]] in HTML
to get a registered trademark sign [reg].

p[]
You can use numeric character references too,
of course.
For example,
code[+[[#174]]] in decimal or code[+[[#x00AE]]] in hexadecimal
are alternative representations for the character [reg].


h3[Quoted strings]

You can still use the directed (left and right)
single- and double-quote character references
to typeset quoted strings properly.
Writing code[+[[ldquo]quote[rdquo]]] in MinML,
as opposed to code[+[&ldquo;quote&rdquo;]] in XML,
already seems like a slightly-improved way to express
a quoted "[string].

p[]
Because quoted strings are such an important common case, however,
MinML provides an even more concise alternative for matching quotes.
You can write code[+["[string]]] to express
a "[string] delimited by matching double quotes,
or code[+['[string]]]
for a '[string] delimited by matching single quotes.
-[
The leading code["] or code['] characters here are actually just element names,
which MinML liberalizes to allow punctuation and symbols.
]


h3[Comments in markup]

You can include comments in MinML markup
with code[- <[var[c]]], like this:

table{style=width:75%;padding:10pt;margin-left:auto;margin-right:auto}[
	tr[
		th[HTML]
		th[MinML]
		th[Output]
	]
	tr[
		td[code[+[<!-- comment -->]]]
		td[code[+[-[comment]]]]
		td[-[comment]]
	]
]


h3[Managing whitespace]

Because an element tag is outside (just before)
an open bracket or curly brace in MinML,
we often need whitespace to separate an element from preceding text:

table[
	tr[
		td[code[+[bee em[yoo] tiful]]]
		td[bee em[yoo] tiful]
	]
]

Without the whitespace before the code[em] tag,
it would look like the incorrect tag code[beeem].
If you don't actually want whitespace around an element, however,
you can use less-than code[+[<]] and greater-than code[+[>]] signs
to consume or "[suck] the surrounding whitespace:

table[
	tr[
		td[code[+[bee <em[yoo]> tiful]]]
		td[bee <em[yoo]> tiful]
	]
]

These space-sucking symbols are em[not] delimiters as in SGML, however,
and need not appear in matched pairs.
You can use them to suck space on one side but not the other:

table[
	tr[
		td[code[+[mark <em[up] now]]]
		td[mark <em[up] now]
	]
	tr[
		td[code[+[now em[mark]> up]]]
		td[now em[mark]> up]
	]
]

You can also use space-suckers em[within] an element's content,
to suck space at the beginning and/or end of the content:

table[
	tr[
		td[code[+[a <b[> b <]> c]]]
		td[a <b[> b <]> c]
	]
]

If you need literal square brackets or curly braces
immediately after what could otherwise be an element name,
you can separate them with whitespace and a space-sucker:

table[
	tr[
		td[code[+[b[1 <[hellip]> 10]]]]
		td[b[1 <[hellip]> 10]]
	]
	tr[
		td[code[+[b <[1 <[hellip]> 10]]]]
		td[b <[1 <[hellip]> 10]]
	]
	tr[
		td[code[+[set <{a,b,c}]]]
		td[set <{a,b,c}]
	]
]

The same is true if you need a literal square-bracket pair 
surrounding what could be mistaken for a character reference:

table[
	tr[
		td[code[+[[star]]]]
		td[[star]]
	]
	tr[
		td[code[+[[> star <]]]]
		td[[> star <]]
	]
]


h3[Raw matchertext sequences]

MinML builds on the
a{href=/pub/lang/matchertext/}[matchertext]
syntactic discipline.
Matchertext makes it possible
to embed one text string into another unambiguously [ndash]
within a language or even across languages [ndash]
without having to "[escape]
or otherwise transform the embedded text.
The cost of this syntactic discipline 
is that the ASCII dfn[matcher] characters [ndash]
namely the parentheses code[()],
square brackets code[[]],
and curly braces code[{}] [ndash]
must appear em[only] in properly-nesting matched pairs throughout matchertext.

p[]
Let's first look at one of the benefits of matchertext in MinML.
You can use the sequence code[+ <[var[m]]]
to include any matchertext string var[m] into the markup
as raw literal text,
which is completely uninterpreted except to find its end.
No character sequences are disallowed in the embedded text
as long as matchers match.

p[]
You can use raw matchertext sequences
 to include verbatim examples of markup or other code
in your text, for example.
A code[+ <[var[m]]] sequence
is thus a more concise analog to XML's clunky CDATA sections:

table{style=width:100%}[
	tr[
		th[XML]
		th[MinML]
		th[Output]
	]
	tr[
		td[code[+[<![CDATA[example <b>bold</b> markup]]>]]]
		td[code[+[+[example <b>bold</b> in XML]]]]
		td[+[example <b>bold</b> in XML]]
	]
	tr[
		td[code[+[<![CDATA[example b[bold] in MinML]]>]]]
		td[code[+[+[example b[bold] in MinML]]]]
		td[+[example b[bold] in MinML]]
	]
]

Unlike CDATA sections,
raw matchertext sequences nest cleanly.
Including a literal example of a CDATA section in XML markup,
for example,
is
a{href=https://en.wikipedia.org/wiki/CDATA#Nesting}[mind-meltingly painful]:

table{style=width:100%}[
	tr[
		th[XML:]
		td[code[+[<![CDATA[example <![CDATA[character data]]]]><![CDATA[> section]]>]]]
	]
	tr[
		th[Output:]
		td[+[example <![CDATA[character data]]> section]]
	]
]

Expressing a literal example
of a raw matchertext sequence code[+ <[[hellip]]] in MinML
is straightforward in contrast:

table{style=width:100%}[
	tr[
		th[MinML:]
		td[code[+[+[example +[matchertext] literal]]]]
	]
	tr[
		th[Output:]
		td[+[example +[matchertext] literal]]
	]
]


h3[Literal unmatched matchers]

The matchertext discipline has a cost, of course.
If you want to include an em[unmatched] literal
parenthesis, bracket, or curly brace in your MinML markup,
you must "[escape] it with a character reference.
You can use standard named or numeric character references,
like code[+[[lparen]]] or code[+[[#x28]]]
for an unmatched left parentheses for example.

p[]
MinML also provides an alternative, more visual syntax for unmatched matchers:
code[+[[(<)]]] and code[+[[(>)]]] for an open and close parenthesis,
respectively,
code[+[[[<]]]] and code[+[[[>]]]] for a square bracket, and
code[+[[{<}]]] and code[+[[{>}]]] for a curly brace.
You might think of the code[<] or code[>] symbol in this context
as a stand-in for the unmatched matcher that "[points] left or right
at the matcher you actually want.
The following table summarizes these various ways to express
literal unmatched matchers.

table[
	tr[
		th[]
		th{colspan=3}[Open]
		th{colspan=3}[Close]
	]
	tr[
		td[Parentheses code[()]]
		td[code[+[[lpar]]]]
		td[code[+[[#x28]]]]
		td[code[+[[(<)]]]]
		td[code[+[[rpar]]]]
		td[code[+[[#x29]]]]
		td[code[+[[(>)]]]]
	]
	tr[
		td[Square brackets code[[]]]
		td[code[+[[lbrack]]]]
		td[code[+[[#x5B]]]]
		td[code[+[[[<]]]]]
		td[code[+[[rbrack]]]]
		td[code[+[[#x5D]]]]
		td[code[+[[[>]]]]]
	]
	tr[
		td[Curly braces code[{}]]
		td[code[+[[lbrace]]]]
		td[code[+[[#x7B]]]]
		td[code[+[[{<}]]]]
		td[code[+[[rbrace]]]]
		td[code[+[[#x7D]]]]
		td[code[+[[{>}]]]]
	]
]

While having to replace unmatched matchers with character references
might seem cumbersome,
they tend not to be used often anyway in most text [ndash]
mainly just in text that is em[talking about] such characters.

p[]
Independent of the text embedding benefits discussed above,
there is another compensation for this small bother.
While editing MinML, or any matchertext language,
you may find that your highlighting text editor
or integrated development environment (IDE)
no longer em[ever] guesses wrong
about which parenthesis, bracket, or brace character
matches which other one in your source file.


h3[Metasyntax and processing instructions]

SGML-derived markup can contain metasyntactic dfn[declarations]
of the form code[<! <[hellip]>],
and dfn[processing instructions]
of the form code[<? <[hellip]?>].
MiniML provides the syntax
code[! <[[hellip]]] and
code[? <[[hellip]]], respectively,
for expressing these constructs if needed.

p[]
Since these constructs are typically used
in only a few lines at the beginning of most markup files,
if at all,
improving their syntax is not a high-priority goal for MinML.
Further,
the syntax of [ndash] and processing rules for [ndash]
document type definitions are frighteningly complex,
even in the "[simplified] XML standard.

p[]
MiniML therefore leaves the legacy syntax of the underlying markup language
unmodified within the context of these directives.
Only the outermost "[wrapper] syntax changes.
For example, a MiniML document based on XML
with a document type declaration might look like:

pre[	+[?[xml version="1.0"]]
	+[![DOCTYPE greeting SYSTEM "hello.dtd"]]
	+[greeting[Hello, world!]]
]


h2[Give MinML a try]

There is an 
a{href=https://github.com/dedis/matchertext/tree/main/go/markup/minml}[>
	experimental implementation]
in a{href=https://go.dev}[Go]
that supports parsing MinML into an abstract syntax tree (AST)
and conversion to classic HTML or XML syntax.
This repository also includes a simple
a{href=https://github.com/dedis/matchertext/tree/main/go/markup/minml/cmd}[>
	command-line tool]
to convert MinML to HTML or XML.

p[]
With
a{href=https://github.com/bford/hugo}[this experimental fork]
of the
a{href=https://gohugo.io}[Hugo] website builder,
you can use MinML source files
with extension code[.minml] or code[.m] in your website.
This blog post was written in MinML and published using Hugo this way.
Feel free to check out
a{href=index.m}[the MinML source for this post].

p[]
If you implement MinML in other languages or applications,
please let me know and I will collect and consolidate links.


h2[Conclusion]

MinML is a new "[skin] or outer syntax
for SGML-derived markup languages such as HTML and XML.
MinML preserves all of the base language's power and expressiveness,
unlike the numerous flavors of Markdown.
MinML's syntax just makes markup a bit more concise
and [ndash] at least in this author's opinion [ndash]
less annoying to write, read, or edit.
Elements never need end tags,
only a final close bracket.
Enjoy!

-[
Because MinML builds on the 
a{href=/pub/lang/matchertext/}[matchertext],
all constructs including raw literals naturally nest,
and can contain verbatim embedded strings in any compliant language
without escaping or other syntactic contortions.
While this discipline requires unmatched matchers
to be replaced with character references,
...
]


-[	Old notes:

SystemLiteral: a slight problem in principle, because in XML disallows
either single or double quotes and doesn't support markup.
But SystemLiteral is to be used to contain a URI,
which has much more restrictive syntax.
Uses URI escaping if escaping is needed.

PubidLiteral: same restricted ASCII-only character set as XML

CharData: removes stilly restriction of no '{c[]}{c[]}>' sequence

Comments: -[...]? or ![...]? or [- ... ]?
Drops the restriction that '--' must not appear within comments.
Allows character references to appear for escaping or doc-comment purposes.
When converting to XML, '--' gets escaped with character reference..
If comment text ends in '-', XML writer appends a space
to avoid producing an illegal '--->' terminator.

Processing instructions:
?[...]
Same PITarget syntax.

PI containing '?>' cannot be converted to standard XML
(or would have to be escaped via unknown application escaping syntax).
Converting to MaML must escape unmatched matchers.
Or perhaps just cause a conversion error,
given that the embedded PITarget syntax is effectively unknown
but its constraints are the constraints of the host syntax.

Just disable DTDs entirely?
Protect against XXE attacks https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html
Billion Laughs attack https://en.wikipedia.org/wiki/Billion_laughs_attack

Another strictly-backward-compatible approach would be
to process all DTDs including internal/external entity references
strictly in legacy XML syntax,
even when used (referred to in) MinML syntax.
Thus, recursive entity expansion works, in XML syntax.
MinXML files are thus processed as if first converted to legacy XML
(without doing any entity expansion at all),
then processed as legacy XML source.

Some XML dataset sources for testing:
https://catalog.data.gov/dataset/?res_format=XML
http://aiweb.cs.washington.edu/research/projects/xmltk/xmldata/
https://data.world/datasets/xml

Conditional sections:
INCLUDE is only processed as part of the DTD.  Skip.
IGNORE is ignored.  Skip.

]
