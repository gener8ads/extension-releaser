FROM debian:stable

# Set the Chrome repo.
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install Chrome, GCloud & Xvfb
RUN apt-get update -y
RUN apt-get -y install google-cloud-sdk xvfb chromium

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
      