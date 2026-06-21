#!/bin/bash
DATA_DIR=/app/data
WORK_DIR=/tmp/backup_repo
BACKUP_REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${BACKUP_REPO}.git"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
FILENAME="dashboard-${DATE}.tar.gz"

echo "[备份] 开始打包 $(date)"
tar czf "/tmp/${FILENAME}" -C "$DATA_DIR" .

rm -rf "$WORK_DIR"
git clone --depth 1 "$BACKUP_REPO_URL" "$WORK_DIR"
cp "/tmp/${FILENAME}" "$WORK_DIR/${FILENAME}"
cd "$WORK_DIR"

# 只保留最近28份备份（约7天）
ls -t dashboard-*.tar.gz 2>/dev/null | tail -n +29 | xargs -r rm --

git add -A
git commit -m "Backup ${DATE}" || echo "无变化，跳过提交"
git push
echo "[备份] 完成 $(date)"
