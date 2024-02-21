# Server creation
This is pretty straight forward in the Hetzner console:

1. Create server
2. Good defaults
    + Helsinki (no particular reason over Germany)
    + Debian 12
    + Dedicated vCPU
        - This is for predictability and throughput. It is slightly more
          expensive but not overly so.
    + Otherwise cheapest at the time CCX13
3. Add ssh public key for auth (~/.ssh/id_rsa.pub)
4. Enable ipv4
5. No extra storage volume
    - These can be added later
    - We don't need much storage for our workload
    - Backups must be properly offsite anyway
6. No firewall
    - The firewall is an extra Hetzner concept, but I think the builtin
      iptables should do fine for now
    - At the time there is also no Hetzer firewall configured in the
      subscription
7. No backups
    - Hetzner disk backups add 25% on price, but ideally we should be able to
      re-init and re-deploy, which reduces the need for backups somewhat
    - Regular backup should also be in-server configured
8. No placement groups
    - Not relevant for our needs
9. No cloud config
    - Cloud config is quite nice actually, but it is easier to track a proper
      shell script for fresh-init which does the same thing.
10. Name
    - software-underground-1

This is my public key:
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHRfPUZK61TxCbBYlyAdR4/X7ulBjYiBbTk+f8FzH77mZYEHzKAsuEPbKK+y3Z32zX5HcO5zoA0lHdJ+i5DeDsNxt9MXFaA4BYdnSNyP5RTVNFruvkYOJsRU0FFoBf1D4xu7y8H6RXbCSzk9jgUmdqbhyTLHJL3nC9D5iKB5gEvlI6JrKwQFfZPgs1rzUc/LYxT9i0jdcZbuhL6Docv2jqiYIZe0cNzJxlqO2uRDchmWwwr+buVm51wngLkgZRs3ciRx3YOMEN2Bji19otn9WR1DVwodwfkjjXu9MqrYlV9Vj+3GJW++smWPMtm1q7u6ymU8r2aPwHaJNa9rre7kE7QK2Ma5TAXmBd47+g0jnnKRLovIkFa3LDMj4wHzfHcxnclP7ka4v+L6Vx42wvvZHgpzJM0cXM0AO0gfRvImYM/r9++bBtRK4kQHx8cl3tB+tzoxbVEMTLExN3dQFd6UfJQ910A0PiA+RA2tGZP9yCclyBEJT0hj0CfIgZ3k8+qgX8gq+vToTyuJQUOvZphNLsiglcSPwlBAsnUZRnsV3AsubXo5VdUwHdibQO9/xBeswAWxzydubQ2lxYEyhDfCHJ6jPkBASm7qCL6wtd25AezwJfp8SyyaeMBMtsQuKZDyi1S+6iVzQ4oDyRFdEIJfB6vozH0Qjdk+TZ41DnIQHAyw== j@lambda.is

# https and letsencrypt certificate
**DO NOT TAKE THIS SECTION LIGHTLY**. If you are unsure what you are doing, stop
and ask another maintainer for help. Do not keep the unencrypted certificates
around for a long time. When extracting it to its install location, it is
important that permissions and ownership is set properly.

We need a certificate for the mattermost subdomain. We get one with certbot,
which requires http/80 to be open, but is a one-time job (as the certificate
should be used across deployments). It is therefore not a part of the
automation, but the process is rendered here:

```bash
$ sudo ufw allow 80
$ sudo certbot --nginx
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/mattermost.softwareunderground.org/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/mattermost.softwareunderground.org/privkey.pem
This certificate expires on 2023-12-25.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

$ sudo tar czf letsencrypt.tar.gz --owner 0 --group 0 -C /etc letsencrypt
```

I used my own email for emergency information and expiration alarms.

The certificate is then encrypted with my publig gpg key and checked into the
tree. An encrypted copy should be checked in for every maintainer using their
public gpg keys, which means another maintainer needs to encrypt the archive
for some other maintainer. Setting up gpg is out of scope for this document.

To encrypt/decrypt:
```bash
$ gpg --encrypt --output cert/j-letsencrypt.tar.gz.gpg --recipient j@lambda.is letsencrypt.tar.gz
$ gpg --decrypt -o letsencrypt.tar.gz j-letsencrypt.tar.gz
```

The naming `<user>-tarball.tar.gz.gpg` is conventional, but helps scripting.

# Initialize the server
run `init.sh mattermost.softwareunderground.org` (assuming DNS is set up), or
just use the raw IP for the box. It must exist and have your ssh key in its
authorized keys for root. This can be fixed in the hetzner (or provider)
console.

Some error checking is performed; should there be problems the only real
recourse is to read the init.sh, which is written as a mostly straight forward
shell script.

# Configurations

After initializing the server, we needed to configure it to allow users to
create their account without the need for an invitation. This can be done in
the System Console (you need to login to Mattermost as an admin user) and in
the `Signup` menu, set the `Enable Open Server:` option to true.

# SMTP setup
Hetzner is a cheap public cloud vendor, and as a consequence suffer terribly
under spammers and bots. As a result, as a policy they by default firewall
outgoing email ports (25, 465), which makes running a delivery agent a pain.
Running our own service is also terrible because we have to get through the
filters and whitelists of google et al.

Our email system is provided by hover.com, and we use them as a simple mail
delivery agent. The auth is encrypted and checked in, and mattermost reads
email authentication from its environment.

https://docs.hetzner.com/cloud/servers/faq#why-can-i-not-send-any-mails-from-my-server

# Health checks
TODO

# Backup
TODO
