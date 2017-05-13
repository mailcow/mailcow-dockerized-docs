For DNS blacklist lookups and DNSSEC.

Most systems use either a public or a local caching DNS resolver.
That's a very bad idea when it comes to filter spam using DNS-based black hole lists (DNSBL) or similar technics.
Most if not all providers apply a rate limit based on the DNS resolver that is used to query their service.
Using a public resolver like Googles 4x8, OpenDNS or any other shared DNS resolver like your ISPs will hit that limit very soon.
