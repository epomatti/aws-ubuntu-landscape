# Ubuntu Landscape

## Create the AWS resources

Create the `.auto.tfvars` variables file:

```sh
cp config/template.tfvars .auto.tfvars
```

Set the required variables:

- `landscape_server_fqdn` - This will be the internet FQDN for the Landscape server. It is best to use a real domain for this.
- `landscape_certbot_email` - Required while setting `certbot` certificates.

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

## Setup the Ubuntu Landscape server

This project currently uses the `quickstart` mode for installation. The following are references for such configuration:

- [Ubuntu Pro Dashboard][1]
- [Landscape quickstart deployment][2]
- [Landscape self-hosted documentation][3]
- [Landscape self-hosted setup][4]

Elevate your privileges in the server session:

```sh
sudo su -
```

Make sure cloud init executed properly

```sh
cloud-init status
```

> [!IMPORTANT]
>  Make sure you don't skip the next step. Change the "example.com" to your owned domain of choice.

Setup your domain registry for the `landscape.example.com` to the public IP or AWS EC2 instance name.

> [!NOTE]
> The project is created with an Elastic IP, therefore the public IP address will not change.

Make sure that the DNS has replicated successfully before continuing:

```sh
dig landscape.example.com
```

Attach the server to your Ubuntu Pro subscription. You're currently allowed 5 machines in the Personal free subscription.

```sh
pro attach
```

Set the session variables:

```sh
export FQDN=$(aws ssm get-parameter --name "landscape-server-fqdn" --query "Parameter.Value" --output text)
export CERTBOT_EMAIL=$(aws ssm get-parameter --name "landscape-server-certbot-email" --query "Parameter.Value" --output text)
```

Set your hostname using variables:

```sh
hostnamectl set-hostname "$FQDN"
```

Install Landscape:

```sh
apt update && DEBIAN_FRONTEND=noninteractive apt-get install -y landscape-server-quickstart
```

Install your certificate:

> [!IMPORTANT]
> Make sure the certificate is correctly issued and installed

```sh
certbot --non-interactive --apache --no-redirect --agree-tos --email $CERTBOT_EMAIL --domains $FQDN
```

Your server should be ready for use at `https://landscape.example.com`.

Access the server and create your administrator account.

In case this come in handy, these are the commands to manage the Landscape Server CTL:

```sh
lsctl status
lsctl restart
```

## Ubuntu Pro Server

