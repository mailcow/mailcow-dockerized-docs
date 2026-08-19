!!! info "This guide should only be used by experienced administrators"
      This guide is intended for experienced administrators who need to adjust TLS policies for specific domains or IP addresses.  
      Improper changes to TLS settings can lead to delivery problems or insecure connections.

---

## Background

Since the **mailcow update in September 2025**, mailcow also checks **TLS policies of the recipient for outgoing SMTP connections**.  
Previously, this check applied only to incoming emails or to domains where the feature was explicitly enabled.

In rare cases this can cause emails to no longer be delivered — for example, if a recipient domain publishes faulty or invalid **TLSA records (DANE)**.  
Because Postfix (and thus mailcow) treats these records as authoritative according to [RFC 7672](https://datatracker.ietf.org/doc/html/rfc7672), delivery will be refused in such cases.

If you still want to deliver emails to such affected recipients — for example as a **workaround for faulty TLSA records** — you can set an override policy for the respective domain via the TLS policy management.  
Note that this deliberately bypasses security checks and should only be used **temporarily** or **with proper documentation**.

---

## Procedure

1. **Log in:**  
   Sign in to the mailcow web interface as an administrator.

2. **Navigation:**  
   Open **Email > Configuration**.

3. **Open TLS Policies:**  
   Switch to the **TLS Policies** tab.

4. **Add entry:**  
   Click **Add TLS policy entry**.

5. **Set target:**  
   Enter the affected domain or IP address in the **Target** field for which the policy should apply (e.g. `example.com`).

6. **Select policy:**  
   In the **Policy** dropdown choose one of the following options:
     - `none` – TLS will not be used, even if the target server offers it.  
     - `may` – TLS will be used if available, but is not required.  
     - `encrypt` – TLS is required, but certificates are not verified.  
     - `verify` – TLS is required and the server certificate is verified.  
     - `secure` – TLS is required; certificate and hostname must be valid.  
     - `dane` – TLS according to DANE policies, falls back to opportunistic TLS without a TLSA record.  
     - `dane-only` – TLS only via valid DANE/TLSA records, no fallback.  
     - `fingerprint` – TLS is required; the certificate must match a stored fingerprint.

    *Example:*  
    If a domain has faulty TLSA entries, you can temporarily choose `may` or `encrypt` to allow delivery.

7. **Optional parameters:**  
   In the **Parameters** field you can specify additional Postfix options, e.g.: `protocols=!SSLv2,!SSLv3` to disable legacy protocols.

    Separate parameters from each other with a blank line.

8. **Activate policy:**  
Enable the **Active** option so the policy is applied.

9. **Save:**  
Click **Add** to create and activate the policy.

The policy is now active.  
A **restart of mailcow or Postfix is not required** — the change takes effect immediately.

---

## Example use cases

| Situation | Recommended policy | Description |
|------------|----------------------|---------------|
| Target domain has invalid TLSA records | `may` | Opportunistic TLS to allow delivery despite faulty DANE entries. |
| Internal test systems without valid certificates | `encrypt` | Enforces encryption without certificate verification. |
| Partner domain with correctly configured DANE | `dane` | Secure delivery via DNSSEC-validated TLSA records. (mailcow default when recipient domain is compatible) |
| High-security environment with known certificates | `fingerprint` | Explicit certificate pinning for maximum control. |

!!! warning "Note"
      As soon as faulty TLSA records or certificate issues on the recipient side are resolved, you should **remove the temporarily set policy or reset it to the default value** to preserve the integrity of the TLS security model.

---

## Disabling the TLS policy checks completely

In rare cases a per-domain override is not enough - for example if a firewall with SMTP inspection (Cisco ASA `inspect esmtp`, FortiGate SMTP proxy and similar) or an intercepting relay at your provider removes `STARTTLS` from the EHLO response of the remote server. Postfix then sees a server that offers no TLS at all, while DANE or MTA-STS still demand it, and every affected mail stays in the queue.

To switch the checks off for all destinations, add the following to Postfix [extra.cf](u_e-postfix-extra_cf.en.md):

```bash
smtp_tls_security_level = may
smtp_dns_support_level = enabled
smtp_tls_policy_maps = proxy:mysql:/opt/postfix/conf/sql/mysql_tls_policy_override_maps.cf
```

- `smtp_tls_security_level = may` - opportunistic TLS: encrypt if the remote server offers `STARTTLS`, deliver unencrypted if it does not. The mailcow default is `dane`.
- `smtp_dns_support_level = enabled` - plain DNS lookups instead of the DNSSEC-validated ones, which are only needed for DANE. The mailcow default is `dnssec`.
- `smtp_tls_policy_maps` - same value as in `main.cf`, but without the `socketmap:inet:postfix-tlspol:8642:QUERY` entry, so Postfix no longer asks postfix-tlspol for MTA-STS and DANE policies. The TLS policy entries from the mailcow UI described above keep working.

Without `smtp_dns_support_level = dnssec` Postfix refuses the `dane` and `dane-only` policies, so do not combine this with such entries in the TLS policy table.

Restart Postfix to apply the change:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

Keep the `postfix-tlspol-mailcow` container running, `postfix-mailcow` depends on it. It simply stops receiving queries.

!!! info "Scope"
      These `smtp_*` parameters only apply to **outgoing** deliveries from Postfix to other mail servers on port 25. Incoming mail, submission on port 465/587 and the per-mailbox "TLS enforcement in/out" settings are not affected.

!!! warning "Note"
      Disabling the checks removes the downgrade protection for **all** recipients, an attacker on the path can then strip `STARTTLS` unnoticed. Use a per-domain policy whenever the problem is limited to single recipients and only fall back to this if your entire outgoing traffic is affected.
 