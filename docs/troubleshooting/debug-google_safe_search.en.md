For some time now we have been receiving increasing reports that the mailcow UI is no longer reachable for some users. Instead, a Google Safe Search page is shown stating that the site has been classified as unsafe. 

This can occur even if you have not enabled Safe Search filtering for your site.

<figure markdown>
![Sample representation of the Google Safe Search page](../assets/images/troubleshooting/debug-google_safe_search.png)
<figcaption>Sample representation of the Google Safe Search page</figcaption>
</figure>

## Cause
Unfortunately, Google is not always transparent about how websites are classified.
There are various reasons a site may be marked as unsafe, for example:

- Malware on the site
- Phishing attempts
- Inappropriate content

For mailcow, however, these reasons are very unlikely unless your server has actually been compromised.

Because this also occurs on freshly installed mailcow instances, the cause usually lies elsewhere.

We suspect that Google has recently deployed a new AI model for Safe Search detection that may falsely flag sites similar to mailcow installations (since the mailcow login UI has a similar structure across servers).

## Possible solutions
1. Keep your mailcow installation up to date, as we continuously work to close known security vulnerabilities.
2. Add a logo to your mailcow installation that clearly identifies your organization or domain. This can help increase the perceived trustworthiness of your site.
3. Add an imprint or footer text; this also helps distinguish your instance from other mailcow installations.
4. Contact Google Support and request a review of your site. This may, however, take some time.

!!! info "Note"
    There is no guarantee these measures will be successful, as Google’s classification is automated and not always explainable.
    Nevertheless, it is worth trying—especially if you use mailcow for business purposes.

    **Please be aware that everything possible is being done to ensure the security and integrity of mailcow.**
