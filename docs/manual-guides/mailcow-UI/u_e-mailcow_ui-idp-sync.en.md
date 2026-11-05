mailcow keeps the mailboxes in sync with your identity provider (IdP): it creates mailboxes, updates name and template, disables the login of users who left and syncs group memberships. The sync works with **Keycloak** and **LDAP** (incl. Active Directory). With Generic-OIDC, mailboxes are only created at the first login.

The settings are found in `System > Configuration > Access > Identity Provider` in the sections **Synchronization** and **Groups**. The connection itself is described on the pages for [Keycloak](u_e-mailcow_ui-keycloak.md) and [LDAP](u_e-mailcow_ui-ldap.md).

!!! warning "Keycloak"
    The mailcow client in Keycloak needs a **Service Account** with the role **view-users**. The group sync additionally needs **query-groups**.

---

## Synchronization

* `Import Users`: Creates mailboxes for all IdP users with a matching template (see [Templates](#templates)), without waiting for their first login. Disabled users and users whose domain does not exist in mailcow are skipped.
* `Periodic Full Sync`: Updates name and template of existing mailboxes.
* `Offboarding`: Disables the login of users who were disabled or removed in the IdP, see [Offboarding](#offboarding).
* `Sync / Import interval (min)`: Time between two sync runs. Default: 15 minutes.
* `Change limit (%)`: Safety limit, see [Safety](#safety). Default: 10 %.

---

## Linking mailboxes and IdP users

mailcow stores which IdP user a mailbox belongs to, using an ID that does not change:

* Keycloak: the user ID.
* LDAP: the attribute in `ID attribute`. If it is empty, mailcow uses `objectGUID` (Active Directory), `entryUUID` (OpenLDAP), `nsUniqueId` or `ipaUniqueID`, otherwise the DN.
* Generic-OIDC: the claim `sub`. Mailboxes are linked at the first login.

Only mailboxes that use the IdP as authentication source are synced, mailboxes with the authentication source mailcow are left alone. Existing mailboxes are linked by their email address at the first sync or login. Afterwards, an IdP user who gets the address of another user later cannot take over the mailbox. mailcow reports such cases as conflict.

Email addresses must be unique in the IdP:

* If several IdP users have the same email address, the sync links and imports none of them and reports "Several IdP users have the email …".
* LDAP: The login is refused if the login name matches more than one entry.
* Keycloak with `Mailpassword Flow`: The login needs exactly one user with this email address.
* Keycloak and Generic-OIDC: If the email address or the user in the IdP no longer matches the mailbox, the session in the mailcow UI ends with its next refresh.

The mailbox edit page shows the link under **IdP link**. If an address was given to another person on purpose, an administrator can click **Unlink**, the mailbox is then linked again by email. Domain administrators only see the link. Changing the `ID attribute` links all mailboxes again by email.

---

## Offboarding

With `Offboarding` enabled, mailcow sets mailboxes to **Disallow login (incoming mail is still accepted)** when the user

* is disabled in the IdP (Keycloak: user disabled; Active Directory: account disabled in `userAccountControl`; other LDAP servers: matches the `Disabled filter`), or
* is missing in two complete sync runs in a row (deleted or moved out of the Base DN or filter).

The mailbox and its mails are kept and mail is still delivered. Deleting the mailbox is up to you.

When the user is enabled in the IdP again, mailcow allows the login again. This only applies to mailboxes the sync has disabled, a mailbox you disabled yourself stays disabled. If you enable a mailbox the sync has disabled while the user is still disabled in the IdP, the sync leaves it enabled. It only disables the mailbox again after the user was enabled and disabled again in the IdP.

* The `Disabled filter` is only evaluated by the sync, not at login.
* Sync runs record missing users even while `Offboarding` is off. The first run with offboarding disables the mailboxes of users who are already missing or disabled in the IdP. Check the number **Missing in IdP** in the card **Sync status** before enabling it.

---

## Safety

* A run only changes something if the IdP returned the complete list of users and groups. Connection errors or LDAP size limits abort the run without any change.
* A run is **Blocked** if it would disable more than `Change limit (%)` of the active IdP mailboxes or remove more than `Change limit (%)` of the IdP group memberships, at least 5 each. A blocked run changes nothing at all, it also does not create, link or update mailboxes. Check the changes with **Preview** and use **Run without limit** if they are expected.

!!! warning "LDAP size limit"
    mailcow reads the users with a paged search. If the LDAP server still limits the number of results (e.g. OpenLDAP with its default limit of 500 entries), raise the limit for the bind user. Otherwise every run aborts.

---

## Groups

With `Group sync` enabled, mailcow syncs the members of IdP groups to [mailcow groups](u_e-mailcow_ui-groups.md).

**Keycloak**

* `Group paths`: Comma-separated group paths, e.g. `/Sales`, `/mailcow/*` for all groups below `/mailcow` or `/*` for all groups.
* Only direct members of a group count, members of its subgroups do not.
* The mail address of a group comes from its group attribute `mail`.

**LDAP**

* `Group Base DN`: Where the groups are searched. Empty = `Base DN`.
* `Group filter`: Required, e.g. `(objectClass=group)` for Active Directory or `(objectClass=groupOfNames)` for OpenLDAP. If it is empty while `Group sync` is enabled, every run fails.
* `Group name attribute`: Attribute with the group name. Default: `cn`.
* `Memberships`: How memberships are read:
    * `memberOf of the users`: The `memberOf` attribute of the users (Active Directory, OpenLDAP with memberOf overlay).
    * `Member attribute of the groups`: The attribute in `Member attribute` of the groups, e.g. `member` or `uniqueMember`. Active Directory returns the members of large groups in ranges, mailcow then aborts the run. For Active Directory, use one of the other two modes.
    * `Active Directory incl. nested groups`: Members of nested groups count as members, too.
* The mail address of a group comes from its attribute `mail`.

**Both**

* `Create groups` (default: on): Creates a mailcow group for every IdP group that has none yet, in the domain of the group's mail address. Groups without a mail address of a mailcow domain are created in the `Default group domain`. The mail address becomes the group address if it is free and the domain has aliases left.
* A mailcow group with the same name that is not linked to the IdP group is not taken over, mailcow reports a conflict. To link it, set its `idp_ref` with the [API](u_e-mailcow_ui-api.md).
* Only mailboxes with the IdP as authentication source become IdP members.
* Groups renamed in the IdP are renamed in mailcow. If a linked group is renamed in mailcow, the next run sets the IdP name again.
* If a group disappears from the IdP or no longer matches `Group paths` or `Group filter`, mailcow removes its IdP members, see [Safety](#safety). The group and its manual members stay.

Members from the IdP are marked **IdP** in mailcow, members added in mailcow stay. Address, send-as, shares and template of a group are maintained in mailcow.

---

## Templates

A mailbox from the IdP gets:

1. the template of its group with the highest priority, otherwise
2. the template from the `Attribute Mapping`, otherwise
3. the `Default Template`, only when the mailbox is created.

If no template matches, the mailbox is not created and the run reports a conflict.

At every login and with `Periodic Full Sync`, mailcow applies the template again if the mailbox was changed in the meantime. Manual changes to IdP mailboxes are overwritten then. A mailbox that leaves all groups gets the template from the attribute mapping again.

---

## Sync status

The card **Sync status** below the settings shows the last runs with their mode, result and changes. Conflicts are listed in the details of a run.

* **Preview**: Shows the changes of a run without applying them.
* **Run now**: Starts a run without waiting for the interval.
* **Run without limit**: Starts a run that ignores the change limit once.

Runs start within a minute. The log is found in `System > Information > Logs > Crontasks` (task `Identity Sync`).
