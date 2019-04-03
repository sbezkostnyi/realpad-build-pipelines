FROM frekele/java:jdk8

ENV GRADLE_VERSION=5.3.1
ENV GRADLE_HOME=/opt/gradle
ENV GRADLE_FOLDER=/root/.gradle

# Change to tmp folder
WORKDIR /tmp

# Download and extract gradle to opt folder
RUN wget --no-check-certificate --no-cookies https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt \
    && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
    && rm -f gradle-${GRADLE_VERSION}-bin.zip

# Add executables to path
RUN update-alternatives --install "/usr/bin/gradle" "gradle" "/opt/gradle/bin/gradle" 1 && \
    update-alternatives --set "gradle" "/opt/gradle/bin/gradle" 

# Create .gradle folder
RUN mkdir -p $GRADLE_FOLDER

# Mark as volume
VOLUME $GRADLE_FOLDER

# Change to root folder
WORKDIR /root

# Install required packages
RUN apt-get update \
    && apt-get install -y git file locales heirloom-mailx \
    && rm -rf /var/lib/apt/lists/*

# Add script to send static code analyzers reports
ADD send_reports.sh /send_reports.sh
RUN chmod +x /send_reports.sh

# Make the "en_US.UTF-8" locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
