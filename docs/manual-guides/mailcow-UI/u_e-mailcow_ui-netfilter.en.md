## Change Netfilter Ban Settings

To change the Netfilter settings in general please navigate to: `Configuration -> Configuration & Details -> Configuration -> Fail2ban parameters`.

You should now see a familar interface:

![Netfilter ban settings](../../assets/images/manual-guides/mailcow-netfilter_settings.en.png)

Here you can set several options regarding the bans itself. 
For example the max. Ban time or the max. attempts before a ban is executed.

## Change Netfilter Regex

!!! danger
	The following area requires at least basic regex knowledge. <br>
	If you are not sure what you are doing there, we can only advise you not to attempt a reconfiguration.

In addition to the ban settings, you can also define what exactly should be used from the mailcow container logs to ban a possible attacker.

To do this, you must first expand the regex field, which will look something like this:

![Netfilter Regex](../../assets/images/manual-guides/mailcow-netfilter_regex.en.png)
	
There you can now create various new filter rules.

!!! info
	As updates progress, it is possible that new Netfilter regex rules will be added or removed. <br>
	If this is the case, it is recommended to reset the Netfilter regex rules by clicking on `Reset to default`.