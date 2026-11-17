# Trackerslist

[![License](https://img.shields.io/badge/License-Apache%202.0--Commons%20Clause-blue)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](https://www.python.org/)

Trackerslist 聚合多个公开来源的 BitTorrent 跟踪器，逐条验证连通性后输出有效、排除与合并三档列表；Python 3.9+ 标准库实现，UDP 探测依赖 `nmap`，GitHub Actions 每日更新。开发规范见 [AGENTS.md](AGENTS.md)。

## 特性

- **多源聚合**：从多个知名跟踪器列表源收集数据
- **智能验证**：并发 DNS 解析 + TCP 端口连通性检查，UDP 跟踪器经 nmap 探测
- **自动更新**：每日自动更新，确保跟踪器列表保持最新
- **多种格式**：提供普通文本和 aria2 兼容格式
- **排除列表**：自动识别并排除不可用的跟踪器

## 快速开始

### 直接下载

| 列表 | 纯文本 | aria2（逗号分隔） |
| ---- | ------ | ----------------- |
| 已验证 tracker | [tracker.txt](dist/tracker.txt) | [tracker_aria2.txt](dist/tracker_aria2.txt) |
| 排除 | [exclude.txt](dist/exclude.txt) | [exclude_aria2.txt](dist/exclude_aria2.txt) |
| 合并 | [combine.txt](dist/combine.txt) | [combine_aria2.txt](dist/combine_aria2.txt) |

### 本地构建

```bash
git clone https://github.com/hezhijie0327/Trackerslist.git
cd Trackerslist
python3 build.py
```

依赖：Python 3.9+（仅标准库）、`nmap`（UDP 探测）。验证阶段使用 64 路并发，通常数分钟内完成。

## 用法

### 自定义种子

| 协议 | 种子文件 |
| ---- | -------- |
| HTTP/HTTPS | [http.txt](custom/http.txt) |
| UDP | [udp.txt](custom/udp.txt) |
| WebSocket | [ws.txt](custom/ws.txt) |

种子文件经 main 分支 URL 自引用拉取，与第三方源一起参与合并和验证。

## 文档

- [AGENTS.md](AGENTS.md) — 开发规范与实现细节（英文）

## License

[Apache License 2.0 with Commons Clause v1.0](LICENSE)
