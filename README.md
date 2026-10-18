# 观澜官网（guanlan-website）

观澜 / Guanlan 的产品官网与下载入口。本仓库只承载官网站点，产品源码与安装包由产品仓库维护。

- 产品仓库（唯一事实来源）：<https://github.com/IGNGserver/guanlan-monitor>
- 产品定位：私有部署的电脑与服务器运行状态监控工具
- 托管方案：Cloudflare Pages Direct Upload（见 [`docs/HOSTING.md`](docs/HOSTING.md)）

> **状态**：首版站点已正式部署上线：<https://guanlan.igng.net/>。

## 仓库结构

- `src/`：站点源码（Astro 7 静态站点 + three.js，空闲时懒加载 3D 观测单元）；
- `design/`：3D 观测单元的几何定义（`observatory.json`）、Blender 5.2 构建脚本与母版（`guanlan_observatory.blend`），设计规范见 `design/DESIGN.md`；
- `public/`：静态资产（`observatory.glb`、OG 图、图标、robots.txt、sitemap.xml）；
- `docs/`：站点规范（`SITE.md`）、托管与部署（`HOSTING.md`）、工作区流程（`WORKSPACE.md`）；
- `tests/`：Playwright 端到端检查与产品事实核对测试；
- `scripts/verify-repository.sh`：仓库契约校验脚本。

## 生产部署

生产部署遵循设备级规范第 5c 节（NAS 共享卷不承载重型构建）：
1. 在 GitHub Actions 手动触发 `main` 工作流生成 `site-dist-<commit-sha>` 产物包；
2. 下载至本机 scratch 构建区（`$HOME/.build`）；
3. 执行 `npx wrangler pages deploy dist --project-name guanlan-website --branch main` 发布。

详细部署、域名记录与回滚说明见 [`docs/HOSTING.md`](docs/HOSTING.md)。
