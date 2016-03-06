---
layout: post
title: Apple versus FBI and Software Transparency
---

{{ page.title }}
================

The Apple versus FBI showdown[] has quickly become
one of the most crucial flashpoints of the ``New Crypto Wars''[].
In brief, the FBI invoked the All Writs Act,
a catch-all provision for assistance of law enforcement
dating from shortly after the Constitution and Bill of Rights were ratified,
to demand that Apple create a custom version of its iOS
to help the FBI decrypt the contents of an employer-provided iPhone
used by one of the San Bernardino killers.
While the FBI most certainly has the expertise in-house
to create such a backdoored version of iOS,
Apple's devices are designed to reject any modified version of iOS
unless it is digitally signed with a secret key
that presumably only Apple controls.
*Presumably*.  We'll come back to that.

One of the most interesting and unusual features of this particular legal case
is *how quickly the public learned about it*.
The FBI could have quietly delivered this order under seal,
as it has done with similar decryption-assistance demands [to apple]
and [to other companies].
Apple even reportedly[] *requested* that the order be sealed,
but the FBI chose to to create a big, public showdown.
The facts of the case undermine the FBI's claims
of this particular iPhone's importance to fight terrorism:
e.g., that the killers are already long dead,
that the mountain of metadata the FBI already has about the killers
revealed no hint of connections to other terrorists,
and that the iPhone in question was an employer-provided work phone
that the killers did not bother to destroy
as they did their two personal phones[].
The unmistakable Occam's Razor conclusion from these facts,
as many have concluded[],
is that the FBI is far less interested in the data
than in the court precedent from winning such a public battle.

In short, it appears [the FBI is playing politics],
carefully choosing a battleground on which they think they can win
[using the terrorism card],
even if the specific iPhone in question has little or no intelligence value.

The Secrecy Alternative
-----------------------

Important as this public battle is, however,
we should not forget that the FBI and other government agencies
around the world
can and often have pursued the same goals outside the light of public scrutiny.
In this regard, the Apple versus FBI is the exception, not the rule.
We must remember the result of the last major public battle
over encryption backdoors:
the first ``Crypto Wars'',
in which the US government attempted to impose on everyone
a key escrow encryption system embodied in the infamous [Clipper Chip].
While the government lost the public battle,
we know now from Snowden's revelations
that the government did not give up on their goals of compromising encryption.
Instead they merely moved their efforts back into the shadows,
for example by successfully slipping a backdoored random number generator
into a NIST standard,
allowing them -
or any hacker managing to re-key the backdoor[] -
to compromise all cryptographic algorithms on a device[].

Even if we win this next public round of the Crypto Wars,
we can count on continued attempts by the US and governments around the world
to aquire secret backdoors.
Governments can of course exploit software[] bugs or physical attacks[]
to break into personal devices,
but secret backdoors will continue to be most attractive:
it is much easier and less risky
to exploit a security flaw *you inserted*
than an accidental flaw you must find and design an exploit for.

In the case of Apple's devices,
there is a technologically straightforward way the US government could
secretly aquire a universal backdoor to Apple's devices:
simply demand a copy of Apple's secret software and firmware signing keys.
The government already showed a willingness to do exactly this,
in demanding the secret master keys to Lavabit's encrypted E-mail service
while investigating Snowden.
This might not be entirely trivial if Apple's software signing keys
are held in [hardware security modules]
designed to thwart the extraction or cloning of secret keys.
In that case, however, the government could instead
simply bring its backdoored version of iOS to Apple
and demand that Apple produce the required digital signature for it,
while keeping this entire process
and the existence of this backdoored iOS secret.

Even if Apple wins this public battle, therefore,
they will still rightfully face post-Snowden fears and suspicions -
from companies and governments around the world -
as to whether Apple can still be secretly coerced into
helping to sign backdoored software and firmware images.
And this risk is by no means specific to Apple,
but faced by any organization that creates and releases software.
This risk even broadly applies to open source software,
because you cannot be certain whether a software update
represents a correctly-compiled or backdoored version of a source release
unless you compile it yourself, which precious few users do.

Software Transparency via Decentralized Witness Cosigning
---------------------------------------------------------

In a paper to appear in May at IEEE Security & Privacy 2016
(a preliminary draft is available here),
we introduce *decentralized witness cosigning*,
a technological mechanism by which Apple
and other software and firmware makers
could protect their users from secretly backdoored versions of their software -
and thereby protect *themselves* and their finanical bottom lines from
worldwide fears and suspicions about the possibility of backdoored software.

With conventional digital signatures,
as currently used for most software and firmware signing processes,
a single party (e.g., Apple) holds the secret key
needed to produce valid software images
that devices and their software update mechanisms will accept.
Any well-designed update mechanism refuses to accept any software image
unless it has been authenticated using a *digital certificate*
embedded in the device,
which cryptographically identifies the software maker
via a mathematical relationship with the secret signing key,
It is already a security best-practice
for software makers to keep sensitive software signing keys offline -
perhaps in HSMs or even split across multiple HSMs -
but such measures do not prevent the *organization* from being coerced
into secret misuses of these signing keys.

