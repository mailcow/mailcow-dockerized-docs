mailcow uses the template engine [Jinja](https://jinja.palletsprojects.com/) for the notification mails.
Placeholders can be used to create dynamic content with these templates by replacing them with passed variables during execution. A documentation about the development of Jinja templates can be found [here](https://jinja.palletsprojects.com/en/3.1.x/templates/).

The following variables can be used for the notification email templates:

## Quarantine template

The provided variables can also be obtained on GitHub from the script [dovecot/quarantine_notify.py](https://github.com/mailcow/mailcow-dockerized/blob/master/data/Dockerfiles/dovecot/quarantine_notify.py#L94).

!!! info 
    As an administrator, you can edit the template for the quarantine mails in the mailcow user interface in the global quarantine settings and restore the default template there as well. 
    Code examples can be found in the default template. It can also be viewed on [Github](https://github.com/mailcow/mailcow-dockerized/blob/master/data/assets/templates/quarantine.tpl).

| Name           	| Content                                                                                        	|
|----------------	|------------------------------------------------------------------------------------------------	|
| username       	| E-mail address of the mailbox user                                                             	|
| counter        	| Number of messages in the quarantine, about which this e-mail informs                          	|
| hostname       	| Name of the mailcow instance (See also the environment variable _MAILCOW_HOSTNAME_)            	|
| quarantine_acl 	| Quarantine ACL setting of the mailbox user (Permission to process the mails in the quarantine) 	|
| meta           	| Array/list of all messages in the quarantine about which this e-mail informs                   	|
| meta.qhash     	| Hash value of the quarantine entry (e.g. for direct link to the message in the quarantine)     	|
| meta.id        	| ID of the quarantine entry                                                                     	|
| meta.subject   	| Title of the quarantine entry                                                                  	|
| meta.score     	| Spam score of the quarantine entry                                                             	|
| meta.sender    	| Sender address of the quarantine entry                                                         	|
| meta.created   	| Creation date of the quarantine entry / receipt of the e-mail                                  	|
| meta.action    	| Action of the spam filter (moved to spam folder or quarantine).                                	|


## Quota template

The provided variables can also be obtained on Github from the script [dovecot/quota_notify.py](https://github.com/mailcow/mailcow-dockerized/blob/master/data/Dockerfiles/dovecot/quota_notify.py#L45).

!!! info 
    The template for the quota mails can be edited as an administrator in the mailcow user interface in the quota settings and there also restore the default template. 
    Code examples can be found in the default template. It can also be viewed on [Github](https://github.com/mailcow/mailcow-dockerized/blob/master/data/assets/templates/quota.tpl).

| Name           	| Content                                                                                              	|
|----------------	|------------------------------------------------------------------------------------------------------	|
| username       	| E-mail address of the mailbox user                                                                   	|
| percent        	| Percentage of the occupied space of the mailbox                                                      	|

