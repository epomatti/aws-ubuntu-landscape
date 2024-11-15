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

## Ubuntu hardening

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
