### Backup

This line backups the vmail directory to a file backup_vmail.tar.gz in the mailcow root directory:
```
cd /path/to/mailcow-dockerized
docker run --rm -i -v $(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/vmail" }}{{ .Name }}{{ end }}{{ end }}' $(docker-compose ps -q dovecot-mailcow)):/vmail -v ${PWD}:/backup debian:stretch-slim tar cvfz /backup/backup_vmail.tar.gz /vmail
```

You can change the path by adjusting ${PWD} (which equals to the current directory) to any path you have write-access to.
Set the filename `backup_vmail.tar.gz` to any custom name, but leave the path as it is. Example: `[...] tar cvfz /backup/my_own_filename_.tar.gz`

### Restore
```
cd /path/to/mailcow-dockerized
docker run --rm -it -v $(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/vmail" }}{{ .Name }}{{ end }}{{ end }}' $(docker-compose ps -q dovecot-mailcow)):/vmail -v ${PWD}:/backup debian:stretch-slim tar xvfz /backup/backup_vmail.tar.gz
```