> [!NOTE]
> As of this writing, USG is not yet available for [24.04](https://ubuntu.com/security/certifications/docs/usg/cis).

If you want to enable Ubuntu Pro for the created instance, just flip the variable switch:

```terraform
create_ubuntu_pro_server = true
```

Check the pro licensing status:

> [!NOTE]
> USG and the Landscape client should already be installed. USG should already be enabled.

> [!WARNING]
> Livepatch is currently [not supported](https://ubuntu.com/security/livepatch/docs/livepatch/explanation/which-are-the-supported-architectures) for ARM64 systems

```sh
sudo pro status --all
```

Link the instance to Landscape SaaS and then approve the registration:

```sh
# sudo is required to read /etc/landscape/client.conf
sudo landscape-config --computer-title "aws-ubuntu-pro-server" \
  --account-name "<ACCOUNT>" \
  --http-proxy="" \
  --https-proxy="" \
  --script-users="root,landscape,nobody" \
  --tags="server,aws"
```

Enable script execution:

```sh
sudo landscape-config --include-manager-plugins=ScriptExecution --script-users=root,landscape,nobody
```

Restart the service:

```sh
sudo service landscape-client restart
```

Apply a profile:

```sh
sudo usg fix cis_level1_server
```

## Ubuntu Desktop

This project uses a locally deployed bear metal remote Ubuntu 22.04 Desktop. Create a [Ubuntu image][5]. The recommended burning tool is [Balena][6].

> [!NOTE]
> Using Ubuntu 22.04 as of the time of this project Ubuntu Pro des not support 24.04 USG, which is part of this scope of experimentation.

Make sure all packages are updated:

```sh
sudo apt update
sudo apt upgrade -y
```

Set up XRDP to manage your machine remotely. This project follows this Digital Ocean's article.

```sh
sudo apt install xfce4 xfce4-goodies -y
sudo apt install xrdp -y
sudo systemctl status xrdp
```

Once logged into your Ubuntu Desktop workstation, attach the machine for Ubuntu landscape management.

The `ubuntu-pro-client` should already be installed. Just make sure it is updated:

```sh
# This will update the client ot the latest version 
sudo apt install -y ubuntu-pro-client
```

> [!NOTE]
> You should be using a Let's Encrypt certificated issued earlier in this documentation. In for some reason you're opting for a self-signed approach, check how to [set it up in the client][8].

Attach the Ubuntu Desktop machine to a license:

```sh
sudo pro attach
```

Now, from your Ubuntu Landscape Server, follow the instructions on how to register a computer vi the menu. The path should be something like this:

```
https://landscape.example.com/account/standalone/how-to-register
```

These are examples of commands to be executed in the Ubuntu Desktop client machine:

```sh
sudo apt-get update
sudo apt-get install -y landscape-client
# Replace the domain
sudo landscape-config --computer-title "MyUbuntuDesktop" --account-name standalone  --url https://landscape.example.com/message-system --ping-url http://landscape.example.com/ping
```

> [!NOTE]
> Make sure to check Ubuntu Pro status in Landscape to confirm it has been properly registered.


### Enable script execution (administrator)

In case script execution needs to be enabled.

```sh
sudo -u landscape bash -x /opt/canonical/landscape/scripts/update_security_db.sh
```

Configuration file:

```sh
/etc/landscape/client.conf
```

Restarting the client:

```sh
sudo service landscape-client restart
```

## Ubuntu Hardening

Ubuntu Pro supports [Ubuntu Security Guide (USG)][9]. For quick guide, the [tutorial][14] can be o good starting point.

Following the [installation guide][10]:

> [!NOTE]
> This is already covered by the previous steps already executed

1. Install the UA client
2. Attach the subscription

Enable and install USG:

```sh
sudo ua enable usg
sudo apt install usg
```

This project uses CIS benchmarks, for which there are different [profiles][11]:

> [!TIP]
> Check the [CIS Benchmark publications][12] for in-depth details about each profile

- Level 1: Balanced
- Level 2: Restrictive

To apply the benchmark, select one of the profiles:

```sh
# Profiles: cis_level1_workstation, cis_level2_workstation
sudo usg fix <PROFILE>
```

A system `reboot` is required after this point.

Then, run the audit command:

> [!TIP]
> Once the audit below is completed, access the HTML page for analysis

```sh
# Profiles: cis_level1_workstation, cis_level2_workstation
sudo usg audit <PROFILE>
```

To access the file from another user:

```sh
cp usg-report-xxx.html /home/user/Desktop/
chown <user>: /home/<user>/Desktop/usg-report-20241110.1302.html
```

To apply for a set of systems:

```sh
sudo usg generate-fix <PROFILE> --output fix.sh
```

If required, explore the [customization][13] options.

Other references include the [Ubuntu engagement][15] page, and the [CIS Benchmark Ubuntu][16] page.

## VirtualBox

Simplest way might be to use VirtualBox with Vagrant:

> [!NOTE]
> USG currently not supported for 24.04

```sh
mkdir -p vagrant/ubuntu-jammy
cd vagrant/ubuntu-jammy

vagrant init ubuntu/jammy64
vagrant up
vagrant ssh
```

To increase the VM performance, set custom values:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "2048"
  vb.cpus = "2"
end
```

Setup Ubuntu Pro:

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y ubuntu-advantage-tools
```

Attach to a subscription:

```sh
sudo pro attach
```

Enable and install USG, the Landscape Client:

```sh
sudo pro enable usg
sudo apt install -y usg landscape-client
```

Set up the configuration file `/etc/landscape/client.conf`:

> [!TIP]
> The [documentation](https://ubuntu.com/landscape/docs/configure-landscape-client) have guidelines for CM tools such as Puppet or Ansible.

```
[client]
log_level = info 
url = https://{FQDN}/message-system
ping_url = http://{FQDN}/ping
data_path = /var/lib/landscape/client
registration_key = {REGISTRATION_KEY}
computer_title = {COMPUTER_TITLE}
account_name = {ACCOUNT_NAME}
include_manager_plugins = ScriptExecution
script_users = root,landscape,nobody
```

With the file set, register the machine:

```sh
sudo landscape-config
```

> [!WARNING]
> If you run into a "twisted.internet" error it might be due to [this bug](https://bugs.launchpad.net/landscape-client/+bug/1868730). Check the ownership of the `/var/lib/landscape/client` structure, it should have `landscape` ownership. If necessary, fix it by running `sudo chown -R landscape:landscape /var/lib/landscape/client`.

Apply a USG a profile:

```sh
sudo usg fix cis_level1_server
```

## Tuning

The client can read several variables to adjust the behavior.

An example is provided in the [repository](https://github.com/canonical/landscape-client/blob/main/example.conf), and this is a sample [question](https://answers.launchpad.net/landscape-client/+question/403745).

Configuration can be changed in the `client.conf` file:

```
/etc/landscape/client.conf
```

For local debugging this might might be useful:

```conf
# The number of seconds between server exchanges
exchange_interval = 900 # 15 minutes

# The number of seconds between urgent exchanges with the server.
urgent_exchange_interval = 60 # 1 minute

# The number of seconds between pings.
ping_interval = 30

# The number of seconds between apt update calls.
apt_update_interval = 21600

# The number of seconds between package monitor runs.
package_monitor_interval = 1800

# The number of seconds between snap monitor runs.
snap_monitor_interval = 1800
```

## Troubleshooting

Make sure to run scripts with the right user `landscape`, or if `root` is used, apply the correct permissions.

```sh
sudo cat /etc/sudoers
groups landscape
```

An example with the docker list:

```sh
stat /etc/apt/sources.list.d/docker.list
chmod -v o+r /etc/apt/sources.list.d/docker.list
```

## Monitoring

Here's a New Relic example setup with log [forwarding](https://docs.newrelic.com/docs/logs/forward-logs/forward-your-logs-using-infrastructure-agent/#manual):

Configuration is declared in the `logging.yml` file:

```
/etc/newrelic-infra/logging.d/logging.yml
```

Forward all the Landscape client logs:

```yaml
logs:
  - name: landscape-client-logs
    file: /var/log/landscape/*.log
    attributes:
      logtype: landscape-client
      environment: sandbox
```

Quick commands to manage the agents:

```sh
sudo systemctl <start|stop|restart|status> newrelic-infra
sudo service landscape-client restart
```

## Mirrors / Repositories

This section will cover mirror configuration. Check out the [repository mirroring](https://ubuntu.com/landscape/docs/explanation-about-repository-mirroring) and [mirror management](https://ubuntu.com/landscape/docs/manage-repositories-web-portal) articles.

### EBS Modifications

> [!CAUTION]
> Watch out for EBS modifications rate limit

Be mindful that there might be a 6 hour rate-limit for EBS.

If you reach the limit, then try this [resolution](https://repost.aws/knowledge-center/ebs-resolve-modify-volume-issues) procedure that involves attaching the instance to a new volume from a snapshot.

### CloudWatch

The CloudWatch Agent has been configured and installed by Terraform. Check its status, and [troubleshoot it](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/troubleshooting-CloudWatch-Agent.html) if necessary:

```sh
sudo systemctl status amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```

### Mirror GPG Key Generation

> [!NOTE]
> You have to give a real name and email so that he key is generated, otherwise it won't. Check [this video](https://youtu.be/yduAcCqi2z0?list=PLnrmLjoInKWgQdNpMxuMC7rrdoDUgz6YZ) for reference.

> [!IMPORTANT]
> Landscape mirror keys must not have passwords

```sh
# Install and run rngd to improve the efficiency of generating the GPG key
sudo apt-get install rng-tools && sudo rngd -r /dev/urandom

# Either 2 years, or never expire
gpg --gen-key 
gpg --full-gen-key

# List the public or secret keys
gpg -K
gpg --list-keys
gpg --list-secret-keys

# Export it
gpg -a --export-secret-keys {SECRET_KEY_ID} > mirror-key.asc
```

Just in case deleting a key is required:

```sh
gpg --delete-secret-key {SECRET_KEY_ID}
gpg --delete-key {SECRET_KEY_ID}
```

### RabbitMQ Timeout

> [!TIP]
> Consider changing the [timeout](https://ubuntu.com/landscape/docs/configure-rabbitmq-for-landscape) for RabbitMQ

```sh
sudo touch /etc/rabbitmq/rabbitmq
# Add this (5 hours): consumer_timeout = 18000000
sudo vim /etc/rabbitmq/rabbitmq
sudo rabbitmq-diagnostics environment | grep consumer_timeout
```

### Create and Sync the Mirror

#### Volume Space

Packages are going to be downloaded to `/var/lib/landscape/landscape-repository/standalone/` by default.

Follow up the size with `du`:

```sh
du -h --max-depth=1 | sort -hr
```

#### Pockets

Purpose for package management:

- `release` - Official release
- `security` - Critical security updates
- `updates` - Bug fixes and stability improvements. Tested and approved before being released.

The pockets `proposed` and `backports` do not receive as much testing as `updates`.

This is a common recommendation:

```
deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse
```

#### Components

Components breakdown:

- `main` - Officially supported free software.
- `restricted` - Proprietary drivers and firmware supported by Ubuntu.
- `universe` - Community-maintained open-source packages.
- `multiverse` - Non-free software that Ubuntu does not officially support.

#### PostgreSQL Mirror

On Landscape, add the distribution and the mirror. Example for PostgreSQL:

| Configuration | Value                                    |
|---------------|------------------------------------------|
| Name          | postgres                                 |
| URI           | https://apt.postgresql.org/pub/repos/apt |
| Series name   | `jammy-pgs`                              |
| Pockets       | `release`                                |
| Components    | `main`                                   |
| Architectures | `amd64`                                  |

Now sync the mirror.

Create a repository profile and save to the clients:

```sh
sudo ls -l /etc/apt/sources.list.d/
```

## Profiles

This [YouTube video](https://youtu.be/LreS6DhboYM) gives a run through the Profiles feature.

Demonstrate the usage of the [Profiles](https://ubuntu.com/landscape/docs/explanation-package-profile) feature:

- Repository
- Packages
- [Upgrade](https://ubuntu.com/landscape/docs/managing-computers#heading--manage-upgrade-profiles)
- Removal

## API

Direct interaction with the API is possible via [API Endpoints](https://ubuntu.com/landscape/docs/make-rest-api-requests), such as with the [Packages API](https://ubuntu.com/landscape/docs/api-rest-packages).


## Miscellaneous

General configurations of various types: https://ubuntu.com/landscape/docs/other-classic-web-portal-tasks

[1]: https://ubuntu.com/pro/dashboard
[2]: https://ubuntu.com/landscape/docs/quickstart-deployment
[3]: https://ubuntu.com/landscape/docs/self-hosted-landscape
[4]: https://ubuntu.com/landscape/install
[5]: https://ubuntu.com/tutorials/create-a-usb-stick-on-windows
[6]: https://etcher.balena.io/
[7]: https://www.digitalocean.com/community/tutorials/how-to-enable-remote-desktop-protocol-using-xrdp-on-ubuntu-22-04
[8]: https://askubuntu.com/a/906249
[9]: https://ubuntu.com/security/certifications/docs/usg
[10]: https://ubuntu.com/security/certifications/docs/disa-stig/installation
[11]: https://ubuntu.com/security/certifications/docs/2204/usg/cis/compliance
[12]: https://downloads.cisecurity.org/#/
[13]: https://ubuntu.com/security/certifications/docs/2204/usg/cis/customization
[14]: https://ubuntu.com/tutorials/comply-with-cis-or-disa-stig-on-ubuntu#1-overview
[15]: https://ubuntu.com/engage/a-guide-to-infrastructure-hardening
[16]: https://www.cisecurity.org/benchmark/ubuntu_linux
