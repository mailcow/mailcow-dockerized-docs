#!/bin/bash

set -e

MAILHOST=$1
if [ "$MAILHOST" = "" ]; then
	echo "Usage: echo example.com example.org | $0 mailcow.example.com"
	exit 1
fi

cd $(dirname $0)

# download SOGo Connector (TB68+)
wget -O connector.tar.gz https://github.com/inverse-inc/sogo-connector/archive/master.tar.gz

mkdir -p connector
tar --strip-components=1 -C connector -xf connector.tar.gz

# download SOGo Integrator & Connector (TB60)
wget -O integrator.tb60.tar.gz https://github.com/inverse-inc/sogo-integrator.tb60/archive/master.tar.gz
wget -O connector.tb60.tar.gz https://github.com/inverse-inc/sogo-connector.tb60/archive/master.tar.gz

mkdir -p integrator.tb60 connector.tb60
tar --strip-components=1 -C integrator.tb60 -xf integrator.tb60.tar.gz
tar --strip-components=1 -C connector.tb60 -xf connector.tb60.tar.gz

# build custom SOGo plugins
while read DOMAINS; do
	for DOMAIN in $DOMAINS; do
		# build SOGo Connector (TB68+)
		echo "Building SOGo Connector (TB68+) for $DOMAIN hosted on $MAILHOST"
		cd connector
		mkdir -p custom/${DOMAIN}
		cp -r custom/sogo-demo/* custom/${DOMAIN}/
		sed -i "s/http:\/\/sogo-demo\.inverse\.ca/https:\/\/${MAILHOST}/g" custom/${DOMAIN}/chrome/content/sogo-connector/global/extensions.rdf
		sed -i "s/plugins\/updates\.php[?]/thunderbird-plugins.php?domain=${DOMAIN}\&amp;/g" custom/${DOMAIN}/chrome/content/sogo-connector/global/extensions.rdf
		echo 'pref("sogo-connector.autocomplete.server.urlid", "'${DOMAIN}'");' > custom/${DOMAIN}/defaults/preferences/site.js
		echo 'pref("mail.collect_email_address_outgoing", false);' >> custom/${DOMAIN}/defaults/preferences/site.js
		sed -i 's/<\/Seq>/<li><Description em:id="dkim_verifier@pl" em:name="DKIM Verifier"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/sogo-connector/global/extensions.rdf
		sed -i 's/<\/Seq>/<li><Description em:id="EnhancedPriorityDisplay@kamens.us" em:name="Enhanced Priority Display"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/sogo-connector/global/extensions.rdf

		make build=${DOMAIN}
		CONNECTOR_VER=$(grep em:version install.rdf | awk -F '"' '{print $2}')
		CONNECTOR_MIN_VER=$(grep em:minVersion install.rdf | grep -Eo '[0-9\.*]+' | head -n 1)
		CONNECTOR_MAX_VER=$(grep em:maxVersion install.rdf | grep -Eo '[0-9\.*]+' | head -n 1)
		mv -f sogo-connector-${CONNECTOR_VER}-*.xpi ../sogo-connector-${CONNECTOR_VER}-${DOMAIN}.xpi
		cd ..

		# build SOGo Integrator (TB60)
		echo "Building SOGo Integrator (TB60) for $DOMAIN hosted on $MAILHOST"
		cd integrator.tb60
		echo > defaults/preferences/site.js
		mkdir -p custom/${DOMAIN}
		cp -r custom/sogo-demo/* custom/${DOMAIN}/
		sed -i "s/http:\/\/sogo-demo\.inverse\.ca/https:\/\/${MAILHOST}/g" custom/${DOMAIN}/chrome/content/extensions.rdf
		sed -i "s/plugins\/updates\.php[?]/thunderbird-plugins.php?domain=${DOMAIN}\&amp;/g" custom/${DOMAIN}/chrome/content/extensions.rdf
		echo 'pref("sogo-integrator.autocomplete.server.urlid", "'${DOMAIN}'");' > custom/${DOMAIN}/defaults/preferences/site.js
		echo 'pref("mail.collect_email_address_outgoing", false);' >> custom/${DOMAIN}/defaults/preferences/site.js
		sed -i 's/<\/Seq>/<li><Description em:id="sieve@mozdev.org" em:name="Sieve"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/extensions.rdf
		sed -i 's/<\/Seq>/<li><Description em:id="imap-acl@sirphreak.com" em:name="Imap-ACL-Extension"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/extensions.rdf
		sed -i 's/<\/Seq>/<li><Description em:id="{c1ac4523-76c2-9995-adbd-d93bf5141bea}" em:name="Display Quota"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/extensions.rdf
		sed -i 's/<\/Seq>/<li><Description em:id="dkim_verifier@pl" em:name="DKIM Verifier"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/extensions.rdf
		sed -i 's/<\/Seq>/<li><Description em:id="EnhancedPriorityDisplay@kamens.us" em:name="Enhanced Priority Display"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/extensions.rdf
		sed -i 's/<\/Seq>/<li><Description em:id="{9533f794-00b4-4354-aa15-c2bbda6989f8}" em:name="FireTray"\/><\/li>\<\/Seq>/g' custom/${DOMAIN}/chrome/content/extensions.rdf
		
		make build=${DOMAIN}
		INTEGRATOR_TB60_VER=$(grep em:version install.rdf | awk -F '"' '{print $2}')
		INTEGRATOR_TB60_MIN_VER=$(grep em:minVersion install.rdf | grep -Eo '[0-9\.*]+' | head -n 1)
		INTEGRATOR_TB60_MAX_VER=$(grep em:maxVersion install.rdf | grep -Eo '[0-9\.*]+' | head -n 1)
		mv -f sogo-integrator-*-${DOMAIN}.xpi ../sogo-integrator-${INTEGRATOR_TB60_VER}-${DOMAIN}.xpi
		cd ..
	done
done

# build SOGo Connector (TB60)
cd connector.tb60
make
CONNECTOR_TB60_VER=$(grep em:version install.rdf | awk -F '"' '{print $2}')
CONNECTOR_TB60_MIN_VER=$(grep em:minVersion install.rdf | grep -Eo '[0-9\.*]+' | head -n 1)
CONNECTOR_TB60_MAX_VER=$(grep em:maxVersion install.rdf | grep -Eo '[0-9\.*]+' | head -n 1)
mv -f sogo-connector-*.xpi ../sogo-connector-${CONNECTOR_TB60_VER}.xpi
cd ..

# remove SOGo plugins sources
rm -rf connector.tar.gz connector integrator.tb60.tar.gz integrator.tb60 connector.tb60.tar.gz connector.tb60

# download Sieve plugin
SIEVE_RELEASES=$(wget -qO - 'https://addons.thunderbird.net/en-US/thunderbird/addon/sieve/')
SIEVE_VER=$(echo "$SIEVE_RELEASES" | grep version-number | awk -F '[<>]' '{print $3}' | head -n 1)
SIEVE_MIN_VER=$(echo "$SIEVE_RELEASES" | grep data-min | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
SIEVE_MAX_VER=$(echo "$SIEVE_RELEASES" | grep data-max | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
SIEVE_URL=$(echo "$SIEVE_RELEASES" | grep -o 'https://.*\.xpi' | head -n 1)
wget -O sieve-${SIEVE_VER}.xpi ${SIEVE_URL}
unset SIEVE_RELEASES

# download ACL plugin
IMAP_ACL_RELEASES=$(wget -qO - 'https://addons.thunderbird.net/en-US/thunderbird/addon/imap-acl-extension/')
IMAP_ACL_VER=$(echo "$IMAP_ACL_RELEASES" | grep version-number | awk -F '[<>]' '{print $3}' | head -n 1)
IMAP_ACL_MIN_VER=$(echo "$IMAP_ACL_RELEASES" | grep data-min | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
IMAP_ACL_MAX_VER=$(echo "$IMAP_ACL_RELEASES" | grep data-max | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
IMAP_ACL_URL=$(echo "$IMAP_ACL_RELEASES" | grep -o 'https://.*\.xpi' | head -n 1)
wget -O imap_acl_extension-${IMAP_ACL_VER}-tb.xpi ${IMAP_ACL_URL}
unset IMAP_ACL_RELEASES

# download Display Quota plugin
DQ_ACL_RELEASES=$(wget -qO - 'https://addons.thunderbird.net/en-US/thunderbird/addon/display-quota/')
DQ_ACL_VER=$(echo "$DQ_ACL_RELEASES" | grep version-number | awk -F '[<>]' '{print $3}' | head -n 1)
DQ_ACL_MIN_VER=$(echo "$DQ_ACL_RELEASES" | grep data-min | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
DQ_ACL_MAX_VER=$(echo "$DQ_ACL_RELEASES" | grep data-max | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
DQ_ACL_URL=$(echo "$DQ_ACL_RELEASES" | grep -o 'https://.*\.xpi' | head -n 1)
wget -O display_quota-${DQ_ACL_VER}-tb.xpi ${DQ_ACL_URL}
unset DQ_ACL_RELEASES

# download DKIM Verifier plugin (current release TB68+)
DKIMV_ACL_RELEASES=$(wget -qO - 'https://addons.thunderbird.net/en-US/thunderbird/addon/dkim-verifier/')
DKIMV_ACL_VER=$(echo "$DKIMV_ACL_RELEASES" | grep version-number | awk -F '[<>]' '{print $3}' | head -n 1)
DKIMV_ACL_MIN_VER=$(echo "$DKIMV_ACL_RELEASES" | grep data-min | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
DKIMV_ACL_MAX_VER=$(echo "$DKIMV_ACL_RELEASES" | grep data-max | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
DKIMV_ACL_URL=$(echo "$DKIMV_ACL_RELEASES" | grep -o 'https://.*\.xpi' | head -n 1)
wget -O dkim_verifier-${DKIMV_ACL_VER}-tb.xpi ${DKIMV_ACL_URL}
unset DKIMV_ACL_RELEASES

# download DKIM Verifier plugin (release for TB60)
DKIMV_TB60_ACL_VER='2.1.0'
DKIMV_TB60_ACL_MIN_VER='52.0'
DKIMV_TB60_ACL_MAX_VER='60.*'
DKIMV_TB60_ACL_URL='https://addons.thunderbird.net/thunderbird/downloads/file/1015240/dkim_verifier-${DKIMV_TB60_ACL_VER}-tb.xpi'
wget -O dkim_verifier-${DKIMV_TB60_ACL_VER}-tb.xpi ${DKIMV_TB60_ACL_URL}

# download Enchanced Priority Display plugin (current release TB68+)
EPD_ACL_RELEASES=$(wget -qO - 'https://addons.thunderbird.net/en-US/thunderbird/addon/enhanced-priority-display/')
EPD_ACL_VER=$(echo "$EPD_ACL_RELEASES" | grep version-number | awk -F '[<>]' '{print $3}' | head -n 1)
EPD_ACL_MIN_VER=$(echo "$EPD_ACL_RELEASES" | grep data-min | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
EPD_ACL_MAX_VER=$(echo "$EPD_ACL_RELEASES" | grep data-max | awk -F '[<>]' '{print $1}' | head -n 1 | awk -F '[""]' '{print $2}')
EPD_ACL_URL=$(echo "$EPD_ACL_RELEASES" | grep -o 'https://.*\.xpi' | head -n 1)
wget -O enhanced_priority_display-${EPD_ACL_VER}-tb.xpi ${EPD_ACL_URL}
unset EPD_ACL_RELEASES

# download Enchanced Priority Display plugin (release for TB60)
EPD_TB60_ACL_VER='1.8.2'
EPD_TB60_ACL_MIN_VER='3.0a1pre'
EPD_TB60_ACL_MAX_VER='60.*'
EPD_TB60_ACL_URL='https://addons.thunderbird.net/thunderbird/downloads/file/1012004/enhanced_priority_display-${EPD_TB60_ACL_VER}-sm+tb.xpi'
wget -O enhanced_priority_display-${EPD_TB60_ACL_VER}-tb.xpi ${EPD_TB60_ACL_URL}

# download FireTray plugin
FTRAY_ACL_VER='0.6.5'
FTRAY_ACL_MIN_VER='7.0'
FTRAY_ACL_MAX_VER='60.*'
FTRAY_ACL_URL="https://github.com/Ximi1970/FireTray/releases/download/v${FTRAY_ACL_VER}/firetray-${FTRAY_ACL_VER}.xpi"
wget -O firetray-${FTRAY_ACL_VER}.xpi ${FTRAY_ACL_URL}
unset FTRAY_ACL_RELEASE

# update version file
echo "sogo-connector@inverse.ca;${CONNECTOR_VER};sogo-connector-${CONNECTOR_VER}-__DOMAIN__.xpi;${CONNECTOR_MIN_VER};${CONNECTOR_MAX_VER}" > version.csv
echo "sogo-integrator@inverse.ca;${INTEGRATOR_TB60_VER};sogo-integrator-${INTEGRATOR_TB60_VER}-__DOMAIN__.xpi;${INTEGRATOR_TB60_MIN_VER};${INTEGRATOR_TB60_MAX_VER}" >> version.csv
echo "sogo-connector@inverse.ca;${CONNECTOR_TB60_VER};sogo-connector-${CONNECTOR_VER}.xpi;${CONNECTOR_TB60_MIN_VER};${CONNECTOR_TB60_MAX_VER}" >> version.csv
echo "sieve@mozdev.org;${SIEVE_VER};sieve-${SIEVE_VER}.xpi;${SIEVE_MIN_VER};${SIEVE_MAX_VER}" >> version.csv
echo "imap-acl@sirphreak.com;${IMAP_ACL_VER};imap_acl_extension-${IMAP_ACL_VER}-tb.xpi;${IMAP_ACL_MIN_VER};${IMAP_ACL_MAX_VER}" >> version.csv
echo "{c1ac4523-76c2-9995-adbd-d93bf5141bea};${DQ_ACL_VER};display_quota-${DQ_ACL_VER}-tb.xpi;${DQ_ACL_MIN_VER};${DQ_ACL_MAX_VER}" >> version.csv
echo "dkim_verifier@pl;${DKIMV_ACL_VER};dkim_verifier-${DKIMV_ACL_VER}-tb.xpi;${DKIMV_ACL_MIN_VER};${DKIMV_ACL_MAX_VER}" >> version.csv
echo "dkim_verifier@pl;${DKIMV_TB60_ACL_VER};dkim_verifier-${DKIMV_TB60_ACL_VER}-tb.xpi;${DKIMV_TB60_ACL_MIN_VER};${DKIMV_TB60_ACL_MAX_VER}" >> version.csv
echo "EnhancedPriorityDisplay@kamens.us;${EPD_ACL_VER};enhanced_priority_display-${EPD_ACL_VER}-tb.xpi;${EPD_ACL_MIN_VER};${EPD_ACL_MAX_VER}" >> version.csv
echo "EnhancedPriorityDisplay@kamens.us;${EPD_TB60_ACL_VER};enhanced_priority_display-${EPD_TB60_ACL_VER}-tb.xpi;${EPD_TB60_ACL_MIN_VER};${EPD_TB60_ACL_MAX_VER}" >> version.csv
echo "{9533f794-00b4-4354-aa15-c2bbda6989f8};${FTRAY_ACL_VER};firetray-${FTRAY_ACL_VER}.xpi;${FTRAY_ACL_MIN_VER};${FTRAY_ACL_MAX_VER}" >> version.csv
