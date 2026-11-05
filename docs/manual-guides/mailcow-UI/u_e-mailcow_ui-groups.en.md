Groups bundle mailboxes. Everything you configure on a group applies to all of its members:

| Feature | Members get |
| --- | --- |
| Group address | Mail to the group address is delivered to all members |
| Send as | Members may send as other addresses |
| Mailbox access | Members open other mailboxes in their mail client |
| Calendars and address books | Members get access to SOGo calendars and address books of other mailboxes |
| Mailbox template | The settings of a mailbox template |

Groups are maintained in mailcow or synced from Keycloak or LDAP/Active Directory, see [Identity Provider sync](u_e-mailcow_ui-idp-sync.md).

---

## Create a group

Navigate to `E-Mail > Configuration > Groups` and click **Add group**. To change a group later, click **Edit** in the list.

* `Domain`: The domain the group belongs to. It cannot be changed later.
* `Name`: Unique within the domain.
* `Description`: Optional, shown below the name in the list of groups.
* `Group address`: Optional, see [Group address](#group-address-distribution-list).
* `Members`: Mailboxes of the group. Only regular mailboxes can be members, resources cannot.
* `Send as`: Addresses the members may send as, see [Send as](#send-as).
* `Mailbox access`, `Calendars and address books`: Shares, see [Shares](#shares).
* `Mailbox template`, `Priority`: Only for administrators, see [Mailbox template](#mailbox-template).
* `Active`: An inactive group keeps its settings, but its members lose everything they got through the group.

---

## Group address (distribution list)

If a group has an address, mailcow creates an alias for it that delivers to all members and keeps it up to date. The alias appears in the alias list as **Managed by group** and can only be changed in the group.

The address must belong to the domain of the group, addresses of alias domains are not possible. It must not be used by a mailbox or alias yet and counts against the alias limit of the domain (`Max. possible aliases`). While the group is inactive or has no members, mail to the address is rejected, but the address stays reserved for the group.

* `Members may send as the group address`: Members can use the group address as sender.
* `Show the group address as identity in SOGo`: Members can select the address as sender in SOGo (requires the option above).
* `Only accept mail from senders of the domain`: Mail from external senders to the group address is rejected.

!!! warning "Large groups"
    Postfix delivers mail for a single address to at most 1000 recipients (`virtual_alias_expansion_limit`). mailcow shows a warning when a group with an address has more members.

---

## Send as

Enter one address per line: a mailbox, an alias or `@example.org` for all addresses of a domain. As long as the group is active, every member may send as these addresses.

SOGo does not offer these addresses automatically. Members add them as identity in SOGo or in their mail client themselves. Only the group address becomes an identity in SOGo automatically, see [Group address](#group-address-distribution-list).

The mailbox edit page shows these addresses under **May send as (through groups)**. They can only be changed in the group.

!!! tip
    To let a team send as `info@example.org`, add the team as members, enter `info@example.org` under `Send as` and give the group access to the mailbox (see [Shares](#shares)).

---

## Mailbox template

Administrators can assign a mailbox template to a group. mailcow applies it to all members:

* A mailbox in several groups gets the template of the active group with the highest `Priority`. With equal priority, the group with the lowest ID wins.
* The template is applied when the effective template of a mailbox changes, for example when it joins a group. Editing a template applies it again to all members it is the effective template of. **Apply the template to all members again** applies it on purpose.
* A member that leaves the group keeps the settings of the template. If the template of another group applies now, mailcow applies that one.
* Mailboxes with the authentication source mailcow keep manual changes until the template is applied again.
* Mailboxes from an identity provider get the group template instead of the template from the attribute mapping. mailcow applies their template again at every login and full sync, manual changes are overwritten then. A mailbox that leaves all groups gets the template from the attribute mapping again. See [Templates](u_e-mailcow_ui-idp-sync.md#templates).

---

## Shares

Shares give the members access to folders of other mailboxes. mailcow applies them right away. A background task checks them every 15 minutes, applies failed shares again and restores shares that were changed or removed outside of the group. Owners can still share folders with single users in SOGo or their mail client.

### Mailbox access (IMAP)

Choose a mailbox and the rights of the members:

| Right | Members can |
| --- | --- |
| Read | read mails and mark them as read |
| Write | also create folders, file, move and delete mails |
| Full access | also delete folders |

Members find the mailbox in their mail client below `Shared/<mailbox>/`, e.g. `Shared/info@example.org/INBOX`.

* `Subscribe`: Subscribes the folders of the mailbox for every member within a minute, so that mail clients show them. This is done once: a member who unsubscribes a folder keeps it that way.
* New subfolders get the share immediately, new top-level folders within 15 minutes.
* Members who leave the group lose the access with their next connection. Folders mailcow subscribed for them are unsubscribed within a minute, unless another group gives them access to the same mailbox.

### Calendars and address books (SOGo)

Choose a mailbox, the type (`Calendar` or `Address book`) and the access:

| Access | Calendar | Address book |
| --- | --- | --- |
| Read | View all appointments | View contacts |
| Write | Also create, change and delete appointments | Also create, change and delete contacts |

Private appointments only show date and time.

* Folder: `personal` is the default calendar or address book of the mailbox. For other folders, enter the folder ID, the last part of the CalDAV or CardDAV link in the folder properties in SOGo.
* `Subscribe`: Adds the folder to SOGo of every member within a minute. This is done once: a member who removes it keeps it removed. Without this option, members subscribe to the folder in SOGo themselves. Members who lose the access are unsubscribed within a minute, unless another group shares the same folder with them.
* Status **Pending**: the folder does not exist yet. For `personal`, mailcow creates the folder of an active mailbox itself, e.g. of a shared mailbox that never opened SOGo. Other folder IDs stay pending until the folder exists, the share becomes active within 15 minutes after that.

With `SKIP_SOGO=y` in `mailcow.conf`, this section and the option `Show the group address as identity in SOGo` are hidden.

---

## Shared mailboxes

A shared mailbox is a team mailbox such as `info@example.org` without a login of its own.

1. Create the mailbox in `E-Mail > Configuration > Mailboxes` and enable **Shared mailbox**. With the authentication source mailcow, a password is not needed.
2. Create a group for the team, give it `Mailbox access` to the shared mailbox and enter its address under `Send as`.
3. Optionally share its calendar or address book in `Calendars and address books`.

A shared mailbox receives mail as usual, but nobody can log in with it: IMAP, POP3, SMTP, SOGo, ActiveSync, app passwords and the mailcow UI are blocked. A login with the right password is logged as `Login denied` and does not count as failed login for netfilter, see [What counts as a failed login](u_e-mailcow_ui-netfilter.md#what-counts-as-a-failed-login).

---

## Deleting and renaming

Groups follow changes of mailboxes, aliases and domains:

* Deleting a mailbox removes its memberships, the shares of its folders and send-as entries with its address.
* Renaming a mailbox: memberships, shares and send-as entries follow the new address.
* Deleting an alias removes its address from send-as. Renaming an alias: send-as entries follow.
* Deleting a domain deletes its groups and removes send-as entries with addresses of the domain. Deleting an alias domain removes send-as entries with its addresses.
* Deleting a mailbox template removes it from the groups. Members keep their settings.

---

## Permissions

* **Administrators** manage all groups.
* **Domain administrators** manage the groups of their domains if their ACL **Groups** is enabled (default):
    * Members can come from all domains they manage. Members from other domains are shown below the member list and are kept when they save the group.
    * Send-as addresses and shared folders must belong to their domains. If an administrator added send-as addresses or shares outside their domains, the group is read-only for them. This also applies to a share that is still being removed.
    * Template, priority and the link to an IdP group are reserved for administrators.
    * If a change of a domain administrator changes the effective template of members (e.g. by disabling the group), mailcow only applies it to mailboxes in the domains of this domain administrator. Other members get it with **Apply the template to all members again** or at their next IdP login.
    * On the edit page of a mailbox, they only see the groups of their domains.
* **Mailbox users** see their groups on their user page.
* Members synced from an identity provider are marked **IdP** and can only be changed there.

---

## Limitations

* Groups cannot contain other groups. Nested groups of Active Directory can be resolved by the [LDAP group sync](u_e-mailcow_ui-idp-sync.md#groups).
* "Send on behalf of" is not supported, members send as the address.

---

## Troubleshooting

* Shares with the status **Failed** are retried every 15 minutes. The log is found in `System > Information > Logs > Crontasks` (task `Group Shares`).
* The IMAP rights of a mailbox can be checked in the Dovecot container. Group shares appear as `group=mcg_<group ID>`:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec dovecot-mailcow doveadm acl get -u info@example.org INBOX
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec dovecot-mailcow doveadm acl get -u info@example.org INBOX
    ```
