#!/bin/sh

set -x
set -e

case $1 in
  "success" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="has Passed"
    ARTIFACT_URL="$CI_JOB_URL/artifacts/download"
    ;;

  "failure" )
    EMBED_COLOR=15158332
    STATUS_MESSAGE="has Failed"
    ARTIFACT_URL="Not available"
    ;;

  * )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="has Passed"
    ARTIFACT_URL="$CI_JOB_URL/artifacts/download"
    ;;
esac

shift

if [ $# -lt 1 ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DiscordHooks/gitlab-ci-discord-webhook" && exit
fi

AUTHOR_NAME="$(git log -1 "$CI_COMMIT_SHA" --pretty="%aN")"
COMMITTER_NAME="$(git log -1 "$CI_COMMIT_SHA" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "$CI_COMMIT_SHA" --pretty="%s")"
COMMIT_MESSAGE="$(git log -1 "$CI_COMMIT_SHA" --pretty="%b")" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g'

if [ "$AUTHOR_NAME" == "$COMMITTER_NAME" ]; then
  CREDITS="$AUTHOR_NAME authored & committed"
else
  CREDITS="$AUTHOR_NAME authored & $COMMITTER_NAME committed"
fi

if [ -z $CI_MERGE_REQUEST_ID ]; then
  URL=""
else
  URL="$CI_PROJECT_URL/merge_requests/$CI_MERGE_REQUEST_ID"
fi

TIMESTAMP=$(date --utc +%FT%TZ)


if [ -z $LINK_ARTIFACT ] || [ $LINK_ARTIFACT = false ] ; then
  WEBHOOK_DATA='{
    "attachments": [
        {
            "fallback": "Required plain-text summary of the attachment.",
            "color": "#36a64f",
            "pretext": "",
					  "author_name": "'$GITLAB_USER_NAME'('$GITLAB_USER_LOGIN')",
            "author_link": "https://'$CI_SERVER_HOST'/'$GITLAB_USER_LOGIN'",
            "author_icon": "https://'$CI_SERVER_HOST'/uploads/-/system/user/avatar/'$GITLAB_USER_ID'/avatar.png",
            "title": "'$CI_JOB_NAME' #'$CI_PIPELINE_ID' '$STATUS_MESSAGE'",
            "title_link": "'$CI_JOB_URL'",
            "text": "",
            "fields": [
			        {
                "title": "Branch",
                "value": "<'$CI_PROJECT_URL'/tree/'$CI_COMMIT_REF_NAME'|'$CI_COMMIT_REF_NAME'>",
                "short": true
             },
             {
              "title": "Commit",
              "value": "<'$CI_PROJECT_URL'/commit/'$CI_COMMIT_SHA'|'$CI_COMMIT_SHORT_SHA'>",
              "short": true
            }
            ],
            "image_url": "http://my-website.com/path/to/image.jpg",
            "thumb_url": "http://example.com/path/to/thumb.png",
            "footer": "'$CI_PROJECT_NAME'",
            "footer_icon": "",
            "ts": "'$TIMESTAMP'"
        }
    ]
}'
else
	WEBHOOK_DATA='{
    "attachments": [
        {
            "fallback": "Required plain-text summary of the attachment.",
            "color": "#36a64f",
            "pretext": "",
					  "author_name": "'$GITLAB_USER_NAME'('$GITLAB_USER_LOGIN')",
            "author_link": "https://'$CI_SERVER_HOST'/'$GITLAB_USER_LOGIN'",
            "author_icon": "https://'$CI_SERVER_HOST'/uploads/-/system/user/avatar/'$GITLAB_USER_ID'/avatar.png",
            "title": "'$CI_JOB_NAME' #'$CI_PIPELINE_ID' '$STATUS_MESSAGE'",
            "title_link": "'$CI_JOB_URL'",
            "text": "",
            "fields": [
			        {
                "title": "Branch",
                "value": "<'$CI_PROJECT_URL'/tree/'$CI_COMMIT_REF_NAME'|'$CI_COMMIT_REF_NAME'>",
                "short": true
             },
             {
              "title": "Commit",
              "value": "<'$CI_PROJECT_URL'/commit/'$CI_COMMIT_SHA'|'$CI_COMMIT_SHORT_SHA'>",
              "short": true
            },
            {
				    "title": "Artifacts",
				    "value": "<'$ARTIFACT_URL'|'$CI_JOB_ID'>",
				    "short": true
			      }
            ],
            "image_url": "http://my-website.com/path/to/image.jpg",
            "thumb_url": "http://example.com/path/to/thumb.png",
            "footer": "'$CI_PROJECT_NAME'",
            "footer_icon": "",
            "ts": "'$TIMESTAMP'"
        }
    ]
}'
fi

for ARG in "$@"; do
  echo -e "[Webhook]: Sending webhook to Slack...\\n";

  (curl --fail --progress-bar -A "GitLabCI-Webhook" -H Content-Type:application/json -H X-Author:eliertoncosta#5944 -d "$WEBHOOK_DATA" "$ARG" \
  && echo -e "\\n[Webhook]: Successfully sent to slack.") || echo -e "\\n[Webhook]: Unable to send to slack."
done