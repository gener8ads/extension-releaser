FROM ubuntu:focal

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

## ----------- Chrome -----------
RUN apt-get update; apt-get clean

# Add a user for running applications.
RUN useradd apps
RUN mkdir -p /home/apps && chown apps:apps /home/apps

# Install wget.
RUN apt-get install -y wget jq unzip xvfb apt-transport-https ca-certificates gnupg curl

# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install Chrome.
RUN apt-get update -y
RUN apt-get -y install google-chrome-stable
RUN apt-get -y install google-cloud-sdk
## ----------- Chrome -----------

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN systemd-machine-id-setup && ln -sf /etc/machine-id /var/lib/dbus/machine-id

ENTRYPOINT ["/entrypoint.sh"]
      