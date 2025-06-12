FROM photoprism/photoprism:latest

# 기본 설정 (비밀정보 제외)
ENV PHOTOPRISM_DEFAULT_LOCALE="ko"
ENV PHOTOPRISM_LOG_LEVEL="info"
ENV PHOTOPRISM_UPLOAD_NSFW="true"
ENV PHOTOPRISM_DELETE_ENABLED: "true"
ENV PHOTOPRISM_AUTH_MODE="password"
ENV PHOTOPRISM_DISABLE_SIGNUP="false"
ENV PHOTOPRISM_DISABLE_USERS="false"
ENV PHOTOPRISM_READONLY="false"

# 빌드 타임 변수 선언
ARG PHOTOPRISM_DATABASE_SERVER
ARG PHOTOPRISM_DATABASE_NAME
ARG PHOTOPRISM_DATABASE_USER
ARG PHOTOPRISM_DATABASE_PASSWORD
ARG PHOTOPRISM_ADMIN_PASSWORD
ARG PHOTOPRISM_S3_BUCKET
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_REGION

# 런타임 환경변수 설정
ENV PHOTOPRISM_DATABASE_SERVER=$PHOTOPRISM_DATABASE_SERVER
ENV PHOTOPRISM_DATABASE_NAME=$PHOTOPRISM_DATABASE_NAME
ENV PHOTOPRISM_DATABASE_USER=$PHOTOPRISM_DATABASE_USER
ENV PHOTOPRISM_DATABASE_PASSWORD=$PHOTOPRISM_DATABASE_PASSWORD
ENV PHOTOPRISM_ADMIN_PASSWORD=$PHOTOPRISM_ADMIN_PASSWORD
ENV PHOTOPRISM_S3_BUCKET=$PHOTOPRISM_S3_BUCKET
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=$AWS_REGION

WORKDIR /photoprism

# AWS CLI 설치
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    unzip \
    inotify-tools && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/venv/bin:$PATH"

# 감지 스크립트 복사
COPY upload-watcher.sh /usr/local/bin/upload-watcher.sh
RUN chmod +x /usr/local/bin/upload-watcher.sh

# 진입점 스크립트 생성
RUN echo '#!/bin/bash\n\
/usr/local/bin/upload-watcher.sh &\n\
exec /opt/photoprism/bin/photoprism start\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
