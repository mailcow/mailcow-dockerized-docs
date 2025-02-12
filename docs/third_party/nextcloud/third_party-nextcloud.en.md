## Configure Nextcloud to use mailcow for authentication

The following describes how set up authentication via mailcow using the OAuth2 protocol. We will only assume that you have already set up Nextcloud at _cloud.example.com_ and that your mailcow is running at _mail.example.com_. It does not matter if your Nextcloud is running on a different server, you can still use mailcow for authentication.

1\. Log into mailcow as administrator.

2\. Click Configuration in the drop-down menu (top right).

3\. Then, in the "Access" tab, select the OAuth2 drop-down item.

4\. Scroll down and click the _Add OAuth2 client_ button. Specify the redirect URI as `https://cloud.example.com/index.php/apps/sociallogin/custom_oauth2/mailcow` and click _Add_. Save the client ID and secret for later.

!!! info
    Some installations, including those setup using the removed helper script of mailcow, need to remove index.php/ from the URL to get a successful redirect: `https://cloud.example.com/apps/sociallogin/custom_oauth2/mailcow`

5\. Log into Nextcloud as administrator.

6\. Click the button in the top right corner and select _Apps_. Click the search button in the toolbar, search for the [_Social Login_](https://apps.nextcloud.com/apps/sociallogin) plugin and click _Download and enable_ next to it.

7\. Click the button in the top right corner and select _Settings_. Scroll down to the _Administration_ section on the left and click _Social login_.

8\. Uncheck the following items:

- "Disable auto create new users"
- "Allow users to connect social logins with their accounts"
- "Do not prune not available user groups on login"
- "Automatically create groups if they do not exists"
- "Restrict login for users without mapped groups"

7\. Check the following items:

- "Prevent creating an account if the email address exists in another account"
- "Update user profile every login"
- "Disable notify admins about new users"

Click the _Save_ button.

8\. Scroll down to _Custom OAuth2_ and click the _+_ button.
9\. Configure the parameters as follows:

- Internal name: `mailcow`
- Title: `mailcow`
- API Base URL: `https://mail.example.com`
- Authorize URL: `https://mail.example.com/oauth/authorize`
- Token URL: `https://mail.example.com/oauth/token`
- Profile URL: `https://mail.example.com/oauth/profile`
- Logout URL: (leave blank)
- Client ID: (what you obtained in step 1)
- Client Secret: (what you obtained in step 1)
- Scope: `profile`

Click the _Save_ button at the very bottom of the page.

---

If you have previously used Nextcloud with mailcow authentication via user\_external/IMAP, you need to perform some additional steps to link your existing user accounts with OAuth2.

1\. Click the button in the top right corner and select _Apps_. Scroll down to the _External user authentication_ app and click _Remove_ next to it.
2\. Run the following queries in your Nextcloud database (if you set up Nextcloud with the script from mailcow, you can use the following command to get into the container):

=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf && docker compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf && docker-compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

```sql
INSERT INTO oc_users (uid, uid_lower) SELECT DISTINCT uid, LOWER(uid) FROM oc_users_external;
INSERT INTO oc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("mailcow-", uid) FROM oc_users_external;
```

---

If you have previously used Nextcloud without mailcow authentication, but with the same usernames as mailcow, you can also link your existing user accounts with OAuth2.

1\. Run the following queries in your Nextcloud database (if you set up Nextcloud with the script from mailcow, you can use the following command to get into the container):
=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf && docker compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf && docker-compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

```sql
INSERT INTO oc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("mailcow-", uid) FROM oc_users;
```

---

## Update

The Nextcloud instance can be updated easily with the web update mechanism. In the case of larger updates, there may be further changes to be made after the update. After the Nextcloud instance has been checked, problems are shown. This can be e.g. missing indices in the DB or similar.
It shows which commands have to be executed, these have to be placed in the php-fpm-mailcow container.

As an an example run the following command to add the missing indices.
`docker exec -it -u www-data $(docker ps -f name=php-fpm-mailcow -q) bash -c "php /web/nextcloud/occ db:add-missing-indices"`

The update can also been done by CLI with the following command: 

`docker exec -it -u www-data $(docker ps -f name=php-fpm-mailcow -q) bash -c "php /web/nextcloud/updater/updater.phar"`


This can also been done in an non interactive way (e.g. CRON) with this command: 

!!! danger
    We do not recommend this! Serios damage can be caused or the update process brakes over time.<br>
    **USE AT OWN RISK!!**

`docker exec -it -u www-data $(docker ps -f name=php-fpm-mailcow -q) bash -c "php /web/nextcloud/updater/updater.phar --no-interaction"`

---

## Debugging & Troubleshooting

It may happen that you cannot reach the Nextcloud instance from your network. This may be due to the fact that the entry of your subnet in the array 'trusted_proxies' is missing. You can make changes in the Nextcloud config.php in `data/web/nextcloud/config/*`.

```
'trusted_proxies' =>
  array (
    0 => 'fd4d:6169:6c63:6f77::/64',
    1 => '172.22.1.0/24',
    2 => 'NewSubnet/24',
  ),
```

After the changes have been made, the nginx container must be restarted.
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart nginx-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart nginx-mailcow
    ```
