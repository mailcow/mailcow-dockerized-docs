!!! info "Note"
    This guide requires mailcow version **2025-09** or newer.

!!! danger "If manually setup before, be aware"
    If you previously configured MTA‑STS manually for your domain in mailcow, be aware any existing MTA‑STS files (for example .well-known/mta-sts.txt) are no longer reachable after this update. mailcow now serves MTA‑STS policies dynamically based on the domain's MTA‑STS setting in the UI and uses the configuration stored there.

    mailcow does not create any MTA-STS files in the .well-known directory, all content is generated dynamically via PHP code.

!!! warning "Important"
    MTA-STS is particularly useful for domains that do not support (or cannot support) DANE. If you already use DANE (DNS-based Authentication of Named Entities), MTA-STS is not strictly necessary, but can be used in addition to further improve security.

## What is MTA-STS?
MTA-STS (Mail Transfer Agent Strict Transport Security) is a security standard designed to improve the security of email transmissions. It allows domain owners to publish policies that require emails to be transmitted only over secure connections (TLS). This helps prevent man-in-the-middle attacks and ensures the integrity and confidentiality of email communication.

mailcow now supports managing MTA-STS policies directly through the mailcow UI, which was implemented as part of the "E-Mail-Sicherheitsjahr 2025" (Translates to "Email Security Year 2025") initiative of the German Federal Office for Information Security (BSI). mailcow actively participates in this initiative to promote general improvement of email security and make the configuration of those easier to accomplish.

## Requirements
- mailcow version **2025-09** or newer
- A domain that points to your mailcow installation
- A valid SSL certificate for your domain (e.g. from Let's Encrypt)
- Access to your domain's DNS settings

## Step 1: Enable MTA-STS in the mailcow UI
1. Log in to the mailcow UI as an administrator.
2. Navigate to **E-Mail** :material-arrow-right: **Configuration**, followed by the **Domains** tab.
3. Edit the domain for which you want to enable MTA-STS (click **Edit**).
4. You should now see the **MTA-STS** tab, which looks similar to the following: ![MTA-STS Tab](../assets/images/post_installation/mta-sts-tab.png)
5. Let's briefly go through all options:
    - **Version**: The current version of the MTA-STS policy. Currently only version 1 (STSv1) is defined by the RFC standard.
    - **Mode**: Choose the desired mode:
        - `none`: policy is disabled (monitoring only)
        - `testing`: policy is active, but violations are only logged
        - `enforce`: policy is active and violations are blocked
    - **Maximum Age**: Specify how long mail servers should cache the policy (in seconds). The recommended value is 86400 seconds (1 day).
    - **MX entries**: Enter the MX records of your domain here, separated by commas. These records indicate which mail servers are authorized to receive email for your domain.
6. After making the desired settings, check **Active** and click **Save changes**.

## Step 2: Add DNS record for MTA-STS
1. Create a new DNS TXT record for your domain with the name `_mta-sts.yourdomain.tld` (replace `yourdomain.tld` with your actual domain).
2. The value of the TXT record should look like this:
   ```
    v=STSv1; id=2024090101
   ```
   - `v=STSv1`: Indicates the version of the MTA-STS policy.
   - `id=2024090101`: A unique identifier for the policy that should be incremented each time the policy changes (e.g. date of change in the format YYYYMMDDHH).

    !!! info "Note"
        When changing the MTA-STS policy (e.g. changing the mode or the MX entries), the `id` in the DNS record must be increased so that receiving mail servers recognize the new policy.

        mailcow automatically generates a new `id` when you make changes in the mailcow UI and save them.

        You can always retrieve the currently valid id using the DNS Check within the mailcow UI (blue DNS Check button).

        In general, after enabling MTA-STS in the mailcow UI you should always use the DNS Check to ensure that the DNS records (TXT and CNAME) are set correctly and have propagated.

3. Create another DNS CNAME record for your domain with the name `mta-sts.yourdomain.tld` that points to the mailcow FQDN (e.g. `mail.yourdomain.tld`, replace `mail.yourdomain.tld` with your actual FQDN).

    !!! warning "Important"
        The CNAME record is required so that a valid SSL certificate can be generated (assuming mailcow generates the certificates) and receiving mail servers can retrieve the MTA-STS policy. mailcow hosts the policy file centrally to simplify management.

4. Wait for the DNS changes to propagate. This can take some time depending on the TTL settings of your DNS records.

## Step 3: Verifying the MTA-STS configuration
1. After the DNS records have propagated, you can verify the MTA-STS configuration.
2. Use an online tool like [Hardenize](https://www.hardenize.com/) or the [MTA-STS Validator from Mailhardener](https://www.mailhardener.com/tools/mta-sts-validator) to check whether your MTA-STS policy is set up correctly.
3. Alternatively, you can also use the DNS Check in the mailcow UI to ensure that the DNS records are set correctly.

## Step 4: Monitoring and adjustments
1. Monitor the email logs in the mailcow UI to ensure that no legitimate emails are being blocked.
2. If you find that legitimate emails are being blocked, you can temporarily set the mode to `testing` to log violations without blocking emails.
3. Adjust the MX entries and other settings as needed and increase the `id` in the DNS record with every change.
4. Once you are confident that everything is working correctly, you can set the mode to `enforce` to fully enforce the policy.