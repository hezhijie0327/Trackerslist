# Trackerslist

一个全面且持续更新的 BitTorrent 跟踪器列表项目，聚合多个来源的跟踪器并提供验证。

## 项目介绍

本项目收集、验证并合并来自多个源的 BitTorrent 跟踪器列表。通过自动化脚本和 GitHub Actions，我们每天更新跟踪器列表，确保提供最新、最有效的跟踪器。

## 功能特点

- 📡 **多源聚合**: 从多个知名跟踪器列表源收集数据
- ✅ **智能验证**: 使用 DNS 查询和端口扫描验证跟踪器可用性
- 🔄 **自动更新**: 每日自动更新，确保跟踪器列表保持最新
- 📊 **多种格式**: 提供普通文本和 aria2 兼容格式
- 🚫 **排除列表**: 自动识别并排除不可用的跟踪器

## 文件说明

### 输出文件

- `trackerslist_tracker.txt` - 已验证的有效跟踪器列表
- `trackerslist_exclude.txt` - 不可用/无法访问的跟踪器列表
- `trackerslist_combine.txt` - 所有跟踪器（有效+无效）的合并列表
- `trackerslist_tracker_aria2.txt` - aria2 格式的有效跟踪器（逗号分隔）
- `trackerslist_exclude_aria2.txt` - aria2 格式的排除跟踪器（逗号分隔）
- `trackerslist_combine_aria2.txt` - aria2 格式的合并跟踪器（逗号分隔）

### 数据目录

- `data/data_http.txt` - HTTP/HTTPS 跟踪器种子数据
- `data/data_udp.txt` - UDP 跟踪器种子数据
- `data/data_ws.txt` - WebSocket 跟踪器种子数据

## 许可证

本项目采用 [Apache License 2.0 with Commons Clause v1.0](LICENSE) 许可证。
