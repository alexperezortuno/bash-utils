# Send mails with Bash

## Method 1

### Dependencies

You need to have `mailutils` installed on your system.

Debian/Ubuntu:
```bash
sudo apt install mailutils
```

CentOS/RHEL:
```bash
sudo yum install mailx
```

### Usage

```bash
echo "This is the body of the email" | mail -s "This is the subject" test@test.com
```

- `s` is the subject of the email.
- `echo` is the body of the email.

Attach a file to the email:
```bash
echo "This is the body of the email" | mail -s "This is the subject" -A /path/to/file test@test.com
```

## Method 2

### Dependencies

Debian/Ubuntu:
```bash
sudo apt install ssmtp
```

### Configuration
```bash
sudo nano /etc/ssmtp/ssmtp.conf
```

Add the following lines to the file:
```bash
root=mail@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=mail@gmail.com
AuthPass=yourpassword
UseSTARTTLS=YES
UseTLS=YES
```

### Usage

```bash
echo -e "To: test@mail.com\nSubject: Mail subject\n\nThis is the subject" | ssmtp test@mail.com
```

## Method 3

### Dependencies

Debian/Ubuntu:
```bash
sudo apt install sendmail
```

### Usage

```bash
cat <<EOL | sendmail -t
To: test@mail.com
Subject: Email subject

This is the subject
EOL
```

## Method 4

### Dependencies

Debian/Ubuntu:
```bash
sudo apt install msmtp
```

### Configuration

```bash
nano ~/.msmtprc
```

Add the following lines to the file:
```bash
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile ~/.msmtp.log

account default
host smtp.gmail.com
port 587
from correo@gmail.com
user correo@gmail.com
password tu_contraseña
auth on
tls on
tls_starttls on
```

change the permissions of the file:
```bash
chmod 600 ~/.msmtprc
```

### Usage

```bash
echo "This is the body of the email" | msmtp -a test@mail.com
```

## Method 5

Use a curl command to send an email.

```bash
curl -s --user 'api:YOUR_API_KEY' \
    https://api.mailgun.net/v3/YOUR_DOMAIN_NAME/messages \
    -F from='Tú <mail@domain.com>' \
    -F to=test@mail.com \
    -F subject='Subject mail' \
    -F text='This is the body of the email'
```

