#!/bin/bash
set -e

DATA_DIR=/app/data
WORK_DIR=/tmp/backup_repo
BACKUP_REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${BACKUP_REPO}.git"

mkdir -p "$DATA_DIR"

git config --global user.email "backup@komari.local"
git config --global user.name "Komari Backup Bot"

if [ -n "$GITHUB_TOKEN" ]; then
  echo "[启动恢复] 正在从 GitHub 拉取最新备份..."
  rm -rf "$WORK_DIR"
  git clone --depth 1 "$BACKUP_REPO_URL" "$WORK_DIR" 2>/dev/null || echo "[启动恢复] 仓库为空或克隆失败，跳过恢复"

  if [ -d "$WORK_DIR" ]; then
    LATEST=$(ls -t "$WORK_DIR"/dashboard-*.tar.gz 2>/dev/null | head -n1)
    if [ -n "$LATEST" ]; then
      echo "[启动恢复] 找到备份: $LATEST，正在恢复..."
      tar xzf "$LATEST" -C "$DATA_DIR"
      echo "[启动恢复] 恢复完成"
    else
      echo "[启动恢复] 未找到备份文件，使用全新数据库"
    fi
  fi
fi

# 每 6 小时自动备份一次
echo "0 */6 * * * /backup.sh >> /var/log/backup.log 2>&1" > /etc/crontabs/root
crond -b -L /var/log/cron.log

echo "[启动] Komari 主程序启动..."
exec /app/komari server -l 0.0.0.0:25774