With decentralized witness cosigning, in contrast,
a software maker imprints their devices and software update mechanisms
with a digital certificate corresponding not just to their own secret key
but also to secret keys held by a group of independent *witnesses*.
These witnesses might include other cooperating software companies,
public-interest organizations such as ALCU, EFF, or CDT,
or major corporate customers or governments around the world
desiring not just verbal but also technological assurances
of the software maker's commitment to transparency.
In turn, before accepting any software image
the device's update mechanism verifies that it has been signed
not only by the software maker but also by a threshold number
(e.g., at least two-thirds) of the designated group of witnesses.
In essence, the device does not accept any software image
unless it arrives with a cryptographic ``proof''
that this *particular* software image has been publicly observed by -
and placed under the scrutiny of -
a large, decentralized group of independent parties around the world.

Of course,
independent witnesses cannot necessarily determine immediately
whether or not a particular software image actually contains a backdoor,
especially in the common case where the source code is proprietary
and the software maker signs and releases only binary images.
Nevertheless, the witnesses can still proactively ensure *transparency*
by ensuring that *every correctly-signed software image in existence*
has been disclosed, cataloged, and subjected to public scrutiny.
For example, if future Apple devices adopted decentralized witness cosigning,
and the FBI attempted to coerce Apple secretly into signing
a backdoored version of iOS version 11.2.1,
then the only way Apple could do so would be to submit
the backdoored iOS version to the independent witnesses for cosigning.
Even though those witnesses could not necessarily recognize the backdoor,
they would immediately notice that two different iOS images
labeled "version 11.2.1" have been signed
(the standard one and the backdoored one),
immediately raising alarms and drawing the attention of security companies
around the world to perform a careful inspection
of the differences between the two software images.
The FBI could of course coerce Apple to give the backdoored image
a different version number that most customers never receive
(e.g., "11.2.1LE" or "11.2.1.1") -
but the witnesses would still be able to tell that an iOS image *exists*
that has been signed but not widely distributed,
again likely drawing suspicion and careful public scrutiny.

Proactive versus Retroactive Transparency
-----------------------------------------

Decentralized witness cosigning is by no means the first
cryptographic transparency mechanism.
For example, the Public Key Infrastructure (PKI)[]
used to secure Web connections has long been known to have similar weaknesses,
and PKI transparency mechanisms such as [Moxie's],
Certificate Transparency, AKI/ARPKI, etc.
have been been proposed proposed as part of this problem.
Certificate Transparency is now a standard part of the Chrome browser.
Related mechanisms such as Perspectives[] and CONIKS[]
address the closely-related problem of transparently binding
users' names, E-mail addresses, or telephone numbers to
the cryptographic keys needed to support end-to-end encrypted messaging.

All of these prior transparency mechanisms have a crucial weakness, however:
they can only *retroactively* detect if a secret signing key has been misused.
Existing transparency mechanisms do not substantially increase
the number of independent signing keys an attacker must control
before a device accepts a compromised software image or PKI certificate,
but instead rely on the victim device
to communicate actively or *gossip* the images or certificates it has seen
with other entities on the Internet -
*after* the victim has already accepted the compromised digital signature.

This retroactive transparency approach has two critical weaknesses,
which are especially severe with respect to the software transparency problem
at issue in the Apple versus FBI case.
First, if the device accepts and starts running a backdoored software update
before the device has had a chance to gossip
information about the update with other parties on the Internet,
then the backdoored software can be designed to evade transparency
simply by disabling the retroactive transparency mechanism in the code.
Second, even if the attacker neglects to take this step,
or cannot for whatever reason,
the attacker can still evade transparency if the attacker is in control
of the device or its only Internet access paths.
In the FBI versus Apple case, for example,
the FBI could trivially evade a retroactive transparency mechanism
and keep a backdoored iOS image secret
simply by keeping the device disconnected from the rest of the Internet
when installing their backdoored software update.

This weakness of retroactive transparency approaches
also applies to attackers who may not control the device itself
but only the device's Internet access path.
For example, a compromised Internet service provider (ISP)
or corporate Internet gateway can defeat retroactive transparency mechanisms
by persistently blocking a victim device's access
to transparency servers elsewhere on the Internet.
Even if the user's device is mobile,
a state intelligence service such as China's ``Great Firewall''[]
could defeat retroactive transparency mechanisms by persistently blocking
connections from a targeted victim's devices to external transparency servers,
in the same way that China already blocks connections to many websites[]
and the Tor anonymity network[], for example.

Decentralized witness cosigning solves these weaknesses
by providing *proactive transparency*,
enabling devices to verify a standalong cryptographic ``proof of transparency''
*before* accepting or relying on the software update in any way.
Thus, with decentralized witness cosigning,
companies such as Apple can offer a strong guarantee to their customers
that every software images they ever sign is publicly disclosed
before any of their devices, anywhere, will consider it valid -
even if the device and/or its network connectivity
is completely under the attacker's control.

