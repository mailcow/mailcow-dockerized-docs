mailcow verwendet für die Benachrichtigungs-Mails die Template-Engine [Jinja](https://jinja.palletsprojects.com/).
Durch Platzhalter können mit diesen Templates dynamische Inhalte erzeugt werden, indem bei der Ausführung diese Platzhalter mit übergeben Variablen ersetzt werden. Eine Doku zur Entwicklung von Jinja Templates findet sich [hier](https://jinja.palletsprojects.com/en/3.1.x/templates/). 

Für die Templates der Benachrichtungs-Emails können die folgenden Variablen verwendet werden:

## Quarantäne Template 

Die bereitgestellten Variablen können auch auf GitHub aus dem Script [dovecot/quarantine_notify.py](https://github.com/mailcow/mailcow-dockerized/blob/master/data/Dockerfiles/dovecot/quarantine_notify.py#L94) entnommen werden.

!!! info 
    Das Template für die Qarantäne Mails kann man als Administrator in der Benutzeroberfläche in den globalen Quarantäne-Einstellungen bearbeiten und dort ebenso das Standard Template wiederherstellen. 
    Code Beispiele kann man dem Standard Template entnehmen. Es kann auch auf [Github](https://github.com/mailcow/mailcow-dockerized/blob/master/data/assets/templates/quarantine.tpl) eingesehen werden.


| Name           	| Inhalt                                                                                               	|
|----------------	|------------------------------------------------------------------------------------------------------	|
| username       	| E-Mail Adresse des Mailbox Benutzers                                                                 	|
| counter        	| Anzahl der Nachrichten in der Quarantäne, über die in dieser Mail benachrichtigt wird                	|
| hostname       	| Name der Mailcow Instanz (Siehe auch die Umgebungsvariable _MAILCOW_HOSTNAME_)                       	|
| quarantine_acl 	| Einstellung der Quarantäne ACL des Benutzers (Berechtigung zur Bearbeitung von Mails in der Quarantäne) 	|
| meta           	| Array/Liste aller Nachrichten/Einträge in der Quarantäne, über die benachrichtigt wird               	|
| meta.qhash     	| Hashwert des Quarantäne Eintrags (Bspw für Direktlink zur Nachricht in der Quarantäne)               	|
| meta.id        	| ID des Quarantäne Eintrags                                                                           	|
| meta.subject   	| Titel der E-Mail des Quarantäne Eintrags                                                             	|
| meta.score     	| Spam Score der E-Mail des Quarantäne Eintrags                                                        	|
| meta.sender    	| Absender Adresse der E-Mail des Quarantäne Eintrags                                                  	|
| meta.created   	| Datum der Erstellung des Quarantäne Eintrags, bzw Empfang der E-Mail                                 	|
| meta.action    	| Aktion des Spamfilters (Verschoben in Spam-Ordner oder in die Quarantäne)                            	|

## Quota Template

Die bereitgestellten Variablen können auch auf Github aus dem Script [dovecot/quota_notify.py](https://github.com/mailcow/mailcow-dockerized/blob/master/data/Dockerfiles/dovecot/quota_notify.py#L45) entnommen werden.

!!! info 
    Das Template für die Quota Mails kann man als Administrator in der Benutzeroberfläche in den Quota-Einstellungen bearbeiten und dort ebenso das Standard Template wiederherstellen. 
    Code Beispiele kann man dem Standard Template entnehmen. Es kann auch auf [Github](https://github.com/mailcow/mailcow-dockerized/blob/master/data/assets/templates/quota.tpl) eingesehen werden.

| Name           	| Inhalt                                                                                               	|
|----------------	|------------------------------------------------------------------------------------------------------	|
| username       	| E-Mail Adresse des Mailbox Benutzers                                                                 	|
| percent        	| Prozentualer Anteil des belegten Speicherplatzes der Mailbox                                        	|

