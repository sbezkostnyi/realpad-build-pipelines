#!/bin/bash

# Script sends email with static code analyzers reports from Gradle build
# It's designed to be executed as part of Bitbucket Pipelines build

# Requires to configure next environment variables in your repository:
# SMTP_SERVER=host:port
# SMTP_AUTH_USER=username
# SMTP_AUTH_PASSWORD=password
# SMTP_SENDER=from@domain.com
# SMTP_RECIPIENTS=recipient@domain.com

TEMP_DIR="/tmp/reports"

# Exit on error
set -e

# Cleanup temporary directory
if [[ -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
fi
mkdir "${TEMP_DIR}"

REPORTS_DIR="${BITBUCKET_CLONE_DIR}/build/reports/"
ATTACHMENTS=()

# Copy reports to temporary directory
for DIR in ${REPORTS_DIR}*/; do
  DIR_NAME=$(basename "${DIR}")
  for FILE in ${DIR}*; do
    FILE_NAME=$(basename "${FILE}")
    REPORT_FILE="${TEMP_DIR}/report.${DIR_NAME}.${FILE_NAME}"
    cp "${FILE}" "${REPORT_FILE}"
    ATTACHMENTS+=("--attach-type $(file --brief --mime-type ${REPORT_FILE}) --attach ${REPORT_FILE}")
  done
done

CODE_ANALYZED_REGEXP="s/\<p\>Code analyzed\:\<\/p\>\n.*\<ul\>\n(.*\<li\>.*\<\/li\>\n)+.*\<\/ul\>\n.*(?=\<p\>)//g"

perl -i -p0e "${CODE_ANALYZED_REGEXP}" "${TEMP_DIR}/report.spotbugs.main.html"
perl -i -p0e "${CODE_ANALYZED_REGEXP}" "${TEMP_DIR}/report.spotbugs.test.html"

# Build email body
echo "Static code analyzers reports from the Pipelines build #${BITBUCKET_BUILD_NUMBER}" > "${TEMP_DIR}/body.txt"
echo "" >> "${TEMP_DIR}/body.txt"
echo "Build details: https://bitbucket.org/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}/addon/pipelines/home#!/results/${BITBUCKET_BUILD_NUMBER} " >> "${TEMP_DIR}/body.txt"
echo "Commit details: https://bitbucket.org/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}/commits/${BITBUCKET_COMMIT} " >> "${TEMP_DIR}/body.txt"

# Send email with reports
swaks -tls \
  --server "${SMTP_SERVER}" \
  --auth LOGIN \
  --auth-user "${SMTP_AUTH_USER}" \
  --auth-password "${SMTP_AUTH_PASSWORD}" \
  --from "${SMTP_SENDER}" \
  --to "${SMTP_RECIPIENTS}" \
  --header "Subject: Static code analyzers reports from the Pipelines build #${BITBUCKET_BUILD_NUMBER}" \
  --attach-body "${TEMP_DIR}/body.txt" \
  ${ATTACHMENTS[@]}
