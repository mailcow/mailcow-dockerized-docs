Es ist möglich, Pre- und Post-Update-Hooks zum `update.sh` Skript hinzuzufügen, das Ihre gesamte mailcow-Installation aktualisiert.

Um dies zu tun, fügen Sie einfach das entsprechende Bash-Skript in Ihr mailcow-Root-Verzeichnis ein:  

* `pre_update_hook.sh` für Befehle, die vor dem Update laufen sollen
* `post_update_hook.sh` für Befehle, die nach dem Update ausgeführt werden sollen

Beachten Sie, dass `pre_update_hook.sh` jedes Mal ausgeführt wird, wenn Sie `update.sh` aufrufen, und `post_update_hook.sh` wird nur ausgeführt, wenn die Aktualisierung erfolgreich war und das Skript nicht erneut ausgeführt werden muss.

Die Skripte werden von der Bash ausgeführt, ein Interpreter (z.B. `#!/bin/bash`) sowie ein Execute Permission Flag ("+x") sind nicht erforderlich.