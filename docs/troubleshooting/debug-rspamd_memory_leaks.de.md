Eine kurze Anleitung, um einen schlecht funktionierenden Rspamd tiefgehend zu analysieren.

```
docker compose exec rspamd-mailcow bash

if ! grep -qi 'apt-stable-asan' /etc/apt/sources.list.d/rspamd.list; then
  sed -i 's/apt-stabil/apt-stabil-asan/i' /etc/apt/sources.list.d/rspamd.list
fi

apt-get update ; apt-get upgrade rspamd

nano /docker-entrypoint.sh

# Fügen Sie vor "exec "$@"" die folgenden Zeilen ein:

export G_SLICE=always-malloc
export ASAN_OPTIONS=new_delete_type_mismatch=0:detect_leaks=1:detect_odr_violation=0:log_path=/tmp/rspamd-asan:quarantine_size_mb=2048:malloc_context_size=8:fast_unwind_on_malloc=0

```

Starten Sie Rspamd neu: `docker compose restart rspamd-mailcow`

Ihr Speicherverbrauch wird stark ansteigen, er wird auch stetig wachsen, was nicht mit einem möglichen Memory Leak zusammenhängt, nach dem Sie suchen.

Lassen Sie den Container für ein paar Minuten, Stunden oder Tage laufen (es sollte die Zeit sein, die Sie normalerweise warten, bis der Memory Leak "passiert") und starten Sie ihn neu: `docker compose restart rspamd-mailcow`.

Betreten Sie nun den Container, indem Sie `docker compose exec rspamd-mailcow bash` ausführen, wechseln Sie das Verzeichnis zu /tmp und kopieren Sie die asan-Dateien an den gewünschten Ort oder laden Sie sie über termbin.com hoch (`cat /tmp/rspamd-asan.* | nc termbin.com 9999`).