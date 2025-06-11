FROM photoprism/photoprism:latest

# 환경변수는 런타임에 전달 (Secrets으로 관리)
ENV PHOTOPRISM_DEFAULT_LOCALE="ko"
ENV PHOTOPRISM_DATABASE_DRIVER="mariadb"
ENV PHOTOPRISM_LOG_LEVEL="info"
ENV PHOTOPRISM_UPLOAD_NSFW="true"

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
