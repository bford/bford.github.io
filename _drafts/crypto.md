---
layout: post
title: An advanced crypto library for Go
---

{{ page.title }}
================

Interesting features:

* An abstract group arithmetic framework for public-key cryptography
based on the discrete logarithm problem.

* Several alternative concrete instantiations of this abstract
group arithmetic framework,
based on the NIST elliptic curve implementations in the Go standard library
and in the OpenSSL crypto library,
and implementations of both generic Edwards curves
and an adaptation of Adam Langley's Ed25519-curve-specific 
optimized group arithmetic code to the abstract group API.

* Implementations of a number of advanced crypto algorithms
built on this abstract group arithmetic framework,
and hence automatically compatible woth both integer group
and any suitable elliptic curves:

	* Shamir Verifiable Secret Sharing (VSS),
	the standard foundation for t-of-n threshold cryptographic techniques.

	* An implementation of the general Camenisch/Stadler framework
	for proofs of knowledge based on the discrete-logarithm problem.
	For example...

	* Anonymous and pseudonymous public-key encryption and signatures,
	where the sender or receiver are identified only as an anonymous member
	of some explicit *set* of public keys, without revealing anything
	about which member of the set signed the message or is to receive it.

	* C. Andrew Neff's cryptographic protocol for proving
	the correctness of a shuffle.

...


