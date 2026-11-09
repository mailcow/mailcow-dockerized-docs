### **Configure**

To add or edit your **Identity Provider** configuration, log in to your *mailcow UI* as administrator, go to `System > Configuration > Access > Identity Provider` and select **Keycloak** from the Identity Provider dropdown.

**Connection**

* `Server URL`: The base URL of your Keycloak server.
* `Realm`: The Keycloak realm where the mailcow client is configured.
* `Version`: Specifies the Keycloak version.
* `Client ID`: The Client ID assigned to mailcow Client in Keycloak.
* `Client Secret`: The Client Secret assigned to the mailcow client in Keycloak.
* `Ignore SSL Errors`: If enabled, SSL certificate validation is bypassed.

**Login**

* `Redirect URL`: The redirect URL that Keycloak will use after authentication. This should point to your mailcow UI. Example: `https://mail.mailcow.tld`. With **Add redirect URL** you can add further URLs, e.g. for additional host names.
* `Mailpassword Flow`: If enabled, mailcow will attempt to validate user credentials using the **Keycloak Admin REST API** instead of relying solely on the Authorization Code Flow.
    * This requires that the user has a **mailcow_password** attribute set in Keycloak. **mailcow_password** should contain a hashed password
    * The mailcow client in Keycloak must have a Service Account and permission to view-users.
* `Auto-create users on login`: If enabled, mailboxes are created at the first login of a user, see [Automatic User Provisioning](#automatic-user-provisioning).

**Mailbox templates**

* `Default Template`: Used to create a mailbox if no attribute mapping matches. It is not applied to existing mailboxes.
* `Attribute Mapping`:
    * `Attribute`: Defines the attribute value that should be mapped.
    * `Template`: Specifies which mailbox template should be applied for the defined attribute value.

**Synchronization** and **Groups**

* Import of users, periodic sync, offboarding and group sync are described in [Identity Provider sync](u_e-mailcow_ui-idp-sync.md).

!!! info "Keycloak 24 and newer"
    Keycloak only stores user attributes that are defined in the user profile. Add `mailcow_template` (and `mailcow_password` for the Mailpassword Flow) to the user profile of the realm or enable **Unmanaged attributes** in the realm settings.

!!! info "Keycloak 26.8.2 and newer"
    The Admin REST API only accepts tokens with the client scope `kc-admin-api`. Add it to the mailcow client as **Default** scope (`Clients > mailcow client > Client scopes > Add client scope`). Without it, the Mailpassword Flow and the sync fail with HTTP 401.

---

### **Automatic User Provisioning**  
If a user does not exist in **mailcow** and logs in via the **mailcow UI**, the user will be **automatically created**, provided that `Auto-create users on login` is enabled and a matching **attribute mapping** or a **Default Template** is configured.  

#### **How It Works**  
1. On login, **mailcow** initializes an **Authorization Code Flow** and, if successful, retrieves the user's **OIDC token**.  
2. **mailcow** then looks for the **`mailcow_template`** value in the user info and retrieves it.  
3. If the value matches an attribute defined in the **Attribute Mapping**, the corresponding **mailbox template** is applied. Otherwise the **Default Template** is used.  

#### **Example Configuration**  
- The user has an attribute **`mailcow_template`** with the value **`default`**, which can be retrieved from the **User Info Endpoint**.  
- Under **Attribute Mapping**, set **`Attribute`** to **`default`** and select an appropriate **mailbox template**.  

#### **Updates on Login**  
Each time a user logs in via the **mailcow UI** (with the [Mailpassword Flow](#mailpassword-flow) also via mail protocols), **mailcow** checks if the assigned **template** has changed. If so, it updates the mailbox settings accordingly. Templates of [groups](u_e-mailcow_ui-groups.md#mailbox-template) take precedence over the attribute mapping.  

#### **Import and Updates via Crontask**  
Users can also be imported and updated in the background, without waiting for their login. Disabled or deleted users can lose their login automatically (offboarding), and Keycloak groups can be synced to mailcow groups. See [Identity Provider sync](u_e-mailcow_ui-idp-sync.md).

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

The tab requires the mailbox ACL **Manage app passwords**. An app password never allows a protocol that the mailbox itself does not allow.

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

4. **Check the Email Address**  
    - The email address must be unique in Keycloak. The **Mailpassword Flow** needs exactly one user with this email address, see [Linking mailboxes and IdP users](u_e-mailcow_ui-idp-sync.md#linking-mailboxes-and-idp-users).  

If Keycloak is down, see [Identity provider outages](u_e-mailcow_ui-netfilter.md#identity-provider-outages).

If you’re experiencing issues with the synchronization, check the card **Sync status** in the Identity Provider settings and review the logs under `System > Information > Logs > Crontasks`.  
