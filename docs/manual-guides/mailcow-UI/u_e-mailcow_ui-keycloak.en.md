### **Configure**

To add or edit your **Identity Provider** configuration, log in to your *mailcow UI* as administrator, go to `System > Configuration > Access > Identity Provider` and select **Keycloak** from the Identity Provider dropdown.

* `Server URL`: The base URL of your Keycloak server.
* `Realm`: The Keycloak realm where the mailcow client is configured.
* `Client ID`: The Client ID assigned to mailcow Client in Keycloak.
* `Client Secret`: The Client Secret assigned to the mailcow client in Keycloak.
* `Redirect URL`: The redirect URL that Keycloak will use after authentication. This should point to your mailcow UI. Example: `https://mail.mailcow.tld`
* `Version`: Specifies the Keycloak version.
* `Attribute Mapping`:
    * `Attribute`: Defines the attribute value that should be mapped.
    * `Template`: Specifies which mailbox template should be applied for the defined LDAP attribute value
* `Mailpassword Flow`: If enabled, mailcow will attempt to validate user credentials using the **Keycloak Admin REST API** instead of relying solely on the Authorization Code Flow.
    * This requires that the user has a **mailcow_password** attribute set in Keycloak. **mailcow_password** should contain a hashed password
    * The mailcow client in Keycloak must have a Service Account and permission to view-users.
* `Ignore SSL Errors`: If enabled, SSL certificate validation is bypassed.
* `Periodic Full Sync`: If enabled, mailcow periodically performs a full sync of all users from Keycloak.
* `Import Users`: If enabled,  new users are automatically imported from Keycloak into mailcow.
* `Sync / Import Interval (min)`: Defines the time interval (in minutes) for periodic synchronization and user imports.

---

### **Automatic User Provisioning**  
If a user does not exist in **mailcow** and logs in via the **mailcow UI**, the user will be **automatically created**, provided that a matching **attribute mapping** is configured.  

#### **How It Works**  
1. On login, **mailcow** initializes an **Authorization Code Flow** and, if successful, retrieves the user's **OIDC token**.  
2. **mailcow** then looks for the **`mailcow_template`** value in the user info and retrieves it.  
3. If the value matches an attribute defined in the **Attribute Mapping**, the corresponding **mailbox template** is applied.  

#### **Example Configuration**  
- The user has an attribute **`mailcow_template`** with the value **`default`**, which can be retrieved from the **User Info Endpoint**.  
- Under **Attribute Mapping**, set **`Attribute`** to **`default`** and select an appropriate **mailbox template**.  

#### **Updates on Login**  
Each time a user logs in via the **mailcow UI**, **mailcow** checks if the assigned **template** has changed. If so, it updates the mailbox settings accordingly.  

#### **Import and Updates via Crontask**  
!!! warning "Prerequisite"

    This requires **mailcow** to have access to the **Keycloak Admin REST API**.  
    Make sure the **mailcow Client** has an Service Account and the Service account role **view-users**.

If **Import Users** is enabled, a scheduled cron job will automatically import users from Keycloak to mailcow at the specified **Sync / Import Interval (min)**.  

If **Periodic Full Sync** is enabled, the cron job will also update existing users at the specified **Sync / Import Interval (min)**, ensuring that any changes in LDAP are applied to their corresponding mailboxes in mailcow.  

Check the logs for imports and sync updates under `System > Information > Logs > Crontasks`.

---

### **Mailpassword Flow**  
!!! warning "Prerequisite"

    This requires **mailcow** to have access to the **Keycloak Admin REST API**.  
    Make sure the **mailcow Client** has an Service Account and the Service account role **view-users**.

The **Mailpassword Flow** is a direct authentication method that does **not** use the **OIDC Protocol**. It serves as an alternative to the **Authorization Code Flow**.  

With the **Mailpassword Flow**, automatic user provisioning also works for logins via **mail protocols** (IMAP, SIEVE, POP3, SMTP).  

#### **How It Works**  
1. On login, **mailcow** uses the **Keycloak Admin REST API** to retrieve the user’s attributes.  
2. **mailcow** looks for the **`mailcow_password`** attribute.  
3. The **`mailcow_password`** value should contain a [**compatible hashed password**](../../models/model-passwd.md), which will be used for verification.  

This ensures seamless authentication and mailbox creation for both UI and mail protocol logins.  

#### **Generate a BLF-CRYPT Hashed Password**  
The following command creates a bcrypt-hashed password and prefixes it with `{BLF-CRYPT}`:  

```bash
mkpasswd -m bcrypt | sed 's/^/{BLF-CRYPT}/'
```

---

### **Change the Authentication Source for Existing Users**

Once you have configured an **Keycloak Identity Provider**, you can change the authentication source for existing users from **mailcow** to **Keycloak**.  

1. Navigate to **`E-Mail > Configuration > Mailboxes`**.  
2. Edit the user.  
3. From the **Identity Provider** dropdown, select **Keycloak**.  
4. Save the changes.  

!!! info "Notice"

    The existing SQL password is **not overwritten**. If you switch the authentication source back to **mailcow**, the user will be able to log in with their previous password.  

---

### **Authentication for External Mail Clients (IMAP, SIEVE, POP3, SMTP)**  
!!! info "Notice"

    This does not necessarily apply to users utilizing the Mailpassword Flow.

Before users can use external mail clients, they must first log in to the mailcow UI and navigate to the **Mailbox Settings**.  
In the **App Passwords** tab, they can generate a new app password, which must then be used for authentication in the external mail client.

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

If you’re experiencing issues with **`Periodic Full Sync`** or **`Import Users`**, review the logs under `System > Information > Logs > Crontasks`  
