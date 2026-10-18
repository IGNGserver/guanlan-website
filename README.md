# 观澜官网 · Guanlan Website

观澜 / Guanlan 的产品官网与下载入口。本仓库只承载官网站点，产品源码与发版在独立仓库维护：

- 产品仓库（唯一事实来源）：<https://github.com/IGNGserver/guanlan-monitor>
- 产品定位：私有部署的电脑与服务器监控工具，提供 Web 控制台、Windows / GNOME Linux 桌面端与 Android 客户端
- 托管目标：Cloudflare（Pages / Workers 待定，见 [`docs/HOSTING.md`](docs/HOSTING.md)）

> **状态**：首版站点已完成（Astro 7 + three.js，首页 / 下载 / 部署中枢），尚未部署上线。
> 视觉方向「数字观测站 · 精密仪器」与 3D 源资产说明见 [`design/DESIGN.md`](design/DESIGN.md)。

## 仓库结构

| 路径 | 内容 |
| --- | --- |
| [`src/`](src) | 页面、组件、样式、3D 场景与交互脚本；产品事实集中在 [`src/data/product.ts`](src/data/product.ts) |
| [`design/`](design) | 3D 源资产：共用几何 spec、Blender 构建脚本与 `.blend`、媒体生成工具 |
| [`public/`](public) | 压缩后的模型、社交卡片、图标 |
| [`tests/`](tests) | Playwright 端到端与产品事实一致性测试 |
| [`docs/SITE.md`](docs/SITE.md) | 官网定位、页面结构、内容原则、已知的产品侧不一致 |
| [`docs/HOSTING.md`](docs/HOSTING.md) | Cloudflare 托管方案与上线检查清单 |
| [`docs/WORKSPACE.md`](docs/WORKSPACE.md) | 本机 worktree 工作区约定 |
| [`scripts/verify-repository.sh`](scripts/verify-repository.sh) | 仓库契约检查（本地与 CI 共用） |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | CI：仓库契约、whitespace、凭据扫描；PR 上构建并跑端到端测试 |

## 开发

工作区、分支、验证与 PR 流程见 [`AGENTS.md`](AGENTS.md) 与 [`CONTRIBUTING.md`](CONTRIBUTING.md)。依赖安装与构建在项目卷之外的构建区进行：

```bash
pnpm install --store-dir "$BUILD_SCRATCH_ROOT/pnpm-store"
pnpm dev                          # 本地开发
pnpm build                        # astro check + astro build → dist/
pnpm exec playwright install chromium && pnpm test
```

## 许可

[MIT](LICENSE)
