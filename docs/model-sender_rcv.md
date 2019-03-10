When a mailbox is created, a user is allowed to send mail from and receive mail for his own mailbox address.

    Mailbox me@example.org is created. example.org is a primary domain.
    Note: a mailbox cannot be created in an alias domain.

    me@example.org is only known as me@example.org.
    me@example.org is allowed to send as me@example.org.

We can add an alias domain for example.org:

    Alias domain alias.com is added and assigned to primary domain example.org.
    me@example.org is now known as me@example.org and me@alias.com.
    me@example.org is now allowed to send as me@example.org and me@alias.com.

We can add aliases for a mailbox to receive mail for and to send from this new address.

It is important to know, that you are not able to receive mail for `my-alias@my-alias-domain.tld`. You would need to create this particular alias.

    me@example.org is assigned the alias alias@example.org
    me@example.org is now known as me@example.org, me@alias.com, alias@example.org

    me@example.org is NOT known as alias@alias.com.

Please note that this does not apply to catch-all aliases:

    Alias domain alias.com is added and assigned to primary domain example.org
    me@example.org is assigned the catch-all alias @example.org
    me@example.org is still just known as me@example.org, which is the only available send-as option
    
    Any email send to alias.com will match the catch-all alias for example.org

Administrators and domain administrators can edit mailboxes to allow specific users to send as other mailbox users ("delegate" them).

You can choose between mailbox users or completely disable the sender check for domains.

### SOGo "mail from" addresses

Mailbox users can, obviously, select their own mailbox address, as well as all alias addresses and aliases that exist through alias domains.

If you want to select another _existing_ mailbox user as your "mail from" address, this user has to delegate you access through SOGo (see SOGo documentation). Moreover a mailcow (domain) administrator
needs to grant you access as described above.
