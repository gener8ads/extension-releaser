FROM ubuntu:trusty

ARG CERT
ARG EXTENSION_UPDATE_URL
ARG GCS_SERVICE_ACCOUNT
ARG TARGET_GCS_URL

## ----------- Chrome -----------
RUN apt-get update; apt-get clean

# Add a user for running applications.
RUN useradd apps
RUN mkdir -p /home/apps && chown apps:apps /home/apps

# Install wget.
RUN apt-get install -y wget jq unzip wmctrl fluxbox xvfb apt-transport-https ca-certificates gnupg

# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable
## ----------- Chrome -----------

## ----------- GSUtil -----------
RUN wget https://storage.googleapis.com/pub/gsutil.zip && \
    unzip gsutil.zip
## ----------- GSUtil -----------
COPY gsutil/ /gsutil

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN echo ${CERT} > /cert.pem
RUN echo ${GCS_SERVICE_ACCOUNT} > /service_account.json
RUN export GOOGLE_APPLICATION_CREDENTIALS=/service_account.json

ENTRYPOINT ["/entrypoint.sh"]