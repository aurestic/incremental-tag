FROM alpine/git:1.0.7

LABEL "com.github.actions.name"="Create an incremental tag"
LABEL "com.github.actions.description"="Create an incremental tag under your conditions"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/aurestic/incremental-tag"
LABEL "homepage"="https://github.com/aurestic/incremental-tag"
LABEL "maintainer"="Jose Zambudio <zamberjo@gmail.com>"

RUN apk add coreutils

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
