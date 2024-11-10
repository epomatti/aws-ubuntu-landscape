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

> [!NOTE]
> 

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

```sh
certbot --apache --non-interactive --no-redirect --agree-tos --email $CERTBOT_EMAIL --domains $(hostname --long)
```

Your server should be ready for use at `https://landscape.example.com`.

## Ubuntu Desktop

This project uses a locally deployed bear metal remote Ubuntu 24.04 Desktop. Create a [Ubuntu image][5]. The recommended burning tool is [Balena][6].

```

```



check the hash





https://ubuntu.com/landscape/docs/self-hosted-landscape


Enable script execution (administrators)


```sh
sudo -u landscape bash -x /opt/canonical/landscape/scripts/update_security_db.sh
```

```sh
/etc/landscape/client.conf
```

```sh
sudo service landscape-client restart
```



[1]: https://ubuntu.com/pro/dashboard
[2]: https://ubuntu.com/landscape/docs/quickstart-deployment
[3]: https://ubuntu.com/landscape/docs/self-hosted-landscape
[4]: https://ubuntu.com/landscape/install
[5]: https://ubuntu.com/tutorials/create-a-usb-stick-on-windows
[6]: https://etcher.balena.io/