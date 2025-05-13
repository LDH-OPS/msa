#!/bin/bash

# 로그 파일 설정
LOG_FILE="/var/log/msa-deploy.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 에러 처리 함수
handle_error() {
    local exit_code=$1
    local error_message=$2
    echo "[ERROR] ${TIMESTAMP} - ${error_message}" | tee -a "${LOG_FILE}"
    # 실패 시 Slack이나 Discord로 알림 보내기 (선택적)
    # curl -X POST -H 'Content-type: application/json' --data '{"text":"배포 실패: '"${error_message}"'"}' $WEBHOOK_URL
    exit "${exit_code}"
}

# 상태 체크 함수
check_service() {
    local service_name=$1
    local max_attempts=30
    local attempt=1

    echo "[INFO] Checking ${service_name} status..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f http://localhost:8081/api/hello > /dev/null; then
            echo "[INFO] ${service_name} is up and running"
            return 0
        fi
        echo "[INFO] Waiting for ${service_name} to start (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done

    handle_error 1 "${service_name} failed to start"
}

# 배포 시작
echo "[INFO] ${TIMESTAMP} - Starting deployment..." | tee -a "${LOG_FILE}"

# 프로젝트 디렉토리로 이동
cd ~/msa || handle_error 1 "Failed to change directory"

# 현재 상태 백업
echo "[INFO] Creating backup..."
BACKUP_DIR="./backups/${TIMESTAMP}"
mkdir -p "${BACKUP_DIR}"
cp -r ./backend/build/libs/* "${BACKUP_DIR}/" 2>/dev/null || true

# 최신 코드 가져오기
echo "[INFO] Pulling latest code..."
git pull origin main || handle_error 1 "Failed to pull latest code"

# 백엔드 빌드
echo "[INFO] Building backend..."
./gradlew build -p backend || handle_error 1 "Backend build failed"

# 도커 컨테이너 재시작
echo "[INFO] Restarting docker containers..."
docker-compose down || handle_error 1 "Failed to stop containers"
docker-compose build || handle_error 1 "Failed to build containers"
docker-compose up -d || handle_error 1 "Failed to start containers"

# 서비스 상태 체크
check_service "backend"

echo "[INFO] ${TIMESTAMP} - Deployment completed successfully!" | tee -a "${LOG_FILE}"

# 오래된 백업 정리 (30일 이상)
find ./backups -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
