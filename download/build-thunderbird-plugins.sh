#!/bin/bash

set -e

MAILHOST=$1
if [ "$MAILHOST" = "" ]; then
	echo "Usage: echo example.com example.org | $0 mailcow.example.com"
	exit 1
fi

cd $(dirname $0)

# we have to use the master branch, because there is no tag or release at the moment
wget -O connector.zip https://github.com/inverse-inc/sogo-connector/archive/master.zip
unzip connector.zip

# build custom connector
while read DOMAINS; do
	for DOMAIN in $DOMAINS; do
		echo "Building SOGo Connector for $DOMAIN hosted on $MAILHOST"
		cd sogo-connector-master
		mkdir -p custom/${DOMAIN}
		cp -r custom/sogo-demo/* custom/${DOMAIN}/
		sed -i "s/https:\/\/demo\.sogo\.nu/https:\/\/${MAILHOST}/g" custom/${DOMAIN}/chrome/content/sogo-connector/general/custom-preferences.js
		sed -i "s/plugins\/updates\.php[?]/thunderbird-plugins.php?domain=${DOMAIN}\&amp;/g" chrome/content/sogo-connector/global/extensions.rdf
		# adjust sogo-connector.autocomplete.server.urlid
		sed -i "s/\"public\"/\"${MAILHOST}\"/g" custom/${DOMAIN}/chrome/content/sogo-connector/general/custom-preferences.js
		# remove wrong timezone setting
		sed -i 's/char_pref(\"calendar\.timezone\.local\", \"\/mozilla\.org\/20070129_1\/America\/Montreal\");//g' custom/${DOMAIN}/chrome/content/sogo-connector/general/custom-preferences.js

		echo 'bool_pref("mail.collect_email_address_outgoing", false);' >> custom/${DOMAIN}/chrome/content/sogo-connector/general/custom-preferences.js
		make build=${DOMAIN}
		CONNECTOR_VER=$(grep \"version\" manifest.json | awk -F '"' '{print $4}')
		CONNECTOR_MIN_VER=$(grep strict_min_version manifest.json | grep -Eo '[0-9\.]+' | head -n 1)
		mv sogo-connector-*.xpi ../sogo-connector-${CONNECTOR_VER}-${DOMAIN}.xpi
		cd ..
	done
done

# if you add any other plugins below, you need to add them into extensions.rdf as in the line commented out above

# # download Sieve plugin
# SIEVE_RELEASES=$(wget --header="Accept: application/vnd.github.v3+json" -qO - https://api.github.com/repos/thsmi/sieve/releases)
# SIEVE_VER=$(echo "$SIEVE_RELEASES" | grep -o '"tag_name": *"[^"]*"' | head -n 1 | awk -F '"' '{print $4}')
# SIEVE_URL=$(echo "$SIEVE_RELEASES" | grep -o '"browser_download_url": *"[^"]*"' | head -n 1 | awk -F '"' '{print $4}')
# wget -O sieve-${SIEVE_VER}.xpi ${SIEVE_URL}
# unset SIEVE_RELEASES
#
# # download ACL plugin
# IMAP_ACL_RELEASES=$(wget -qO - 'https://addons.thunderbird.net/en-US/thunderbird/addon/imap-acl-extension/')
# IMAP_ACL_VER=$(echo "$IMAP_ACL_RELEASES" | grep version-number | awk -F '[<>]' '{print $3}' | head -n 1)
# IMAP_ACL_URL=$(echo "$IMAP_ACL_RELEASES" | grep -o 'https://.*\.xpi' | head -n 1)
# wget -O imap_acl_extension-${IMAP_ACL_VER}-tb.xpi ${IMAP_ACL_URL}
# unset IMAP_ACL_RELEASES

# update version file
echo "sogo-connector@inverse.ca;${CONNECTOR_VER};sogo-connector-${CONNECTOR_VER}-__DOMAIN__.xpi;${CONNECTOR_MIN_VER}" > version.csv
# echo "sieve@mozdev.org;${SIEVE_VER};sieve-${SIEVE_VER}.xpi" >> version.csv
# echo "imap-acl@sirphreak.com;${IMAP_ACL_VER};imap_acl_extension-${IMAP_ACL_VER}-tb.xpi" >> version.csv

rm -rf sogo-connector-master *.zip
