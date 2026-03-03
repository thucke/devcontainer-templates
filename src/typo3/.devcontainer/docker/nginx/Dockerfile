FROM nginx:1.29-alpine-slim

ARG DEVCONTAINER_SERVICE_ID
ARG DEVCONTAINER_SERVICE_NAME

RUN addgroup -g $DEVCONTAINER_SERVICE_ID -S $DEVCONTAINER_SERVICE_NAME && \
    adduser -S -D -H -u $DEVCONTAINER_SERVICE_ID -h /home/$DEVCONTAINER_SERVICE_NAME -s /sbin/nologin \
        -G $DEVCONTAINER_SERVICE_NAME -g $DEVCONTAINER_SERVICE_NAME $DEVCONTAINER_SERVICE_NAME && \
    sed -i "s/user\s*nginx/user\ $DEVCONTAINER_SERVICE_NAME/" /etc/nginx/nginx.conf && \
    apk add --no-cache fcgi

VOLUME /workspaces/TYPO3.introduction
EXPOSE 80

WORKDIR /workspaces/TYPO3.introduction
