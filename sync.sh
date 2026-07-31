#!/bin/bash
# Open Video Downloader 镜像同步脚本
# 用于在 GitHub Actions 之外手动同步上游代码

set -euo pipefail

# 配置
UPSTREAM_URL="https://github.com/jely2002/youtube-dl-gui.git"
UPSTREAM_BRANCH="main"
SYNC_INFO_FILE="upstream/.sync-info"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[信息]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }

# 检查 git
if ! command -v git &> /dev/null; then
    log_error "未找到 git，请先安装 git"
    exit 1
fi

# 添加上游远程仓库
if ! git remote get-url upstream &> /dev/null; then
    log_info "添加上游远程仓库：$UPSTREAM_URL"
    git remote add upstream "$UPSTREAM_URL"
fi

# 获取上游更新
log_info "正在获取上游更新..."
git fetch upstream --tags

# 获取上游最新提交哈希
UPSTREAM_HASH=$(git rev-parse "upstream/$UPSTREAM_BRANCH")
log_info "上游最新提交：$UPSTREAM_HASH"

# 检查是否有更新
if [ -f "$SYNC_INFO_FILE" ]; then
    OLD_HASH=$(grep "^commit=" "$SYNC_INFO_FILE" | cut -d'=' -f2)
    if [ "$UPSTREAM_HASH" = "$OLD_HASH" ]; then
        log_info "上游代码无变化，无需同步"
        exit 0
    fi
    log_info "检测到更新：$OLD_HASH -> $UPSTREAM_HASH"
else
    log_info "首次同步"
fi

# 导出上游代码
log_info "正在导出上游代码..."
rm -rf upstream
mkdir -p upstream
git archive "upstream/$UPSTREAM_BRANCH" | tar -x -C upstream/

# 获取版本号
VERSION=$(grep -m1 '"version"' upstream/package.json | sed 's/.*: *"//;s/".*//' 2>/dev/null || echo "unknown")
log_info "上游版本：$VERSION"

# 写入同步信息
cat > "$SYNC_INFO_FILE" << EOF
commit=$UPSTREAM_HASH
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
upstream_url=$UPSTREAM_URL
version=$VERSION
EOF

log_info "同步信息已写入 $SYNC_INFO_FILE"

# 提交更新
log_info "正在提交更新..."
git config user.name "$(git config user.name || echo 'mirror-bot')"
git config user.email "$(git config user.email || echo 'mirror@localhost')"
git add upstream/
git commit -m "chore: 同步上游代码 $VERSION ($(date -u +%Y-%m-%d))"

# 创建镜像标签
SHORT_HASH=$(echo "$UPSTREAM_HASH" | cut -c1-7)
TAG_NAME="mirror-v${VERSION}-${SHORT_HASH}"

if git tag -l "$TAG_NAME" | grep -q "$TAG_NAME"; then
    log_warn "标签 $TAG_NAME 已存在，跳过"
else
    log_info "正在创建镜像标签：$TAG_NAME"
    git tag "$TAG_NAME"
fi

# 推送
log_info "正在推送到远程仓库..."
git push origin HEAD
git push origin "$TAG_NAME" 2>/dev/null || log_warn "标签 $TAG_NAME 推送失败（可能已存在）"

# 同步上游标签
log_info "正在同步上游标签..."
for tag in $(git tag -l | grep -v "^mirror-"); do
    if git ls-remote --tags origin | grep -q "refs/tags/$tag"; then
        echo "  标签 $tag 已存在于远程，跳过"
    else
        echo "  推送标签：$tag"
        git push origin "$tag" 2>&1 || {
            log_warn "标签 $tag 推送失败（可能需要 PAT 令牌）"
        }
    fi
done

log_info "✅ 同步完成！"
log_info "版本：$VERSION"
log_info "镜像标签：$TAG_NAME"
