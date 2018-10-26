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

The process to move the vmail folder is:
Locate the current vmail folder: `docker volume inspect mailcowdockerized_vmail-vol-1` 
Copy the `_data` folder to the new folder using `cp -a`
Stop Mailcow by executing (from the Mailcow root folder) `docker-compose down`
Create the file `docker-compose.override.yml`
Delete the current vmail folder: `docker volume rm mailcowdockerized_vmail-vol-1`
Start Mailcow by executing (from the Mailcow root folder) `docker-compose up -d`

