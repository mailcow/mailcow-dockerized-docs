### **Configure**

To add or edit your **Identity Provider** configuration, log in to your *mailcow UI* as administrator, go to `System > Configuration > Access > Identity Provider` and select **LDAP** from the Identity Provider dropdown.

**Connection**

* `Host`: The address of your LDAP server. You can provide a single hostname or a comma-separated list of hosts for fallback in case the primary server is unreachable.
* `Port`: The port used to connect to the LDAP server.
* `Encryption`: `None`, `StartTLS` (uses the normal port, usually `389`) or `SSL (LDAPS)`. With SSL, port `389` is changed to `636` automatically.
* `Ignore SSL Errors`: If enabled, SSL certificate validation will be bypassed.
* `Bind DN`: The Distinguished Name (DN) of the LDAP user that will be used to authenticate and perform LDAP searches. This account should have sufficient permissions to read the required attributes.
* `Bind Password`: The password for the **Bind DN** user. It is required for authentication when connecting to the LDAP server.

**Users**

* `Base DN`: The Distinguished Name (DN) from which searches will be performed.
* `Filter`: An optional LDAP search filter to refine which users can authenticate and are synced, e.g. `(objectClass=person)`.
* `Username Field`: The LDAP attribute with the email address of the users, it becomes the mailbox name. Defaults to `mail`.
* `ID attribute`: Attribute with a stable user ID, used to [link mailboxes and LDAP users](u_e-mailcow_ui-idp-sync.md#linking-mailboxes-and-idp-users). If empty, mailcow uses `objectGUID`, `entryUUID`, `nsUniqueId` or `ipaUniqueID`, otherwise the DN.
* `Disabled filter`: Optional LDAP filter that matches disabled users, used for [offboarding](u_e-mailcow_ui-idp-sync.md#offboarding). Active Directory accounts that are disabled in `userAccountControl` always count as disabled.

**Login**

* `Auto-create users on login`: If enabled, mailboxes are created at the first login of a user, see [Automatic User Provisioning](#automatic-user-provisioning).

**Mailbox templates**

* `Attribute Field`: Specifies an LDAP attribute that holds a specific value which can be mapped to a mailbox template using the **Attribute Mapping** section.
* `Default Template`: Used to create a mailbox if no attribute mapping matches. It is not applied to existing mailboxes.
* `Attribute Mapping`:
    * `Attribute`: Defines the LDAP attribute value that should be mapped.
    * `Template`: Specifies which mailbox template should be applied for the defined LDAP attribute value

**Synchronization** and **Groups**

* Import of users, periodic sync, offboarding and group sync are described in [Identity Provider sync](u_e-mailcow_ui-idp-sync.md).

---

### **Automatic User Provisioning**  
If a user does not exist in **mailcow** and logs in via **mail protocols** (IMAP/SIEVE/POP3/SMTP) or the **mailcow UI**, the user will be **automatically created**, provided that `Auto-create users on login` is enabled and a matching **attribute mapping** or a **Default Template** is configured.  

#### **How It Works**  
1. On login, **mailcow** performs an **LDAP bind** and, if successful, retrieves the user's LDAP attributes.  
2. **mailcow** looks for the specified **`Attribute Field`** and retrieves its value.  
3. If the value matches an attribute defined in the **Attribute Mapping**, the corresponding **mailbox template** is applied. Otherwise the **Default Template** is used.  

#### **Example Configuration**  
- The user has an LDAP attribute **`otherMailbox`** with the value **`default`**.  
- In **mailcow**, set **`Attribute Field`** to **`othermailbox`**.  
- Under **Attribute Mapping**, set **`Attribute`** to **`default`** and select an appropriate mailbox template.  

#### **Updates on Login**  
Each time a user logs in, **mailcow** checks if the assigned template has changed. If so, it updates the mailbox settings accordingly. Templates of [groups](u_e-mailcow_ui-groups.md#mailbox-template) take precedence over the attribute mapping.  

#### **Import and Updates via Crontask**  
Users can also be imported and updated in the background, without waiting for their login. Disabled or deleted users can lose their login automatically (offboarding), and LDAP groups can be synced to mailcow groups. See [Identity Provider sync](u_e-mailcow_ui-idp-sync.md).

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

5. **Unique Login Name**  
    - The login name (`Username Field`) must match exactly one entry within `Base DN` and `Filter`, otherwise the login is refused. Email addresses must be unique, see [Linking mailboxes and IdP users](u_e-mailcow_ui-idp-sync.md#linking-mailboxes-and-idp-users).

If the LDAP server is down, see [Identity provider outages](u_e-mailcow_ui-netfilter.md#identity-provider-outages).

If you’re experiencing issues with the synchronization, check the card **Sync status** in the Identity Provider settings and review the logs under `System > Information > Logs > Crontasks`.  
