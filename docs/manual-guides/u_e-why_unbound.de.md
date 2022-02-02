Für DNS-Blacklist-Lookups und DNSSEC.

Die meisten Systeme verwenden entweder einen öffentlichen oder einen lokalen DNS-Auflöser mit Zwischenspeicher.
Das ist eine sehr schlechte Idee, wenn es darum geht, Spam mit DNS-basierten Blackhole-Listen (DNSBL) oder ähnlichen Techniken zu filtern.
Die meisten, wenn nicht alle Anbieter wenden eine Ratenbegrenzung an, die auf dem DNS-Resolver basiert, der für die Abfrage ihres Dienstes verwendet wird.
Wenn Sie einen öffentlichen Resolver wie Google 4x8, OpenDNS oder einen anderen gemeinsam genutzten DNS-Resolver wie den Ihres Internetanbieters verwenden, werden Sie diese Grenze sehr bald erreichen.