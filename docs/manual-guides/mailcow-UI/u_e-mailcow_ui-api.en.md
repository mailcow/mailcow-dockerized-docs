The mailcow API lets other applications read and change the configuration of mailcow, e.g. for monitoring or provisioning. All endpoints are documented on your instance at `https://<your mailcow>/api`.

---

## Create an API key

Navigate to `System > Configuration > Access > Administrators`, open the card **API** and click **Add API key** in the section **API keys**:

* `Description`: What the key is used for.
* `Access`: `Read-Only Access` only allows reading, `Read-Write Access` allows changes as well.
* `Allow API access from these IPs/CIDR network notations`: IP addresses or networks that may use the key, one per line, e.g. `192.0.2.10` or `2001:db8::/64`.
* `Skip IP check for API`: The key works from every IP address. Only use this if the API is not reachable from the internet.
* `Active`: Inactive keys are rejected.

Create one key per application, so you can disable or delete it on its own. The list shows every key, the clipboard icon next to it copies it. **Regenerate API key** (under **Actions** or on the edit page of a key) replaces a key with a new one.

## Service keys from mailcow.conf

Keys for scripts and automated setups can be defined in `mailcow.conf`:

```
API_KEY=
API_KEY_READ_ONLY=
API_ALLOW_FROM=172.22.1.1,127.0.0.1
```

* `API_KEY` has read-write access, `API_KEY_READ_ONLY` read-only access. Allowed characters: `a-z`, `A-Z`, `0-9` and `-`.
* `API_ALLOW_FROM` is a comma-separated list of IP addresses or networks. Without a valid entry, both keys are ignored.

mailcow applies the values when PHP-FPM starts. After changing `mailcow.conf`, recreate the containers:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

* The list of API keys shows the service keys as `API_KEY` and `API_KEY_READ_ONLY` with a lock icon. They can only be changed in `mailcow.conf`: the UI and the API cannot deactivate, regenerate or delete them.
* A key removed from `mailcow.conf` is deleted.
* If a key created in the UI has the same value, it becomes the service key.
* Invalid entries in `API_ALLOW_FROM` and invalid keys are skipped. The log of PHP-FPM shows a warning starting with `API service keys:`, e.g. with `docker compose logs php-fpm-mailcow | grep "API service keys"`.

---

## Use the API

Send the key in the header `X-API-Key`:

```bash
curl -H "X-API-Key: YOUR-API-KEY" https://mail.example.org/api/v1/get/domain/all
```

Requests are logged in `System > Information > Logs > API`.

A request with a valid key starts a session. Clients that keep the session cookie can send further requests without the key. Deleting, deactivating or regenerating a key, or changing its access, ends all sessions started with it. Clients then have to send the current key again.
