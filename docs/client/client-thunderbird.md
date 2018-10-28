<ol>
<li>
  Launch Thunderbird.
</li>
<li>
  If this is the first time you launched Thunderbird, it asks you whether you would like a new email address. Click <i>Skip this and use my existing email</i> and proceed to step 4.
</li>
<li>
  Go to the <i>Tools</i> menu and select <i>Account Settings</i>.
</li>
<li>
  Click the <i>Account Actions</i> dropdown menu at the bottom left and select <i>Add Mail Account</i>.
</li>
<li>
  Enter your name<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> and your password. Make sure the <i>Remember password</i> checkbox is selected and click <i>Continue</i>.
</li>
<li>
  Once the configuration has been automatically detected, click <i>Done</i>.
</li>
<li>
  If you already had other accounts configured in Thunderbird, select the new one<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> on the left, click the <i>Account Actions</i> dropdown and select Set as <i>Default</i>.
</li>
<li>
  Close the account settings window with the <i>OK</i> button.
</li>
<li class="client_integrator_enabled">
  In your web browser, download <span class="client_variables_unavailable">SOGo Integrator</span><span class="client_variables_available"><a class="client_var_integrator_link client_var_link" href="/thunderbird-plugins/sogo-integrator-__VERSION__-__DOMAIN__.xpi">SOGo Integrator</a></span>.
</li>
<li class="client_integrator_enabled">
  Back in Thunderbird, go to the <i>Tools</i> menu and select <i>Add-ons</i>.
</li>
<li class="client_integrator_enabled">
  Click <i>Extensions</i> on the left and ensure that the <i>Lightning</i> add-on is already installed. It is installed by default in the Windows and macOS versions of Thunderbird, but if you are running Linux and installed Thunderbird through your distribution's package manager, <i>Lightning</i> might be available as a separate package (e.g. xul-ext-lightning on Ubuntu).
</li>
<li class="client_integrator_enabled">
  Click <i>Extensions</i> on the left, click the little gear icon at the top and select <i>Install Add-on From File</i>. Select the file you downloaded in step 9, click <i>Open</i> and, after waiting for a few seconds, <i>Install Now</i>.
</li>
<li class="client_integrator_enabled">
  Click the <i>Restart Now</i> button at the top that appears.
</li>
<li class="client_integrator_enabled">
  Thunderbird briefly shows a message that it is updating extensions, then restarts automatically once more.
</li>
<li class="client_integrator_enabled">
  When you are prompted to authenticate<span class="client_variables_available"> for <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span>, enter your email address and password, check <i>Use Password Manager</i> and click <i>OK</i>.
</li>
</ol>

<div class="client_integrator_disabled client_variables_available" markdown="1">
Automatic configuration of calendars and address books in Thunderbird is not currently supported.
      You can ask your server administrator to enable SOGo Integrator if you need it.
</div>

<div class="client_variables_unavailable" markdown="1">
Automatic configuration of calendars and address books (from step 9 onward) in Thunderbird is only supported if your server administrator has enabled [SOGo Integrator](https://mailcow.github.io/mailcow-dockerized-docs/third_party-thunderbird).
</div>
