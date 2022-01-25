#!/bin/sh
set -x
set -e

FAILURE=1
SUCCESS=0

WEBHOOK_URL=${WEBHOOK_URL}

ENVIRONMENT=${CI_COMMIT_BRANCH}


function print_slack_summary_build() {
        local slack_msg_header
        local slack_msg_body
        local slack_channel

# Populate header and define slack channels
slack_msg_header=":x: *Build to ${ENVIRONMENT} failed*"
if [[ "${EXIT_STATUS}" == "${SUCCESS}" ]]; then
        slack_msg_header=":heavy_check_mark: *Build to ${ENVIRONMENT} succeeded*"
fi
cat <<-SLACK
            {
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "*Build to ${ENVIRONMENT} succeeded*"
                        }
                    },
                    {
                        "type": "divider"
                    },
                    {
                        "type": "section",
                        "fields": [
                            {
                                "type": "mrkdwn",
                                "text": "*Stage:*\nBuild"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Pushed By:*\n${GITLAB_USER_NAME}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Job URL:*\nGITLAB_REPO_URL/${CI_JOB_ID}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit URL:*\nGITLAB_REPO_URL$(git rev-parse HEAD)"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Branch:*\n${CI_COMMIT_REF_NAME}"
                            }
                        ]
                    },
                    {
                        "type": "divider"
                    }
                ]
}
SLACK
}

function send_update_build() {
        local slack_webhook
        slack_webhook="$WEBHOOK_URL"
        
   curl -X POST                                           \
       --data-urlencode "payload=$(print_slack_summary_build)"  \
        "${slack_webhook}"
}
