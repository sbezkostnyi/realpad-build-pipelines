FROM gradle:6.3.0-jdk11

# Install required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends file s-nail \
    && rm -rf /var/lib/apt/lists/*

# Add script to send static code analyzers reports
ADD send_reports.sh /send_reports.sh
RUN chmod +x /send_reports.sh
