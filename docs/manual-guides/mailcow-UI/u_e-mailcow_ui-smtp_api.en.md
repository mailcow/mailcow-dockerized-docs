The mailcow webmail client (cow-app) provides a REST API endpoint for sending emails via SMTP. This allows users and applications to send emails programmatically through HTTP requests.

## API Endpoint

```
POST /app/api/smtp/send/
```

## Authentication

The API requires JWT authentication. You must first login to obtain a token:

```bash
# Login to get JWT token
curl -X POST "https://mail.example.com/app/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "your-password"
  }'
```

The response will include an `access_token` that you'll use for subsequent requests.

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
| `password` | string | SMTP password (if not using session) |
| `attachments` | array | List of attachment objects |
| `smtp_host` | string | Custom SMTP host (optional) |
| `smtp_port` | integer | Custom SMTP port (optional) |

### Attachment Format

Each attachment object should contain:

```json
{
  "filename": "document.pdf",
  "content": "base64-encoded-content",
  "content_type": "application/pdf"
}
```

## Example Request

### Basic Email

```bash
curl -X POST "https://mail.example.com/app/api/smtp/send/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -b "session=YOUR_SESSION_COOKIE" \
  -d '{
    "from": "sender@example.com",
    "to": ["recipient@example.com"],
    "subject": "Test Email",
    "body": "This is a test email sent via the SMTP API.",
    "password": "your-smtp-password"
  }'
```

### HTML Email with CC/BCC

```bash
curl -X POST "https://mail.example.com/app/api/smtp/send/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -b "session=YOUR_SESSION_COOKIE" \
  -d '{
    "from": "sender@example.com",
    "to": ["recipient@example.com"],
    "cc": ["cc@example.com"],
    "bcc": ["bcc@example.com"],
    "subject": "HTML Email",
    "body": "Plain text version",
    "html_body": "<html><body><h1>Hello!</h1><p>This is an HTML email.</p></body></html>",
    "password": "your-smtp-password"
  }'
```

## Response Codes

### Success

| Code | Description |
|------|-------------|
| `SMTP-200` | Email sent successfully |

### Errors

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `SMTP-100` | 401 | Authorization credentials invalid |
| `SMTP-101` | 400 | Missing required fields |
| `SMTP-102` | 404 | Account not found |
| `SMTP-103` | 400 | Password required for SMTP authentication |
| `SMTP-201` | 400 | SMTP authentication failed |
| `SMTP-202` | 400 | Recipients refused |
| `SMTP-203` | 400 | Sender refused |
| `SMTP-204` | 400 | SMTP error |
| `SMTP-205` | 400 | Unexpected error |

## UI Toggle

The webmail interface also includes a toggle switch "Send via SMTP API" in the compose email dialog. When enabled, emails are sent directly through the SMTP API instead of the sync engine.

## Use Cases

- **Automation**: Send emails from scripts or applications
- **Integration**: Integrate email sending into third-party applications
- **Direct SMTP**: Bypass the sync engine for direct SMTP delivery
- **Programmatic Access**: Build custom email clients or tools

