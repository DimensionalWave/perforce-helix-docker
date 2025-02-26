# perforce-helix-docker

This repository contains a collection of source files for building Docker images for Perforce Helix. It exists purely because there is no working Docker solution in existence for Perforce Helix.

## perforce-helix

This directory contains the source files for building a Perforce Helix Core server Docker image. The published Docker images are available as [`dimensionalwave/perforce-helix` on GitHub Container Registry](https://hub.docker.com/r/dimensionalwave/perforce-helix).

### Build the image

You can build the Docker image using the command below, simply replace latest with the required tag

```
docker build -t ghcr.io/dimensionalwave/perforce-helix:latest --platform linux/amd64 .
```

### Usage

To have a disposable Perforce Helix Core server running, simply do:

```sh
docker run --rm \
    --publish 1666:1666 \
    ghcr.io/dimensionalwave/perforce-helix:2023.1
```

The above command makes the server available locally at `:1666`, with a default super user `admin` and its password `pass12349ers`.

All available options and their default values:

```sh
NAME=perforce-server
P4HOME=/p4
P4NAME=master
P4TCP=1666
P4PORT=1666
P4USER=admin
P4PASSWD=pass12349ers
P4CASE=-C0
P4CHARSET=utf8
JNL_PREFIX=perforce-server
```

Use the `--env` flag to override default:

```sh
docker run --rm \
    --publish 1666:1666 \
    --env P4USER=amy \
    --env P4PASSWD=securepassword \
    ghcr.io/dimensionalwave/perforce-helix:2023.1
```

> [!WARNING]
> Please be noted that although the server survives restarts (i.e. data is retained), it may break if you change some of the options after the initial bootstrap (i.e. the very first run of the image, when options are being hard-coded to the Perforce Helix Core server configuration).

To start a long-running production container, do remember to volume the data directory (`P4HOME`) and replace the `--rm` flag with `-d` (detach):

```sh
docker run -d \
    --publish 1666:1666 \
    --env P4PASSWD=securepassword \
    --volume ~/.helix-p4d-home:/p4 \
    ghcr.io/dimensionalwave/perforce-helix:2023.1
```

Now you have a running server, please read our handbook for [how to set up the client side](https://handbook.sourcegraph.com/departments/technical-success/support/process/p4-enablement/).

### Running Perforce Helix with SSL enabled

Frist, generate some self-signed SSL certificates:

```bash
mkdir ssl
pushd ssl
openssl genrsa -out privatekey.txt 2048
openssl req -new -key privatekey.txt -out certrequest.csr
openssl x509 -req -days 365 -in certrequest.csr -signkey privatekey.txt -out certificate.txt
rm certrequest.csr
popd
```

Next, we need to run the server with `P4SSLDIR` set to a directory containing the SSL files, and set `P4PORT` to use SSL:

```bash
docker run --rm \
    --publish 1666:1666 \
    --env P4PORT=ssl:1666 \
    --env P4SSLDIR=/ssl \
    --volume ./ssl:/ssl \
    ghcr.io/dimensionalwave/perforce-helix:latest
```

## Credits

Based on the amazing work from https://github.com/sourcegraph/helix-docker which is heavily inspired by https://github.com/p4paul/helix-docker and https://github.com/ambakshi/docker-perforce.
