FROM frekele/gradle:4-jdk8

# Install required packages
RUN apt-get update \
    && apt-get install -y git file locales \
    && rm -rf /var/lib/apt/lists/*

# Make the "en_US.UTF-8" locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
