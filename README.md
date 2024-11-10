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

Set the session variables:

```sh
export FQDN=$(aws ssm get-parameter --name "landscape-server-instance-id" --query "Parameter.Value" --output text)
export CERTBOT_EMAIL=$(aws ssm get-parameter --name "landscape-server-instance-id" --query "Parameter.Value" --output text)
```

```sh
pro attach
```


## Landscape Server


```sh
# hostnamectl set-hostname "$FQDN"
# apt update && apt-get install -y landscape-server-quickstart


# EMAIL="YOUR-EMAIL@ADDRESS.COM"
# sudo certbot --apache --non-interactive --no-redirect --agree-tos --email $CERTBOT_EMAIL --domains $(hostname --long)
```

## Ubuntu Desktop

https://etcher.balena.io/
https://ubuntu.com/tutorials/create-a-usb-stick-on-windows

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
