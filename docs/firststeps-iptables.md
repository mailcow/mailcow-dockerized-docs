When running a machine which is publicly available it is mandatory to secure it.
One step is to use a firewall like _iptables_ to block all ports that should not be opened to the public.

This guide mainly copies a [blog entry at unrouted.io](https://unrouted.io/2017/08/15/docker-firewall/) and makes the essential points available here.
There are more measurements that should be taken to secure a machine.

## Make iptables rules persistent 

Install `iptables-persistent` to make iptables rules persistent

    sudo apt-get install iptables-persistent

## Create own filter chain

Create `/etc/iptables.conf` that looks like this:

    *filter
    :INPUT ACCEPT [0:0]
    :FORWARD DROP [0:0]
    :OUTPUT ACCEPT [0:0]
    :FILTERS - [0:0]
    :DOCKER-USER - [0:0]
    
    ## explicit flush  
    -F INPUT
    -F DOCKER-USER
    -F FILTERS
    
    ## add FILTERS-chain 
    -A INPUT -i lo -j ACCEPT
    -A INPUT -p icmp --icmp-type any -j ACCEPT
    -A INPUT -j FILTERS
    
    -A DOCKER-USER -i ens33 -j FILTERS
    
    ## add own rules
    -A FILTERS -m state --state ESTABLISHED,RELATED -j ACCEPT
    ## SSH
    -A FILTERS -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
    ## Webserver
    -A FILTERS -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
    -A FILTERS -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
    ## mailcow
    -A FILTERS -m state --state NEW -p tcp -m tcp --dport 25 -j ACCEPT
    -A FILTERS -m state --state NEW -p tcp -m tcp --dport 465 -j ACCEPT
    -A FILTERS -m state --state NEW -p tcp -m tcp --dport 587 -j ACCEPT
    -A FILTERS -m state --state NEW -p tcp -m tcp --dport 993 -j ACCEPT
    -A FILTERS -m state --state NEW -p tcp -m tcp --dport 995 -j ACCEPT
    -A FILTERS -m state --state NEW -p tcp -m tcp --dport 4190 -j ACCEPT
    ## ELSE REJECT
    -A FILTERS -j REJECT --reject-with icmp-host-prohibited

    
    COMMIT
    
Those rules add a new chain to iptables and allow the required ports

## Load into kernel

To load your own rules into kernel execute:
 
    sudo iptables-restore -n /etc/iptables.conf
Note that the `-n` flag turns off the implicit global flush for iptables.
That is why there is an explicit flush in the rules file.
This is done to preserve iptables rules made by docker.

## Starting your firewall at boot

Add a new file `/etc/system/system/iptables.service` with this content:

    [Unit]
    Description=Restore iptables firewall rules
    Before=network-pre.target
    
    [Service]
    Type=oneshot
    ExecStart=/sbin/iptables-restore -n /etc/iptables.conf
    
    [Install]
    WantedBy=multi-user.target
    
And enable it `sudo systemctl enable --now iptables`

If your version of systemctl doesn't support this you can do it the _old_ way:

    sudo systemctl enable iptables
    sudo systemctl start iptables
    
To update your firewall now:

    sudo systemctl restart iptables