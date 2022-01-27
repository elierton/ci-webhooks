{
    "attachments": [
        {
            "fallback": "Required plain-text summary of the attachment.",
            "color": "#36a64f",
            "pretext": "",
					  "author_name": "'$GITLAB_USER_NAME'('$GITLAB_USER_LOGIN')",
            "author_link": "$CI_SERVER_HOST/$GITLAB_USER_LOGIN",
            "author_icon": "https://gitlab.com/favicon.png",
            "title": "'$CI_JOB_NAME' #'$CI_PIPELINE_ID' '$STATUS_MESSAGE'",
            "title_link": "https://google.com.br",
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
}