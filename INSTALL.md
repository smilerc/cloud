sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

// https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket
sudo chmod 666 /var/run/docker.sock

// run watchtower container

docker run --name cloud -d -e production='yes' -p4570:4570 smilerc67/cloud

docker run -d --restart=always \
    --name watchtower \
    -e WATCHTOWER_POLL_INTERVAL=60 \
    -e REPO_USER=smilerc67 \
    -e REPO_PASS='Ghbdtnbrb67&' \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower


docker run -d --restart=always \
    --name watchtower \
    -e WATCHTOWER_POLL_INTERVAL=60 \
    -e REPO_USER=smilerc67 \
    -e REPO_PASS='Ghbdtnbrb67&' \
    -v $HOME/.docker/config.json:/config.json \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower

heroku pg:backups:capture --app=cvtcenter HEROKU_POSTGRESQL_YELLOW
heroku pg:backups:download --app cvtcenter

