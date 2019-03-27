<div class="client_outlookEAS_enabled" markdown="1">

## Outlook 2016 or higher from Office 365 on Windows

<div class="client_variables_unavailable" markdown="1">
  This is only applicable if your server administrator has not disabled EAS for Outlook. If it is disabled, please follow the guide for Outlook 2007 instead.
</div>

Outlook 2016 has an [issue with autodiscover](https://github.com/mailcow/mailcow-dockerized/issues/615). Only Outlook from Office 365 is affected. If you installed Outlook from another source, please follow the guide for Outlook 2013 or higher. 

For EAS you must use the old assistant by launching `C:\Program Files (x86)\Microsoft Office\root\Office16\OLCFG.EXE`. If this application opens, you can go to step 4 of the guide for Outlook 2013 below.

If it does not open, you can completely [disable the new account creation wizard](https://support.microsoft.com/en-us/help/3189194/how-to-disable-simplified-account-creation-in-outlook) and follow the guide for Outlook 2013 below.

## Outlook 2013 or higher on Windows

<div class="client_variables_unavailable" markdown="1">
  This is only applicable if your server administrator has not disabled EAS for Outlook. If it is disabled, please follow the guide for Outlook 2007 instead.
</div>

1. Launch Outlook.
2. If this is the first time you launched Outlook, it asks you to set up your account. Proceed to step 4.
3. Go to the *File* menu and click *Add Account*.
4. Enter your name<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> and your password. Click *Next*.
5. When prompted, enter your password again, check *Remember my credentials* and click *OK*.
6. Click the *Allow* button.
7. Click *Finish*.

## Outlook 2007 or 2010 on Windows

</div>

<div class="client_outlookEAS_disabled" markdown="1">

## Outlook 2007 or higher on Windows

</div>

1. Download and install [Outlook CalDav Synchronizer](https://caldavsynchronizer.org).
2. Launch Outlook.
3. If this is the first time you launched Outlook, it asks you to set up your account. Proceed to step 5.
4. Go to the *File* menu and click *Add Account*.
5. Enter your name<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> and your password. Click *Next*.
6. Click *Finish*.
7. Go to the *CalDav Synchronizer* ribbon and click *Synchronization Profiles*.
8. Click the second button at top (*Add multiple profiles*), select *Sogo*, click *Ok*.
9. Click the *Get IMAP/POP3 account settings* button.
10. Click *Discover resources and assign to Outlook folders*.
11. In the *Select Resource* window that pops up, select your main calendar (usually *Personal Calendar*), click the *...* button, assign it to *Calendar*, and click *OK*. Go to the *Address Books* and *Tasks* tabs and repeat repeat the process accordingly. Do not assign multiple calendars, address books or task lists!
12. Close all windows with the *OK* buttons.

## Outlook 2011 or higher on macOS

The Mac version of Outlook does not synchronize calendars and contacts and therefore is not supported.
