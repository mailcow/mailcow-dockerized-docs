# CrowdSec Integration

[Mailcow-Crowdsec](https://github.com/JoeRu/Mailcow-Crowdsec) is a community-maintained integration that adds CrowdSec log analysis and firewall enforcement to mailcow using `docker-compose.override.yml`. It adds services without editing mailcow's own Compose file. Please report integration issues to the [project's issue tracker](https://github.com/JoeRu/Mailcow-Crowdsec/issues).

## Features

- Reads Docker logs from Postfix, Dovecot and nginx using CrowdSec collections and additional local parsers and scenarios.
- Enforces CrowdSec ban decisions with an iptables/ipset firewall bouncer in the host's `INPUT`, `FORWARD` and `DOCKER-USER` chains.
- Includes configurable country-based SMTP authentication rules, repeat-offender scenarios and trusted IP/CIDR allowlists.
- Uses CrowdSec community threat intelligence; enrollment in the CrowdSec Console is optional.

## Requirements and installation

The project requires a running mailcow installation on a Linux host, Docker Compose v2, and root or sudo access. The included bouncer Dockerfile downloads a Linux **amd64** binary; check compatibility before using another architecture.

Follow the maintained [installation instructions](https://github.com/JoeRu/Mailcow-Crowdsec#installation). The setup consists of:

1. Copying the project's `crowdsec/` directory and Compose override into the mailcow installation directory. If an override already exists, merge the `services:` and `volumes:` sections instead of overwriting it. Keep mailcow's original Compose file unchanged.
2. Adjusting container names in `crowdsec/acquis.yaml` to match the running nginx, Postfix and Dovecot containers.
3. Reviewing `crowdsec/parsers/s02-enrich/whitelists.yaml` and adding trusted administration, VPN and monitoring addresses before enabling bans.
4. Reviewing the SMTP scenarios in `crowdsec/scenarios/`. The supplied country rules distinguish Germany (`DE`) from other countries; adapt both rules and their thresholds to your users.
5. Starting CrowdSec, then checking acquisition metrics to confirm that all three log sources are being read.
6. Registering the firewall bouncer with CrowdSec and inserting its API key into a copy of `crowdsec/cs-firewall-bouncer.yaml.example` named `crowdsec/cs-firewall-bouncer.yaml`.
7. Building and starting `cs-firewall-bouncer`, then verifying bouncer registration, firewall chains and ban decisions as described in the project's guide.

!!! warning "Review host access and ban rules"

    The bouncer uses host networking and the `NET_ADMIN` and `NET_RAW` capabilities to change the host firewall. Bans can affect access to services beyond mailcow. Keep a recovery connection available and review allowlists and scenarios to avoid locking yourself or legitimate users out.

    CrowdSec mounts `/var/run/docker.sock` read-only to read container logs. A read-only socket mount does not make Docker API access read-only; treat this as privileged access to the host.

## Security and maintenance

- Protect the bouncer configuration: it contains a secret LAPI API key and must not be committed or shared. The project excludes it with `.gitignore`.
- Keep the LAPI binding on `127.0.0.1:8080` as supplied, and check for port conflicts before installation.
- Review CrowdSec's community data-sharing settings before enabling the integration.
- The CrowdSec image uses `latest`, and the bouncer build fetches the latest upstream release by default. Review updates; the project documents pinning the bouncer with the `VERSION` build argument.
- Keep your override and custom configuration under review after mailcow updates. See the project's [bouncer upgrade instructions](https://github.com/JoeRu/Mailcow-Crowdsec#upgrading-the-bouncer) and review any optional update hook before installing it.

For parser, scenario and decision management, see the [CrowdSec documentation](https://docs.crowdsec.net/).
