#!/usr/bin/env bash

set -eu

function help {
    echo "usage: init.sh [--user user] mattermost.softwareunderground.org"
    echo "Please read the README for more details"
}

# Default user to whoami, so that the letsencrypt are decrypted by default with
# the user that is running the script. If the crypt/name-* does not match the
# current user you can override it with --user.
suser=$(whoami)
argv=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            help
            exit 0
            ;;
        --user)
            suser="$2"
            shift
            ;;
        *)
            argv+=("$1")
            ;;
    esac
    shift
done

host="${argv[0]}"

users=(j)

debpkgs=(
    sudo
    fail2ban
    ufw
    stow
    rsync
    postgresql
    postgresql-common
    nginx
    certbot
    python3-certbot-nginx
)

set -x

ssh root@${host} "bash - " << EOF
    set -x
    apt-get update
    apt upgrade -y
    apt-get install -y ${debpkgs[@]}

    for user in ${users[@]}; do
        if ! id \$user 2>/dev/null; then
            # create the user with disabled password (no prompt),
            # delete it to make it empty, then expire so users must set it on first
            # login.
            #
            # This is to make sudo require the extra password check which is a nice
            # extra mechanism to prevent accidental changes.
            adduser --disabled-password --gecos "" \$user
            passwd -d \$user
            chage -d 0 \$user
        fi
    done

    for user in ${users[@]}; do
        adduser \$user sudo
    done

    useradd --system --create-home --user-group mattermost
    mkdir -p /stow
EOF

for user in ${users[@]}; do
    if [ -d home/$user ]; then
        rsync -av --chown=$user:$user home/$user root@${host}:/stow/home
    fi
done

ssh -q root@${host} "bash -" << EOF
cd /tmp
wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
yes | bash guix-install.sh
rm guix-install.sh
EOF

rsync -av etc lib root@${host}:/stow
rsync -av --chown=mattermost:mattermost --chmod=g+w opt/mattermost root@${host}:/stow/opt
gpg --decrypt secrets/${suser}-letsencrypt.tar.gz.gpg | ssh root@${host} "tar xzf - -C /stow/etc"
gpg --decrypt secrets/${suser}-mm.home.tar.gz.gpg | ssh root@${host} \
    "su - mattermost -c 'tar xzf - -C /home/mattermost'"

ssh -q root@${host} "bash -" << EOF
    if ! su - postgres --command \
        "psql postgres -tXAc \"SELECT 1 FROM pg_roles WHERE rolname='mmuser'\"" \
        | grep -q 1; then

        su - postgres --command \
            "psql -f -" << END
                CREATE USER mmuser WITH PASSWORD
                '$(gpg --decrypt secrets/mm.home.tar.gz.gpg | tar -O -xzf - .pgpass | cut -d : -f 5)';
END
    fi

    if ! su - postgres --command "psql -lq" | grep -qw mattermost; then
        su - postgres --command "psql --file -" << END
            CREATE DATABASE mattermost;
            GRANT ALL ON DATABASE mattermost TO mmuser;
            ALTER DATABASE mattermost OWNER TO mmuser;
            GRANT USAGE, CREATE ON SCHEMA PUBLIC TO mmuser;
END
    fi
EOF

ssh -q root@${host} "bash -" << EOF
    # disable all sites but mattermost
    rm /etc/nginx/sites-*/*

    mkdir -p /etc/letsencrypt
    # cli.ini is written by the bot package, but we bring our own
    rm -f /etc/letsencrypt/cli.ini

    set -xeuo pipefail
    for u in ${users[@]}; do chown -R \$u:\$u /stow/home/\$u; done
    for u in ${users[@]}; do stow -d /stow/home -t /home/\$u \$u; done
    stow -d /stow/etc -t /etc/ssh ssh
    stow -d /stow/etc -t /etc/fail2ban fail2ban
    stow -d /stow/etc -t /etc/nginx nginx
    stow -d /stow/etc -t /etc/letsencrypt letsencrypt
    stow -d /stow/lib -t /lib/systemd systemd
    stow -d /stow/opt -t /opt/mattermost mattermost

    systemctl enable fail2ban
    systemctl enable mattermost
    systemctl enable certbot.timer
    ufw allow OpenSSH
    # Need full and not just https for certbot to work
    ufw allow 'Nginx Full'
    ufw delete allow 'Nginx HTTP'
EOF

# ufw enable might interrupt the ssh connection, which in turn fails because of
# set -e.
ssh -q root@${host} "yes | ufw enable" || true;

set +x
echo "Machine set up - please reboot it for all changes to take effect"
echo "Run: ssh root@${host} \"reboot now\""
