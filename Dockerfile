FROM gradle:8.5-jdk17

ENV NODE_HOME /opt/node
ENV NODE_VERSION 20.11.0
ARG NODE_DOWNLOAD_SHA256=9556262f6cd4c020af027782afba31ca6d1a37e45ac0b56cecd2d5a4daf720e0  

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
