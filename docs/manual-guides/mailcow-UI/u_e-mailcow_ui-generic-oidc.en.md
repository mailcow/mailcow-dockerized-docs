### **Configure**

To add or edit your **Identity Provider** configuration, log in to your *mailcow UI* as administrator, go to `System > Configuration > Access > Identity Provider` and select **Generic-OIDC** from the Identity Provider dropdown.

* `Authorization Endpoint`: The provider's authorization server URL.
* `Token Endpoint`: The provider's token server URL.
* `User Info Endpoint`: The provider's user info server URL.
* `Client ID`: The Client ID assigned to mailcow Client in OIDC provider.
* `Client Secret`: The Client Secret assigned to the mailcow client in OIDC provider.
* `Redirect URL`: The redirect URL that OIDC provider will use after authentication. This should point to your mailcow UI. Example: `https://mail.mailcow.tld`
* `Client Scopes`: Specifies the OIDC scopes requested during authentication. The default scopes are `openid profile email mailcow_template`
* `Attribute Mapping`:
    * `Attribute`: Defines the attribute value that should be mapped.
    * `Template`: Specifies which mailbox template should be applied for the defined attribute value
* `Ignore SSL Errors`: If enabled, SSL certificate validation is bypassed.

---

### **Automatic User Provisioning**  
If a user does not exist in **mailcow** and logs in via **mailcow UI**, the user will be **automatically created**, provided that a matching **attribute mapping** is configured.  

#### **How It Works**  
1. On login, **mailcow** initializes an **Authorization Code Flow** and, if successful, retrieves the user's **OIDC token**.  
2. **mailcow** then looks for the **`mailcow_template`** value in the user info and retrieves it.  
3. If the value matches an attribute defined in the **Attribute Mapping**, the corresponding **mailbox template** is applied.  

#### **Example Configuration**  
- The user has an attribute **`mailcow_template`** with the value **`default`**, which can be retrieved from the **User Info Endpoint**.  
- Under **Attribute Mapping**, set **`Attribute`** to **`default`** and select an appropriate **mailbox template**.  

#### **Updates on Login**  
Each time a user logs in via **mailcow UI**, **mailcow** checks if the assigned template has changed. If so, it updates the mailbox settings accordingly.  

---

### **Change the Authentication Source for Existing Users**

Once you have configured an **Generic-OIDC Identity Provider**, you can change the authentication source for existing users from **mailcow** to **Generic-OIDC**.  

1. Navigate to **`E-Mail > Configuration > Mailboxes`**.  
2. Edit the user.  
3. From the **Identity Provider** dropdown, select **Generic-OIDC**.  
4. Save the changes.  

!!! info "Notice"

    The existing SQL password is **not overwritten**. If you switch the authentication source back to **mailcow**, the user will be able to log in with their previous password.  

---

### **Authentication for External Mail Clients (IMAP, SIEVE, POP3, SMTP)**  

Before users can use external mail clients, they must first log in to the mailcow UI and navigate to the **Mailbox Settings**.  
In the **App Passwords** tab, they can generate a new app password, which must then be used for authentication in the external mail client.

---

### **Troubleshooting**

If users are unable to log in, follow these steps to diagnose and resolve the issue:  

1. **Test Connection**  
    - Navigate to **`System > Configuration > Access > Identity Provider`**.  
    - Run the **Connection Test** and ensure it completes successfully.

1. **Verfiy Client details**  
    - Navigate to **`System > Configuration > Access > Identity Provider`**.  
    - verify that Client ID and Client Secret matches data of OIDC Provider

3. **Verify the User’s Mail Domain**  
    - Ensure the user’s mail domain exists in mailcow.  
    - Check if the domain is limited by **"Max. possible mailboxes"** or **"Domain quota"**.  

4. **Confirm Attribute Mapping**  
    - Make sure a matching **Attribute Mapping** is configured for the users.  
