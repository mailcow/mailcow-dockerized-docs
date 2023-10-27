Standardmäßig betrachtet mailcow's Postfix **alle Netzwerke als nicht vertrauenswürdig**, ausgenommen seine eigenen IPV4_NETWORK und IPV6_NETWORK Bereiche, die in `mailcow.conf` festgelegt sind. Obwohl dies in den meisten Fällen vernünftig ist, kann es Umstände geben, unter denen Sie einen Host oder ein Subnetz als **unauthentifizierten Relayer** hinzufügen möchten.

Standardmäßig verwendet mailcow `mynetworks_style = subnet` um interne Subnetze zu bestimmen und lässt `mynetworks` unkonfiguriert.

Wenn Sie sich entscheiden, `mynetworks` selbständig in der `extra.conf` von Postfix zu setzen, ignoriert Postfix die mynetworks_style Einstellung. Das bedeutet, dass Sie die von mailcow intern benutzen IPv4- und IPv6-Adressen (in der `mailcow.conf` angegeben als IPV4_NETWORK bzw. IPV6_NETWORK), sowie die Loopback-Subnetze manuell hinzufügen müssen!

!!! abstract "Erläuterung"
    Die Einstellung `mynetworks` erlaubt es eingetragenen Hosts bzw. Subnets **OHNE** Authentifizierung E-Mails an den Postfix MTA zu schicken. Insbesondere dann praktisch, wenn bspw. Monitoring E-Mails von Linux Servern im selben Netzwerk ohne extra Authentifizierung verschickt werden sollen.

!!! danger "Achtung"
    Eine falsche Einstellung von `mynetworks` erlaubt es Ihrem Server, als offenes Relay verwendet zu werden. Wenn dies missbraucht wird, **beeinträchtigt** dies Ihre Fähigkeit, E-Mails zu versenden, und es kann einige Zeit dauern, bis dies abgeklungen ist.

!!! example "Beispiel"
    Als Beispiel nehmen wir das Subnetz `192.168.2.0/24`, welches wir unauthentifiziert Relayen lassen wollen.

Bearbeiten Sie `data/conf/postfix/extra.cf`:

```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 192.168.2.0/24
```

!!! warning "Vorsicht"
    Die Subnetze vor unserem angehangenen Beispiel Subnetz **MÜSSEN** vor oder nach den eigens eingetragenen Werten stehen, da sonst einige mailcow Komponenten wie bspw. der Watchdog oder einige Sieve Filter (wie bspw. Abwesenheitsagenten) nicht funktionieren und Fehler beim Betriebsablauf entstehen.

Führen Sie nach Ihren Änderungen folgenden Befehl aus aus, um Ihre neuen Einstellungen zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

!!! tip "Gut zu wissen!"
    IPv6 Adressen **MÜSSEN** in diesem Fall mit `[]` (Eckigen Klammern) als `mynetworks` Parameter eingetragen werden, da diese sonst nicht verarbeitet werden können.

!!! Info
    Weitere Informationen über mynetworks finden Sie in der [Postfix-Dokumentation](http://www.postfix.org/postconf.5.html#mynetworks).
