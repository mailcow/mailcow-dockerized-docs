A domain wide footer is added to the outgoing mails of a domain, as HTML and as plain text.

## Set up a footer

1. Open `E-Mail > Configuration > Domains` and click `Edit` next to the domain.
2. Open the tab `Domain wide footer`.
3. Enter the footer in `HTML footer` and `PLAIN footer`. Mails with an HTML part get the HTML footer, plain text mails the plain one.
4. Optional:
    - `Exclude from footer`: mailboxes and aliases that send without the footer.
    - `Ignore footer on reply e-mails`: replies (mails with an `In-Reply-To` header) get no footer.
5. Save.

## Placeholders

The footer can contain these placeholders:

| Placeholder | Value |
| --- | --- |
| `{= auth_user =}` | Name of the authenticated user |
| `{= from_user =}` | Local part of the sender, e.g. `moo` for `moo@example.org` |
| `{= from_name =}` | Display name of the sender, e.g. `Mailcow` for `Mailcow <moo@example.org>` |
| `{= from_addr =}` | Address of the sender |
| `{= from_domain =}` | Domain of the sender |
| `{= foo =}` | Value of the custom attribute `foo` of the mailbox (`Custom attributes` on the mailbox edit page) |

Unknown placeholders are replaced by an empty text.
