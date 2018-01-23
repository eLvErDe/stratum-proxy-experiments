FROM acecile/dstm-cuda-zm:0.5.7

MAINTAINER Adam Cecile <acecile@le-vert.net>

# Install easy-rsa to create a PKI
RUN apt update \
    && apt -y --no-install-recommends install easy-rsa \
    && rm -rf /var/lib/apt/lists/*

# Create PKI
RUN make-cadir /root/local-pki \
    && cd /root/local-pki \
    && ln -s openssl-1.0.0.cnf openssl.cnf \
    && . ./vars \
    && ./clean-all \
    && ./pkitool --initca

# Trust PKI
RUN cp /root/local-pki/keys/ca.crt /usr/local/share/ca-certificates/local-pki.crt \
    && update-ca-certificates

# Create simple script to create server certificate
RUN echo '#!/bin/sh' > /root/create-server-cert \
    && echo 'cd /root/local-pki' >> /root/create-server-cert \
    && echo '. ./vars' >> /root/create-server-cert \
    && echo './pkitool --server $@' >> /root/create-server-cert \
    && chmod 0755 /root/create-server-cert

# Install smart-man-in-the-middle
RUN apt update \
    && apt -y --no-install-recommends install git python3 python3-setproctitle \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/eLvErDe/smart-man-in-the-middle.git /root/smart-man-in-the-middle/

# Install multi-process-launcher
RUN git clone https://github.com/eLvErDe/multi-process-launcher.git /root/multi-process-launcher/
