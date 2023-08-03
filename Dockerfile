FROM gradle:8.2.1-jdk17

ENV NODE_HOME /opt/node
ENV NODE_VERSION 18.17.0
ARG NODE_DOWNLOAD_SHA256=5c4a7fd9262c0c47bafab3442de6c3fed1602be3d243cb8cf11309a201955e75

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
    && apt-get install -y --no-install-recommends file \
    && rm -rf /var/lib/apt/lists/*
