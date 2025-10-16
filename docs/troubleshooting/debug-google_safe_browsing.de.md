Seit einiger Zeit erreichen uns vermehrt Reports, dass die mailcow UI bei einigen Nutzern nicht mehr erreichbar ist. Stattdessen wird eine Google SafeBrowsing Seite angezeigt, die darauf hinweist, dass die Seite als unsicher eingestuft wurde.

Dies tritt auch dann auf, wenn Sie selber keine SafeBrowsing Filterung für Ihre Webseite aktiviert haben.
<figure markdown>
![Beispielhafte Darstellung der Google SafeBrowsing Seite](../assets/images/troubleshooting/debug-google_safe_browsing.png)
<figcaption>Beispielhafte Darstellung der Google SafeBrowsing Seite</figcaption>
</figure>

## Ursache
Leider ist Google was die Einstufung von Webseiten angeht nicht immer ganz transparent.
Es gibt verschiedene Gründe, warum eine Webseite als unsicher eingestuft werden kann, z.B.:

- Malware auf der Webseite
- Phishing-Versuche
- Unangemessene Inhalte

Bei mailcow ist es jedoch sehr unwahrscheinlich, dass diese Gründe zutreffen, es sei denn, Ihr Server wurde wirklich kompromittiert.

Da dies aber auch bei Seiten auftritt die frisch mailcow installiert wurden, liegt die Ursache meist woanders.

Wir vermuten, dass Google seit einiger Zeit ein neues KI Modell zur erkennung der SafeBrowsing Filterung einsetzt und dieses bei ähnlichen Seiten wie mailcow Installationen (da das Login UI von mailcow eine ähnliche Struktur aufweist pro Server) fälschlicherweise anschlägt.

## Mögliche Lösungen
1. Halten Sie ihre mailcow Installation aktuell, da wir stetig daran arbeiten, bekannte Sicherheitslücken zu schließen.
2. Fügen Sie ein Logo zu Ihrer mailcow Installation hinzu, das eindeutig Ihre Organisation oder Ihre Domain repräsentiert. Dies kann helfen, die Vertrauenswürdigkeit Ihrer Seite zu erhöhen.
3. Fügen Sie ein Impressum oder einen Footer Text hinzu, dieser hilft auch die Unterscheidung zu anderen mailcow Installationen zu verbessern.
4. Kontaktieren Sie den Google Support und bitten Sie um eine Überprüfung Ihrer Seite. Dies kann jedoch einige Zeit in Anspruch nehmen.

!!! info "Hinweis"
    Es gibt keine Garantie, dass diese Maßnahmen erfolgreich sind, da die Einstufung durch Google automatisiert erfolgt und nicht immer nachvollziehbar ist.
    Es ist jedoch einen Versuch wert, insbesondere wenn Sie mailcow für geschäftliche Zwecke nutzen.

    **Seien Sie sich bewusst, dass wir alles in unserer Macht stehende tun, um die Sicherheit und Integrität von mailcow zu gewährleisten.**
