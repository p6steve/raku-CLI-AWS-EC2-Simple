[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Simple AWS Session & Launch Control

## Getting Started [FIXME]

- apt-get update && apt-get install aws-cli
- aws configure _[enter your config here]_
- docker run -v /root/.aws:/root/.aws -it p6steve/rakudo:basic
- cd ~ && git clone https://github.com/p6steve/raku-WP.git
- cd raku-WP/various
- raku aws2.raku
- ssh -i "MyKeyPair.pem" ubuntu@ec2-13-41-185-87.eu-west-2.compute.amazonaws.com  <= use the public dns 

# Wordpress Deploy & Control

viz. [digital ocean howto](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose#step-3-defining-services-with-docker-compose)

- client script 'raku-wp --launch'
- read client yml config file
- read .env credentials
- launch AWS EC2 instance
- install / use perl AWS CLI tools

# TODOs

- [ ] new (launch based on yaml)
- [ ] nuke (terminate all instances)
- [ ] status (warn if > one running instance)
- [ ] stop     ( " )
- [ ] start    ( " )
- [ ] reboot   ( " )
- [ ] terminate( " )
- [ ] yaml (ie. return yaml with id, etc.)
- [ ] freeze / thaw

### Copyright
copyright(c) 2022 Henley Cloud Consulting Ltd.
