!!! danger "Only perform if necessary"
    This guide is intended for advanced users who need to troubleshoot SOGo issues. Using nightly builds can lead to instability and is not recommended for production environments.

    While mailcow also relies on nightly builds, they are tested before release. If you do not have specific issues with the current SOGo version, you should not follow this guide.

## Build a new Docker image

To build images, in the mailcow directory under the folder `helper-scripts` there is a subfolder named `docker-compose.override.yml.d` where you will find a folder named `BUILD_FLAGS`. In this folder there is a `docker-compose.override.yml` file, which you should copy as follows to a `docker-compose.override.yml` file in your mailcow directory:

```bash
services:
  sogo-mailcow:
    build:
      context: ./data/Dockerfiles/sogo
      dockerfile: Dockerfile
```

!!! warning "Caution if an override already exists"
    If a `docker-compose.override.yml` file already exists in your mailcow directory, add the content above to that file instead of creating a new one.

You can then rebuild the SOGo image with the following command in the mailcow root directory:

=== "docker compose (Plugin)"

    ```bash
    docker compose build sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose build sogo-mailcow
    ```

## Use the SOGo nightly version

Once the new image has been built, you can recreate the SOGo container with the following command:

=== "docker compose (Plugin)"

    ```bash
    docker compose up -d --force-recreate sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose up -d --force-recreate sogo-mailcow
    ```

mailcow now uses the newly built SOGo nightly version.

## Revert to the stable version

If you want to revert to the stable SOGo version later, simply delete the `docker-compose.override.yml` file in your mailcow directory and run this command again:

=== "docker compose (Plugin)"

    ```bash
    docker compose up -d --force-recreate sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose up -d --force-recreate sogo-mailcow
    ```

!!! warning "If you have made additional customizations in your override file"
    If you have made additional customizations in your `docker-compose.override.yml` file, make sure to back it up before deleting it, so you can restore your customizations later.