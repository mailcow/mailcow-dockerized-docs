A quick guide to deeply analyze a malfunctioning Rspamd.

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow bash

    if ! grep -qi 'apt-stable-asan' /etc/apt/sources.list.d/rspamd.list; then
      sed -i 's/apt-stabil/apt-stabil-asan/i' /etc/apt/sources.list.d/rspamd.list
    fi

    apt-get update ; apt-get upgrade rspamd

    nano /docker-entrypoint.sh

    # Add this in front of "exec "$@"":

    export G_SLICE=always-malloc
    export ASAN_OPTIONS=new_delete_type_mismatch=0:detect_leaks=1:detect_odr_violation=0:log_path=/tmp/rspamd-asan:quarantine_size_mb=2048:malloc_context_size=8:fast_unwind_on_malloc=0
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow bash

    if ! grep -qi 'apt-stable-asan' /etc/apt/sources.list.d/rspamd.list; then
      sed -i 's/apt-stabil/apt-stabil-asan/i' /etc/apt/sources.list.d/rspamd.list
    fi

    apt-get update ; apt-get upgrade rspamd

    nano /docker-entrypoint.sh

    # Add this in front of "exec "$@"":

    export G_SLICE=always-malloc
    export ASAN_OPTIONS=new_delete_type_mismatch=0:detect_leaks=1:detect_odr_violation=0:log_path=/tmp/rspamd-asan:quarantine_size_mb=2048:malloc_context_size=8:fast_unwind_on_malloc=0
    ```

Restart Rspamd:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Your memory consumption will increase by a lot, it will also steadily grow, which is not related to a possible memory leak you are looking for.

Leave the container running for a few minutes, hours or days (it should match the time you usually wait for the leak to "happen") and restart it:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Now enter the container by running the command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow bash
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow bash
    ```


Change the directory to /tmp and copy the asan Files to your desired location or upload them via termbin.com (`cat /tmp/rspamd-asan.* | nc termbin.com 9999`).