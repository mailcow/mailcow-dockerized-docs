IPs können in der Datei `data/conf/postfix/custom_postscreen_whitelist.cidr` aus dem Postscreen und damit _auch_ aus den RBL-Prüfungen entfernt werden.

Postscreen führt mehrere Prüfungen durch, um bösartige Absender zu identifizieren. In den meisten Fällen möchten Sie eine IP-Adresse auf die Whitelist setzen, um sie von der Suche nach einer schwarzen Liste auszuschließen.

Das Format der Datei ist wie folgt

`CIDR ACTION`

Dabei steht CIDR für eine einzelne IP-Adresse oder einen IP-Bereich in CIDR-Notation und action entweder für "permit" oder "reject".

Beispiel:

```
# Regeln werden in der angegebenen Reihenfolge ausgewertet.
# Schwarze Liste 192.168.* außer 192.168.0.1.
192.168.0.1 permit
192.168.0.0/16 reject
```

Die Datei wird spontan neu geladen, ein Neustart von Postfix ist nicht erforderlich.