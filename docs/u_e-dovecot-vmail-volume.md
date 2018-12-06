If you want to use another folder for the vmail-volume, you can create an `docker-compose.override.yml` file and add:
```
version: '2.1'
volumes:
  vmail-vol-1:
    driver_opts:
      type: none
      device: /data/mailcow/vmail
      o: bind
```

Moving an existing vmail folder:
- Locate the current vmail folder by its "Mountpoint" attribute: `docker volume inspect mailcowdockerized_vmail-vol-1` 
- Copy the `_data` folder to the new folder using `cp -a`, `rsync -a` or a similar non strcuture breaking copy command
- Stop mailcow by executing `docker-compose down` from within your mailcow root folder (e.g. "/opt/mailcow-dockerized")
- Create the file `docker-compose.override.yml`
- Delete the current vmail folder: `docker volume rm mailcowdockerized_vmail-vol-1`
- Start mailcow by executing `docker-compose up -d` from within your mailcow root folder (e.g. "/opt/mailcow-dockerized")
