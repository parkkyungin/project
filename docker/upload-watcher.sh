#!/bin/bash
set -x

WATCH_DIR="/photoprism/originals"
S3_BUCKET="${PHOTOPRISM_S3_BUCKET}"
S3_URL="s3://${S3_BUCKET}"

if [ -z "$S3_BUCKET" ]; then
  echo "Error: PHOTOPRISM_S3_BUCKET 환경변수가 설정되어 있지 않습니다!"
  exit 1
fi

echo "Watching $WATCH_DIR for new uploads to sync with $S3_URL..."

upload_file() {
  local file_path=$1
  local s3_path="s3://${S3_BUCKET}$2"

  echo "[UPLOAD] $file_path → $s3_path"
  aws s3 cp "$file_path" "$s3_path" --region "${AWS_REGION}"
}

# 실시간 업로드 감지 (1분 대기)
inotifywait -m -r -e close_write,create,moved_to "$WATCH_DIR" |
while read -r directory events filename; do
  if [ -f "${directory}/${filename}" ]; then
    FILE_PATH="${directory}/${filename}"
    REL_PATH="${directory#$WATCH_DIR}"

    echo "[INFO] 파일 업로드 감지됨. 1분 대기 후 S3에 업로드 시작"
    sleep 60

    S3_PATH="${REL_PATH}/${filename}"
    upload_file "$FILE_PATH" "$S3_PATH"
  fi
done &

INOTIFY_PID=$!

# 주기적 동기화 (10분 간격)
while true; do
  sleep 600
  echo "[SYNC] S3 → 로컬 복원"
  aws s3 sync "$S3_URL" "$WATCH_DIR" --exact-timestamps --delete --region "${AWS_REGION}"

  echo "[SYNC] 로컬 → S3 백업"
  aws s3 sync "$WATCH_DIR" "$S3_URL" --exact-timestamps --delete --region "${AWS_REGION}"
done

# 종료 처리
trap "kill $INOTIFY_PID; exit" INT TERM
wait $INOTIFY_PID
