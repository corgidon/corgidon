![Corgidon](https://i.imgur.com/NhZc40l.png)
========

[![Build Status](https://img.shields.io/circleci/project/github/msdos621/corgidon.svg)][circleci]

[circleci]: https://circleci.com/gh/msdos621/corgidon

Corgidon is a fork of [Mastodon](https://github.com/tootsuite/mastodon/blob/master/README.md).  It serves as the codebase for my instance [banana.dog](https://banana.dog).  It also serves as a testing ground for changes I am trying to get upstream into mastodon and/or [florencesoc](https://github.com/florence-social).

# Notable Difference from Mastodon

- Configurable Biography length
- Configurable Toot length
- Option to override the join url instead of directing people to joinmastodon.org
- Reports instance info using the nodeinfo spec just like pleroma and others
- Media takes the full width of the timeline in which it is contained
- Larger Emoji
- Default pink theme replaces default mastodon theme (see themes section)

# Themes

CorgiDon comes bundled with some themes from other instances as well as some unique themes.  Here they are

### Jigglypuff (default theme)

![jigglypuff](https://github.com/corgidon/corgidon/blob/main/.preview/jigglypuff.png?raw=true)

### Cybrespace

![cybrespace](https://github.com/corgidon/corgidon/blob/main/.preview/cybrespace.png?raw=true)

### Cybrespace Light

![cybrespace light](https://github.com/corgidon/corgidon/blob/main/.preview/cybrespacelight.png?raw=true)

### Cybrespace Windows 95

![cybrespace 95](https://github.com/corgidon/corgidon/blob/main/.preview/win95.png?raw=true)

### meemu.org

![meemu-org](https://github.com/corgidon/corgidon/blob/main/.preview/meemu.png?raw=true)

### GeoDude

![geodude](https://github.com/corgidon/corgidon/blob/main/.preview/geodude.png?raw=true)

### Sleeping Town

![sleeping town](https://github.com/corgidon/corgidon/blob/main/.preview/sleepingtown.png?raw=true)

### Royal Tennebaumbs

![royal tennebaumbs](https://github.com/corgidon/corgidon/blob/main/.preview/royal.png?raw=true)

### Witches Town

![witches town](https://github.com/corgidon/corgidon/blob/main/.preview/witches.png?raw=true)

# Things I tried and later removed

- Recaptcha option for login (removed since upstream mastodon introduced ability to review sign ups)
- Collopsable toots (replaced my implimentation with the "Read more>> feature from upstream")
- Option to show direct messages in your home timeline
- Public moderation log availible to logged in users (less useful now that about/more lists blocks)

# Docker Compose Install

A rough guide to how to setup an instance with docker-compose

## Prereqs

- A machine running some version of linux with docker and docker-compose installed
- A domain name (or a subdomain) for the Mastodon server, e.g. example.com
- An e-mail delivery service or other SMTP server to use for mail delivery
- Nginx
- SSL certs / lets-encrypt for your chosen domain

- create a directory for installation, make a note of the full path for later use

```
mkdir corgidon
cd corgidon
pwd corgidon
```

- pull down .env and update *DB_PASS* , *SMTP* settings, *LOCAL_DOMAIN* and any other things you want to change and save the file.

```
curl https://raw.githubusercontent.com/corgidon/corgidon/main/.env.production.sample  > .env.production
```

- pull down the example docker-compose file

```
curl https://raw.githubusercontent.com/corgidon/corgidon/main/docker-compose.yml  > docker-compose.yml
```

- pull the latest version of the docker containers

```
docker-compose pull
```

- generate SECRET_KEY_BASE and OTP_SECRET by running the following command twice.  Set them in the .env.production file

```
docker-compose run --rm web bundle exec rake secret
```

- generate VAPID_PRIVATE_KEY and VAPID_PUBLIC_KEY by running the following command twice.  Set them in the .env.production file

```
docker-compose run --rm web bundle exec rake mastodon:webpush:generate_vapid_key
```

- run db setup and migrate

```
docker-compose run --rm web rails db:setup
docker-compose run --rm web rails db:migrate
```

- rebuild assets

```
docker-compose run --rm web rails assets:precompile
```

- start the corgidon server

```
docker-compose up -d
```

- ensure the media upload directory has proper permission

```
chown -R 991:991 public
```

- setup nginx by pulling down the config file then editing it (replace example.com and /home/mastodon/ with your domain and your installation directory

```
cd /etc/nginx/sites-availible 
curl https://raw.githubusercontent.com/corgidon/corgidon/main/dist/nginx.conf  > /etc/nginx/sites-available/example.com
ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/example.com
nginx -t
service nginx reload
```

- Navigate to your instance and sign up for an account
- Give that new account admin privlidges

```
cd ~/corgidon
docker-compose run --rm web bin/tootctl accounts modify alice --role your_username
```
