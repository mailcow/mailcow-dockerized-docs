### **Configure**

To add or edit your **Identity Provider** configuration, log in to your *mailcow UI* as administrator, go to `System > Configuration > Access > Identity Provider` and select **LDAP** from the Identity Provider dropdown.

* `Host`: The address of your LDAP server. You can provide a single hostname or a comma-separated list of hosts for fallback in case the primary server is unreachable.
* `Port`: The port used to connect to the LDAP server.
* `Use SSL`: enable LDAPS connection. If Port is set to `389` it will be overriden to `636`.
* `Use TLS`: enable TLS connection. SSL Ports cannot be used.
* `Ignore SSL Errors`: If enabled, SSL certificate validation will be bypassed.
* `Base DN`: The Distinguished Name (DN) from which searches will be performed.
* `Username Field`: The LDAP attribute used to identify users during authentication. Defaults to `mail`.
* `Filter`: An optional LDAP search filter to refine which users can authenticate.
* `Attribute Field`: Specifies an LDAP attribute that holds a specific value which can be mapped to a mailbox template using the **Attribute Mapping** section.
* `Bind DN`: The Distinguished Name (DN) of the LDAP user that will be used to authenticate and perform LDAP searches. This account should have sufficient permissions to read the required attributes.
* `Bind Password`: The password for the **Bind DN** user. It is required for authentication when connecting to the LDAP server.
* `Attribute Mapping`:
    * `Attribute`: Defines the LDAP attribute value that should be mapped.
    * `Template`: Specifies which mailbox template should be applied for the defined LDAP attribute value
* `Periodic Full Sync`: If enabled, a full synchronization of all LDAP users and attributes will be performed periodically.
* `Import Users`: If enabled, new users will be automatically imported from LDAP into mailcow.
* `Sync / Import Interval (min)`: Defines the time interval (in minutes) for periodic synchronization and user imports.

---

### **Automatic User Provisioning**  
If a user does not exist in **mailcow** and logs in via **mail protocols** (IMAP/SIEVE/POP3/SMTP) or the **mailcow UI**, the user will be **automatically created**, provided that a matching **attribute mapping** is configured.  

#### **How It Works**  
1. On login, **mailcow** performs an **LDAP bind** and, if successful, retrieves the user's LDAP attributes.  
2. **mailcow** looks for the specified **`Attribute Field`** and retrieves its value.  
3. If the value matches an attribute defined in the **Attribute Mapping**, the corresponding **mailbox template** is applied.  

#### **Example Configuration**  
- The user has an LDAP attribute **`otherMailbox`** with the value **`default`**.  
- In **mailcow**, set **`Attribute Field`** to **`othermailbox`**.  
- Under **Attribute Mapping**, set **`Attribute`** to **`default`** and select an appropriate mailbox template.  

#### **Updates on Login**  
Each time a user logs in, **mailcow** checks if the assigned template has changed. If so, it updates the mailbox settings accordingly.  

#### **Import and Updates via Crontask**  
If **Import Users** is enabled, a scheduled cron job will automatically import users from LDAP to mailcow at the specified **Sync / Import Interval (min)**.  

If **Periodic Full Sync** is enabled, the cron job will also update existing users at the specified **Sync / Import Interval (min)**, ensuring that any changes in LDAP are applied to their corresponding mailboxes in mailcow.  

Check the logs for imports and sync updates under `System > Information > Logs > Crontasks`.

---

### **Change the Authentication Source for Existing Users**

Once you have configured an **LDAP Identity Provider**, you can change the authentication source for existing users from **mailcow** to **LDAP**.  
 
1. Navigate to **`E-Mail > Configuration > Mailboxes`**.  
2. Edit the user.  
3. From the **Identity Provider** dropdown, select **LDAP**.  
4. Save the changes.  

!!! info "Notice"

    The existing SQL password is **not overwritten**. If you switch the authentication source back to **mailcow**, the user will be able to log in with their previous password.  

---

### **Use your own CA certificate for TLS/SSL connections**  

To use your own CA certificate for the TLS/SSL connection to the LDAP server, a `docker-compose.override.yml` must be created.  
The CA certificate should be stored under `data/assets/ssl/ldap-ca.crt`.  
The `docker-compose.override.yml` then looks like this:  
```yaml
services:

  php-fpm-mailcow:
    environment:
      - LDAPTLS_CACERT=/etc/ssl/certs/ldap-ca.crt
    volumes:
      - ./data/assets/ssl/ldap-ca.crt:/etc/ssl/certs/ldap-ca.crt:z
```

Then recreate the PHP-FPM container with:  
=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

---

### **Troubleshooting**

If users cannot log in, first check the log details under: `System > Information > Logs > mailcow UI`.  
Then, follow these steps to diagnose and resolve the issue:  

1. **Test Connection**  
    - Navigate to **`System > Configuration > Access > Identity Provider`**.  
    - Run the **Connection Test** and ensure it completes successfully.  

2. **Verify the User’s Mail Domain**  
    - Ensure the user’s mail domain exists in mailcow.  
    - Check if the domain is limited by **"Max. possible mailboxes"** or **"Domain quota"**.  

3. **Confirm Attribute Mapping**  
    - Make sure a matching **Attribute Mapping** is configured for the users.  

4. **LDAP Filter**  
    - Double-check your LDAP filter if one is configured.

If you’re experiencing issues with **`Periodic Full Sync`** or **`Import Users`**, review the logs under `System > Information > Logs > Crontasks`  
