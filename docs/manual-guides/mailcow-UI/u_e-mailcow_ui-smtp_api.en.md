mailcow provides a REST API endpoint for sending emails via SMTP. This allows users and applications to send emails programmatically through HTTP requests.

## API Endpoint

```
POST /api/v1/send/email
```

## Authentication

The API requires an API key with read-write access. You can generate an API key in the mailcow admin UI:

1. Log in as admin
2. Go to **Configuration** → **Access** → **Edit administrator details**
3. Expand the **API** section
4. Generate or copy your API key
5. Add your IP address to the allowed IPs list

Use the API key in the `X-API-Key` header for all requests.

## Request Format

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `from` | string | Sender email address |
| `to` | array | List of recipient email addresses |
| `subject` | string | Email subject |
| `body` | string | Plain text email body |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `html_body` | string | HTML version of the email body |
| `cc` | array | List of CC email addresses |
| `bcc` | array | List of BCC email addresses |
| `reply_to` | string | Reply-to email address |
| `attachments` | array | List of attachment objects |
| `smtp_host` | string | SMTP host (default: postfix-mailcow) |
| `smtp_port` | integer | SMTP port (default: 587 for authenticated) |
| `smtp_user` | string | SMTP username (required; mailbox) |
| `password` | string | SMTP password (required; mailbox) |

### Attachment Format

Each attachment object should contain:

```json
{
  "filename": "document.pdf",
  "content": "base64-encoded-content",
  "content_type": "application/pdf"
}
```

## Example Requests

### Basic Email (Unauthenticated Internal)

For sending via the internal postfix-mailcow container without authentication:

```bash
curl -X POST "https://mail.example.com/api/v1/send/email" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR-API-KEY" \
  -d '{
    "from": "sender@example.com",
    "to": ["recipient@example.com"],
    "subject": "Test Email",
    "body": "This is a test email sent via the SMTP API."
  }'
```

### Authenticated SMTP

For authenticated SMTP (recommended for production):

```bash
curl -X POST "https://mail.example.com/api/v1/send/email" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR-API-KEY" \
  -d '{
    "from": "sender@example.com",
    "to": ["recipient@example.com"],
    "subject": "Test Email",
    "body": "This is a test email.",
    "smtp_port": 587,
    "password": "your-mailbox-password"
  }'
```

### HTML Email with CC/BCC

```bash
curl -X POST "https://mail.example.com/api/v1/send/email" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR-API-KEY" \
  -d '{
    "from": "sender@example.com",
    "to": ["recipient@example.com"],
    "cc": ["cc@example.com"],
    "bcc": ["bcc@example.com"],
    "subject": "HTML Email",
    "body": "Plain text version",
    "html_body": "<html><body><h1>Hello!</h1><p>This is an HTML email.</p></body></html>",
    "password": "your-mailbox-password"
  }'
```

### Email with Attachment

```bash
# First, base64 encode your file
FILE_CONTENT=$(base64 -w 0 document.pdf)

curl -X POST "https://mail.example.com/api/v1/send/email" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR-API-KEY" \
  -d "{
    \"from\": \"sender@example.com\",
    \"to\": [\"recipient@example.com\"],
    \"subject\": \"Email with Attachment\",
    \"body\": \"Please find the attached document.\",
    \"password\": \"your-mailbox-password\",
    \"attachments\": [{
      \"filename\": \"document.pdf\",
      \"content\": \"${FILE_CONTENT}\",
      \"content_type\": \"application/pdf\"
    }]
  }"
```

## Response Format

### Success Response

```json
[
  {
    "type": "success",
    "log": ["smtp_api", "send", "..."],
    "msg": ["smtp_mail_sent", "sender@example.com", "recipient@example.com"]
  }
]
```

### Error Response

```json
[
  {
    "type": "error",
    "log": ["smtp_api", "send", "..."],
    "msg": "smtp_invalid_from"
  }
]
```

## Sender Authorization

The API enforces sender authorization at mailbox level. SMTP mailbox credentials are required, and the `from` address must be authorized.

### Authorized Senders

Non-admin users can only send from:

1. Their own mailbox address
2. Aliases that point to their mailbox
3. Addresses granted via sender ACL
4. Domain wildcards in sender ACL (e.g., `@domain.tld`)
5. Global wildcard (`*`) in sender ACL
6. External sender aliases

## Error Messages

| Error Code | Description |
|------------|-------------|
| `smtp_invalid_from` | Invalid sender email address |
| `smtp_auth_required` | SMTP username/password required |
| `smtp_unauthorized_sender` | Not authorized to send from this address |
| `smtp_missing_recipients` | No recipients specified |
| `smtp_invalid_recipient` | Invalid recipient email address |
| `smtp_empty_subject` | Email subject is empty |
| `smtp_empty_body` | Email body is empty |
| `smtp_invalid_cc` | Invalid CC email address |
| `smtp_invalid_bcc` | Invalid BCC email address |
| `smtp_invalid_reply_to` | Invalid reply-to email address |
| `smtp_invalid_attachment` | Invalid base64 encoded attachment |
| `smtp_error` | SMTP server error |

## SMTP Port Configuration

| Port | Security | Use Case |
|------|----------|----------|
| 25 | None | Internal sending (no auth required) |
| 587 | STARTTLS | Authenticated submission (recommended) |
| 465 | SSL/TLS | Authenticated submission (legacy) |

## Use Cases

- **Automation**: Send emails from scripts or cron jobs
- **Integration**: Integrate email sending into third-party applications
- **Notifications**: Automated system notifications
- **Transactional Emails**: Order confirmations, password resets, etc.
- **Webhook Responses**: Send emails triggered by webhooks

## Security Considerations

1. Always use HTTPS when calling the API
2. Keep your API key secure and rotate it periodically
3. Use authenticated SMTP (port 587/465) for sending as mailbox users
4. Restrict API access to specific IP addresses in the admin UI
5. Use a read-write API key only when necessary

