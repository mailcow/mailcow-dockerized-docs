## Netfilter Ban-Einstellungen ändern

Um die Netfilter Ban-Einstellungen zu ändern navigieren Sie zu dem Menü Punkt: `Konfiguration -> Server-Konfiguration -> Konfiguration -> Fail2ban-Parameter`.

Sie sollten dann dieses Fenster sehen:

![Netfilter ban settings](../../assets/images/manual-guides/mailcow-netfilter_settings.de.png)

Hier können Sie verschiedene Optionen für die Banns selbst festlegen. 
Zum Beispiel die max. Ban-Zeit oder die max. Versuche bevor ein Ban ausgeführt wird.


## Netfilter Regex ändern

!!! danger "Achtung"
	Folgender Bereich erfordert zumindest grundlegende Regex kenntnisse. <br>
	Sollten Sie sich nicht sicher sein, was Sie dort tun, können wir Ihnen nur von der Umkonfiguration abraten.

Sie können neben den Sperreinstellungen ebenfalls definieren, was genau aus den Logs der mailcow Container verwendet werden soll um einen möglichen Angreifer zu sperren.

Dafür müssen Sie das Regex Feld erst einmal aufklappen, was dann in etwa so aussieht:

![Netfilter Regex](../../assets/images/manual-guides/mailcow-netfilter_regex.de.png)
	
Dort können Sie nun verschiedenste neue Filter-Regeln anlegen.

!!! info "Hinweis"
	Mit weiterschreitenden Updates ist es möglich, dass neue Netfilter Regex Regeln dazu kommen oder entfernt werden. <br>
	Sollte das der Fall sein empfiehlt es sich mit einem Klick auf `Zurücksetzen auf Standard` die Netfilter Regex Regeln neu laden zu lassen.