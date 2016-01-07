---
layout: post
title: Backdoors, Trusted Servers, and Deanonymization
---

{{ page.title }}
================

To my knowledge there are currently only two fundamentally distinct approaches
to achieving strong anonymity online,
and the same legendary computing figure, David Chaum,
pioneered both.
His first approach,
[mixes](http://www.freehaven.net/anonbib/cache/chaum-mix.pdf),
relay messages over multi-hop paths around the network
to obscure their source and destinations.
State-of-the-art deployed anonymity systems such as
[Tor](https://www.torproject.org/)
are highly evolved and performance-optimized variants
of this basic relaying idea.

Chaum's second approach,
[dining cryptographers](http://www.freehaven.net/anonbib/cache/chaum-dc.pdf),
instead uses information-coding principles to hide the sender of a message
among a group of nodes all of whom seem to be spewing gibberish at once.
It's as if you are listening to a crowd
[speaking in tongues](http://www.christianpublishers.org/Speaking%20in%20Tongues-1.jpg)
but what you hear is a single unified voice,
emanating from no one in particular,
elucidating the Ten Commandments with perfect clarity.
Chaum then moved away from anonymity systems
to other projects such as the first major attempt at practical electronic cash
(yes, he was also the "first" Satoshi Nakamoto),
and secure electronic voting systems.
While several research projects,
including Cornell's
[Herbivore](https://www.cs.cornell.edu/people/egs/herbivore/)
and my own
[Dissent](http://dedis.cs.yale.edu/dissent/)
have made progress toward making the dining cryptographers practical,
it has not (yet) made it into widely-deployed systems.

Given Chaum's status as "the father of online anonymity",
it stands to reason
that his first venture *back* into anonymity in many years
would get some attention.
Today at [Real World Crypto](http://www.realworldcrypto.com/rwc2016),
he presented
[cMix](http://eprint.iacr.org/2016/008.pdf),
an interesting new take on the mix approach
that aims to achieve better scalability, lower latencies,
and sufficiently low computation costs on client devices
to be practical for use in energy-conscious mobile phone apps.
I had the pleasure of learning about cMix directly from David
and discussing it with him at some length last year,
but my recent move to [EPFL](http://www.epfl.ch/) and other time demands
prevented me from being able to take a more active role in the project.
The design of cMix is definitely interesting and contains some promising ideas,
but that is not what this blog post is about.

Ending the Crypto War, or Stoking the Flames?
---------------------------------------------

Earlier today before Chaum's talk, Wired also released
[an article on it](http://www.wired.com/2016/01/david-chaum-father-of-online-anonymity-plan-to-end-the-crypto-wars/)
containing a statement that will doubtless attract
a lot more attention than anything in the technical paper on cMix:

	Chaum is also building into PrivaTegrity another feature that’s sure to be far more controversial: a carefully controlled backdoor that allows anyone doing something “generally recognized as evil” to have their anonymity and privacy stripped altogether.

Well before Chaum's talk even began,
Twitter was ablaze with discussion about Chaum's "backdoor" in PrivaTegrity.

<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">The main benefit of Chaum&#39;s new system, as far as I can tell, is that it is a political gift to FBI Director Comey. <a href="https://t.co/64Au0lXxuL">https://t.co/64Au0lXxuL</a></p>&mdash; Christopher Soghoian (@csoghoian) <a href="https://twitter.com/csoghoian/status/684730483503149056">January 6, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">I&#39;m heartbroken to see that Chaum is proposing key escrow for everyone on the planet: <a href="https://t.co/zWZ3bUQsJf">https://t.co/zWZ3bUQsJf</a> What happened to David Chaum?</p>&mdash; Jacob Appelbaum (@ioerror) <a href="https://twitter.com/ioerror/status/684763375260270592">January 6, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

But Where's the Backdoor?
-------------------------

One important observation, however, is that the word "backdoor"
appears nowhere in the actual
[technical paper on cMix](http://eprint.iacr.org/2016/008.pdf) written by
Chaum and his collaborators.
While cMix is the anonymous communication protocol Chaum is proposing,
PrivaTegrity is a larger system built on cMix
to provide anonymous chat and other anonymous interaction applications
directly usable to ordinary users.
In essence, cMix is just an "engine" whereas PrivaTegrity is the car.
So where is this supposed "backdoor" &emdash; in the engine or the car?

The only part of the technical cMix paper that even suggests
the "backdoor" idea (without using that term)
is section IX.B., two brief paragraphs on the paper's second-to-last page.
The first is the most crucial:

	Independent from cMix, PrivaTegrity addresses potential
abuse of anonymity services by establishing a trust model
that offers a balance of anonymity and accountability. On the
one hand, PrivaTegrity aims to provide privacy at a technical
level that is not penetrable by nation states. On the other
hand, PrivaTegrity aims to provide integrity, both prior restraint
and accountability after the fact, that is inescapably tied to
individuals. Only if all of the mixing nodes cooperate, can the
senders and receivers of messages be linked or identified.

In essence, cMix routes users' messages through a series of mixing nodes
(the Wired article talks about nine servers in different countries),
such that none of the servers can individually unmask an anonymous user,
but all of the servers (or their operators) together can unmask a user
that they collectively agree to be deserving of such treatment.

This property is by no means new, unusual, or unique to cMix, however:
in fact a huge number of cryptographic and distributed systems
have this essential security property.
No one really knows how to build secure systems
in which you need to trust *no one at all*.
Instead the best we can really do is to *split* trust across multiple entities
that we hope are at least somewhat independent,
so that no one entity needs to be fully trusted.

This is exactly the same security principle that motivates
[safes with two keys](http://www.deansafe.com/uncodrsawisa.html).
If both keys are required to open the safe and are held by different employees,
then a single dishonest employee working alone will be unable to raid it
without somehow aquiring the other key.
But if the two key-holders conspire,
the two-key mechanism will do nothing to stop them.

Trust Splitting in Anonymity Systems
------------------------------------

Essentially all of the practical anonymity systems,
both deployed and proposed in research,
embody this limited trust-splitting property in some fashion.
Several years ago my group
[coined the term "anytrust"](http://dedis.cs.yale.edu/dissent/papers/eurosec12-abs)
for this security model in the context of anonymity systems,
because users need only assume that "any one" of the servers is honest
and not colluding with all the others against them.
Users don't even need to know or guess which server is honest;
one merely *needs to exist*.
Once again, we did not by any means invent this security model;
it has been in use in many ways and under many names for decades
in cryptography and distributed systems practice.

Users of the well-known [Tor](https://www.torproject.org/) anonymity system,
for example,
depend for their security on a small group of 
*directory authorities* &emdash;
of which [there are currently 10](https://twitter.com/kristovatlas/status/684845884576796673) &emdash;
to keep track of and let Tor clients know the set of relays
available to help anonymize their messages.
If ...


PrivaTegrity

is Chaum's "backdoor" a technical feature?
no, just a common architectural weakness.

Tor has it... (examples)

Can we eliminate such trusted server groups?  Yes, but it's hard.

Does CT fix it?  Not quite.



The policy question: are backdoors needed/good in an anonymity systems?

What would the processes be for controlled deanonymization of a user,
supposing one created a system and set it up like Chaum's
on the (policy) basis that server operators would cooperate
to deanonymize users under "the right conditions"?

who picks those 9 server operators?  Who funds them?
(The power of the purse is strong...)
If a nation-state comes to them and says, 
"we'll block your service and thus destroy a big part of your legal business
unless you help us deanonymize these people who we call 'terrorists'
but the rest of the world calls 'political dissidents'",
what do they do?

sybil problem, multiple possible levels of response...

