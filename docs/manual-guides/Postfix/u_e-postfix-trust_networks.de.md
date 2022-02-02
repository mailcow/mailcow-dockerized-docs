Standardmäßig betrachtet mailcow **alle Netzwerke als nicht vertrauenswürdig**, ausgenommen seine eigenen IPV4_NETWORK und IPV6_NETWORK Bereiche. Obwohl dies in den meisten Fällen vernünftig ist, kann es Umstände geben, unter denen man diese Einschränkung lockern muss.

Standardmäßig verwendet mailcow `mynetworks_style = subnet` um interne Subnetze zu bestimmen und lässt `mynetworks` unkonfiguriert.

Wenn Sie sich entscheiden, `mynetworks` zu setzen, ignoriert Postfix die mynetworks_style Einstellung. Das bedeutet, dass Sie die Bereiche IPV4_NETWORK und IPV6_NETWORK sowie die Loopback-Subnetze manuell hinzufügen müssen!

## Unauthentifiziertes Relaying

!!! warning
    Eine falsche Einstellung von `mynetworks` erlaubt es Ihrem Server, als offenes Relay verwendet zu werden. Wenn dies missbraucht wird, **beeinträchtigt** dies Ihre Fähigkeit, E-Mails zu versenden, und es kann einige Zeit dauern, bis dies behoben ist.

### IPv4-Hosts/Subnetze

Um das Subnetz `192.168.2.0/24` zu den vertrauenswürdigen Netzwerken hinzuzufügen, können Sie die folgende Konfiguration verwenden, abhängig von Ihren IPV4_NETWORK und IPV6_NETWORK Bereichen:

Bearbeiten Sie `data/conf/postfix/extra.cf`:

```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 192.168.2.0/24
```

Führen Sie `docker-compose restart postfix-mailcow` aus, um Ihre neuen Einstellungen zu übernehmen.

### IPv6-Hosts/Subnets

Das Hinzufügen von IPv6-Hosts erfolgt auf die gleiche Weise wie bei IPv4, allerdings muss das Subnetz in eckige Klammern `[]` gesetzt und die Netzmaske angehängt werden.

Um das Subnetz 2001:db8::/32 zu den vertrauenswürdigen Netzwerken hinzuzufügen, können Sie die folgende Konfiguration verwenden, abhängig von Ihren IPV4_NETWORK- und IPV6_NETWORK-Bereichen:

Bearbeiten Sie `data/conf/postfix/extra.cf`:

``` 
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 [2001:db8::]/32
```

Führen Sie `docker-compose restart postfix-mailcow` aus, um Ihre neuen Einstellungen zu übernehmen.

!!! Info
    Weitere Informationen über mynetworks finden Sie in der [Postfix-Dokumentation](http://www.postfix.org/postconf.5.html#mynetworks).

Übersetzt mit www.DeepL.com/Translator (kostenlose Version)