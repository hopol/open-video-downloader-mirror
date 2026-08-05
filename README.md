# Open Video Downloader 镜像仓库

[![同步状态](https://github.com/hopol/open-video-downloader-mirror/actions/workflows/sync.yml/badge.svg)](https://github.com/hopol/open-video-downloader-mirror/actions/workflows/sync.yml)
[![镜像发布](https://github.com/hopol/open-video-downloader-mirror/actions/workflows/release.yml/badge.svg)](https://github.com/hopol/open-video-downloader-mirror/actions/workflows/release.yml)
[![许可证](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 简介

这是 [jely2002/youtube-dl-gui](https://github.com/jely2002/youtube-dl-gui)（Open Video Downloader）的自动镜像仓库。

**本项目不做任何修改和编译**，仅提供：
- 📦 **源码同步**：每5天自动备份上游源代码
- 🚀 **发布镜像**：自动镜像上游的客户端发布版本
- 📝 **中文日志**：每个版本附带中文更新说明

## 为什么需要镜像？

GitHub 上的开源项目可能因为维护调整、作者归档等原因变得不可访问。本镜像仓库确保即使上游项目出现问题，源码和客户端仍然可用。

## 下载客户端

前往 [Releases](https://github.com/hopol/open-video-downloader-mirror/releases) 页面下载最新版本。

| 平台 | 文件 |
|------|------|
| Windows x64 | `Open.Video.Downloader_*_x64-setup.exe` / `*_x64-portable.zip` |
| Windows ARM64 | `Open.Video.Downloader_*_arm64-setup.exe` / `*_arm64-portable.zip` |
| Linux x64 | `.deb` / `.rpm` / `.AppImage` |
| Linux ARM64 | `.deb` / `.rpm` / `.AppImage` |

## 工作原理

### 源码同步（每5天）

```
上游仓库 (jely2002/youtube-dl-gui)
    ↓ git fetch
对比提交哈希
    ↓ 有变化
git archive 导出 → upstream/
    ↓
提交 & 推送 & 创建标签
```

### 发布镜像（每5天检查）

```
检查上游最新 Release
    ↓
是否已镜像？
    ├─ 是 → 跳过
    └─ 否 ↓
下载客户端文件（排除 .sig 和 latest.json）
    ↓
生成中文 Changelog + 原始日志
    ↓
创建镜像 Release（mirror-{版本号}）
```

## 标签说明

| 标签格式 | 说明 | 示例 |
|----------|------|------|
| `mirror-v{版本}-{哈希}` | 源码同步标签 | `mirror-v3.2.1-abc1234` |
| `mirror-{版本}` | 发布镜像标签 | `mirror-3.2.1` |

## 项目结构

```
open-video-downloader-mirror/
├── .github/
│   └── workflows/
│       ├── sync.yml           # 源码同步工作流（每5天）
│       └── release.yml        # 发布镜像工作流（每5天检查）
├── upstream/                  # 上游源码（运行时生成）
├── sync.sh                    # 本地同步脚本
├── README.md                  # 本文档
├── .gitignore
└── LICENSE
```

## 本地同步

```bash
git clone https://github.com/hopol/open-video-downloader-mirror.git
cd open-video-downloader-mirror
git remote add upstream https://github.com/jely2002/youtube-dl-gui.git
chmod +x sync.sh
./sync.sh
```

## 上游项目信息

- **项目名称**：Open Video Downloader
- **上游仓库**：https://github.com/jely2002/youtube-dl-gui
- **技术栈**：Tauri 2 + Vue 3 + Rust + TypeScript
- **上游许可证**：AGPL-3.0-or-later
- **核心功能**：基于 yt-dlp 的跨平台视频下载工具，支持数百个网站

## 许可证

本镜像仓库采用 [MIT 许可证](LICENSE)。

上游项目 Open Video Downloader 采用 [AGPL-3.0-or-later](https://github.com/jely2002/youtube-dl-gui/blob/main/LICENSE) 许可证。

## 致谢

感谢 [Jelle Glebbeek](https://github.com/jely2002) 创建了优秀的 Open Video Downloader 项目。
