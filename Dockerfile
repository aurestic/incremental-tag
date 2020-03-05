FROM alpine/git:1.0.7

LABEL "com.github.actions.name"="Create an incremental release"
LABEL "com.github.actions.description"="Automatically generate & update a incremental release for your releases"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/aurestic/incremental-create-relase"
LABEL "homepage"="https://github.com/aurestic/incremental-create-relase"
LABEL "maintainer"="Jose Zambudio <zamberjo@gmail.com>"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
