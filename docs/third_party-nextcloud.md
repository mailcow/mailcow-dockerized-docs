NextCloud can be set up with the [helper script](https://github.com/mailcow/mailcow-dockerized/raw/master/helper-scripts/nextcloud.sh) included with mailcow. You can also set up NextCloud on a different server and still use mailcow for authentication.

In the following, we will only assume that you have already set up NextCloud at _cloud.example.com_ and that your mailcow is running at _mail.example.com_.
To set up authentication via mailcow, you can use OAuth2 as described below. 

1. Log into mailcow as administrator.
2. Scroll down to _OAuth2 Apps_ and click the _Add_ button. Specify the redirect URI as `https://cloud.example.com/index.php/apps/sociallogin/custom_oauth2/Mailcow` and click _Add_. Save the client ID and secret for later.
3. Log into NextCloud as administrator.
4. Click the button in the top right corner and select _Apps_. Click the search button in the toolbar, search for the [_Social Login_](https://apps.nextcloud.com/apps/sociallogin) plugin and click _Download and enable_ next to it.
5. Click the button in the top right corner and select _Settings_. Scroll down to the _Administration_ section on the left and click _Social login_.
6. Uncheck the following items:
  - _Disable auto create new users_,
  - _Allow users to connect social logins with their accounts_,
  - _Do not prune not available user groups on login_,
  - _Automatically create groups if they do not exists_,
  - _Restrict login for users without mapped groups_,

  and check the following items:
  - _Prevent creating an account if the email address exists in another account_,
  - _Update user profile every login_,
  - _Disable notify admins about new users_.

  Click the _Save_ button.

7. Scroll down to _Custom OAuth2_ and click the _+_ button. 
8. Configure the parameters as follows:
  - Internal name: `Mailcow`
  - Title: `Mailcow`
  - API Base URL: `https://mail.example.com`
  - Authorize URL: `https://mail.example.com/oauth/authorize`
  - Token URL: `https://mail.example.com/oauth/token`
  - Profile URL: `https://mail.example.com/oauth/profile`
  - Logout URL: (leave blank)
  - Client ID: (what you obtained in step 1)
  - Client Secret: (what you obtained in step 1)
  - Scope: `profile`

Click the _Save_ button at the very bottom of the page.

If you have previously used NextCloud with mailcow authentication via user\_external/IMAP, you need to perform some additional steps to link your existing user accounts with OAuth2.

1. Click the button in the top right corner and select _Apps_. Scroll down to the _External user authentication_ app and click _Remove_ next to it.
2. Run the following queries in your Nextcloud database (if you set up Nextcloud using mailcow's script, you can run `source mailcow.conf && docker-compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME`):
```
INSERT INTO nc_users (uid, uid_lower) SELECT DISTINCT uid, LOWER(uid) FROM nc_users_external;
INSERT INTO nc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("Mailcow-", uid) FROM nc_users_external;
```

If you have previously used NextCloud without mailcow authentication, but with the same usernames as mailcow, you can also link your existing user accounts with OAuth2.

1. Run the following queries in your Nextcloud database (if you set up Nextcloud using mailcow's script, you can run `source mailcow.conf && docker-compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME`):
```
INSERT INTO nc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("Mailcow-", uid) FROM nc_users;
```
