As of September 12, 2018 you can setup relayhosts as admin by using the mailcow UI.

This is useful if you want to relay outgoing emails for a specific domain to a third-party spam filter or a service like Mailgun or Sendgrid. This is also known as a _smarthost_.

## Add a new relayhost
Go to the `Routing` tab of the `Configuration and Details` section of the admin UI.
Here you will see a list of relayhosts currently setup.

Scroll to the `Add sender-dependent transport` section.

Under `Host`, add the host you want to relay to. <br>
_Example: if you want to use Mailgun to send emails instead of your server IP, enter smtp.mailgun.org_

If the relay host requires a username and password to authenticate, enter them in the respective fields. <br>
Keep in mind the credentials will be stored in plain text.

### Test a relayhost
To test that connectivity to the host works, click on `Test` from the list of relayhosts and enter a _From:_ address. Then, run the test.

You will then see the results of the SMTP transmission. If all went well, you should see
`SERVER -> CLIENT: 250 2.0.0 Ok: queued as A093B401D4` as one of the last lines.

If not, review the error provided and resolve it.

**Note:** Some hosts, especially those who do not require authentication, will deny connections from servers that have not been added to their system beforehand. Make sure you read the documentation of the relayhost to make sure you've added your domain and/or the server IP to their system.

**Tip:** You can change the default test _To:_ address the test uses from _null@mailcow.email_ to any email address you choose by modifying the _$RELAY_TO_ variable on the _vars.inc.php_ file under _/opt/mailcow-dockerized/data/web/inc_ <br> This way you can check that the relay worked by checking the destination mailbox.

## Set the relayhost for a domain
Go to the `Domains` tab of the `Mail setup` section of the admin UI.

Edit the desired domain.

Select the newly added host on the `Sender-dependent transports` dropdown and save changes.

Send an email from a mailbox on that domain and you should see postfix handing the message over to the relayhost in the logs.