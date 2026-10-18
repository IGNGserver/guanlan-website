# 托管方案（Cloudflare Pages）

> 目标：站点以 Cloudflare Pages 托管，正式域名为 `https://guanlan.igng.net/`。本文记录方案边界、
> 已具备的前提与上线检查清单；未完成项表示自定义域名或自动化发布尚未启用，不应据此宣称正式域名已上线。

## 已确认的前提（2026-10-18 核实）

- Cloudflare 账号已就绪，zone（`igng.net`）与 Pages 均可用；
- 本仓库为独立公开仓库，CI 走 GitHub Actions；
- 正式域名确定为 `https://guanlan.igng.net/`，Cloudflare Pages 项目建议名 `guanlan-site` 或 `guanlan-website`（Direct Upload）；
- `main` 合并不会自动触发生产发布，当前由 GitHub Actions 生成短期构建产物，再执行 Direct Upload。

## 构建产物（2026-10-18 定案）

- 安装：`pnpm install --frozen-lockfile`（Node.js 22.13+，`packageManager: pnpm@10.33.0`）；
- 构建命令：`pnpm build`（`astro check && astro build`）；输出目录 `dist/`（纯静态，含 404.html）；
- 当前 `SITE_URL`：`https://guanlan.igng.net/`；CI、Pages 项目环境变量与 `astro.config.mjs` 缺省值三处一致，改域名必须同时改这三处；
- 可选环境变量：`GITHUB_TOKEN`（构建时读取发布信息免限流）、`GUANLAN_OFFLINE=1`（离线构建，使用烘焙的发布信息）；
- 无边缘逻辑需求；`/models/observatory.glb`（约 0.5 MB）与 `/_astro/*` 可长缓存。

## 托管方案决策

| 方案 | 状态 | 说明 |
| --- | --- | --- |
| Cloudflare Pages（Direct Upload） | **当前方案** | GitHub Actions 构建 `dist/`，再上传到 Pages；适合当前已有的 CI 构建与测试流程 |
| Cloudflare Pages（Git 集成） | 未采用 | Direct Upload 流程更可控，避免外部平台反复拉取大型资产 |
| Workers 静态资源 | 未采用 | 当前没有边缘逻辑需求 |

## 搜索收录与发现

- Google Search Console：无需为本子域单独验证，域名资源 `sc-domain:igng.net` 已覆盖；sitemap 依赖 `public/robots.txt` 的 `Sitemap:` 行被发现；`public/sitemap.xml` 是手工维护的静态索引，新增页面时同步更新。
- Bing Webmaster Tools：若需要可通过验证 meta 或 GSC 关联导入。

## 上线检查清单

- [x] 前端技术栈与构建命令定案，登记到 `AGENTS.md` 并接入 CI（2026-10-18）；
- [x] 正式域名选定为 `https://guanlan.igng.net/`，并同步 `astro.config.mjs` 与 CI `SITE_URL`（2026-10-18）；
- [x] 补齐 `public/robots.txt` 与 `public/sitemap.xml`（2026-10-18）；
- [ ] 创建 Cloudflare Pages 项目（建议名 `guanlan-site`，Direct Upload）；
- [ ] 在 Cloudflare Pages 绑定自定义域名 `guanlan.igng.net`（proxied CNAME → `*.pages.dev`，zone `igng.net`）；
- [ ] 若启用 CI 持续部署：在 GitHub 仓库 Secrets 配置 `CLOUDFLARE_API_TOKEN` 与 `CLOUDFLARE_ACCOUNT_ID`；凭据不得提交；
- [ ] 手动 Direct Upload 首版发布：`npx wrangler pages deploy dist --project-name <项目名> --branch main`；
- [ ] 上线后验证：首页 200、HTTPS 证书生效、`/download/` 与 `/deploy/` 正常、404 返回 404；
- [ ] 评估是否将产品仓库 `homepage` 字段（当前未设置）改为官网域名。

## 发布与回滚

- 生产发布：在 GitHub Actions 手动触发 `Guanlan website checks` 的 `main` 工作流，下载 `site-dist-<commit-sha>` artifact，再通过 Cloudflare Pages Direct Upload 发布；构建与 artifact 只能放在 CI 或本机 scratch，不得写回项目卷；
- 发布命令（在 artifact 解包目录上执行；自定义域名绑定在项目上，因此每次发布都直接服务 `https://guanlan.igng.net/`）：
  `npx wrangler pages deploy dist --project-name <项目名> --branch main`；凭据只以环境变量 `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID` 注入，不得写进仓库或 CI 长期 Secrets；
- 正式入口：<https://guanlan.igng.net/>；
- 回滚：在 Cloudflare Pages 项目中选择上一成功部署版本恢复。发布前记录部署 ID 与对应的 `main` 提交；
- 域名变更：修改 DNS 记录前记录原值，回滚即恢复原记录。
