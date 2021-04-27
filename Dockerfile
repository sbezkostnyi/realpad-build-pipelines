FROM gradle:7.0.0-jdk11

ENV NODE_HOME /opt/node
ENV NODE_VERSION 14.16.1
ARG NODE_DOWNLOAD_SHA256=068400cb9f53d195444b9260fd106f7be83af62bb187932656b68166a2f87f44

# Install Node.js
RUN set -o errexit -o nounset \
    && echo "Downloading Node.js" \
    && wget --no-verbose --output-document=node.tar.gz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" \
    \
    && echo "Checking download hash" \
    && echo "${NODE_DOWNLOAD_SHA256} *node.tar.gz" | sha256sum --check - \
    \
    && echo "Installing Node.js" \
    && tar -xvf node.tar.gz \
    && rm node.tar.gz \
    && mv "node-v${NODE_VERSION}-linux-x64" "${NODE_HOME}/" \
    && ln --symbolic "${NODE_HOME}/bin/node" /usr/bin/node \
    && ln --symbolic "${NODE_HOME}/bin/npm" /usr/bin/npm \
    \
    && echo "Testing Node.js installation" \
    && node --version \
    && npm --version

# Install required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends file swaks libnet-ssleay-perl \
    && rm -rf /var/lib/apt/lists/*

# Add script to send static code analyzers reports
ADD send_reports.sh /send_reports.sh
RUN chmod +x /send_reports.sh
