# 观澜官网（guanlan-website）· 项目 Agent 规范

> 只写本仓库与设备级规范的**差异**。Git 纪律、worktree 路径与生命周期、基线解析、冲突处理、
> PR 流程一律见 `~/.qoder/coder-rules/global-rules.md`，不在这里重复；冲突时以设备级安全条款为准。

Collaboration: solo
Baseline: main
Release: none
Validation: `bash scripts/verify-repository.sh`、`git diff --check`（CI `verify` 作业，每次 push）；`pnpm build`（= `astro check` + `astro build`）、`pnpm test`（Playwright 端到端 + 产品事实一致性，需先 build）（CI `site` 作业，PR 上运行）。
Worktree: `~/项目/.wt/观澜-site/<slug>`

## 这是什么

观澜 / Guanlan 的官网与下载入口，源码与产品仓库分离维护：

- 产品仓库（唯一事实来源）：`https://github.com/IGNGserver/guanlan-monitor`；
- 本仓库只承载站点（页面、样式、静态资源、站点文档），不得复制产品源码、安装包或发布资产。

## 技术栈（2026-10-18 定案）

- Astro 7（纯静态输出 `dist/`）+ TypeScript；3D 场景用 three.js（空闲时懒加载，失败或减少动态时停在 Blender 静帧），其余交互为原生脚本；
- 包管理 pnpm（`packageManager` 已锁定），Node.js ≥ 22.13；字体全部自托管（`@fontsource-variable/*`）；
- 3D 源资产（Blender 构建脚本、`.blend`、Blender 与站点共用的几何 spec）及再生成方法见 `design/DESIGN.md`；
- 页面结构、内容来源与语言策略见 `docs/SITE.md`。

**构建不在项目卷上跑**（设备级规范第 5c 节）：`node_modules`、`dist/`、`.astro/`、Playwright 浏览器一律放在
`$BUILD_SCRATCH_ROOT/观澜-site/<slug>/`（从 worktree 同步出的无 `.git` 副本）里安装与构建；依赖变更后把
`package.json` 与 `pnpm-lock.yaml` 拷回 worktree 再提交。pnpm 在项目卷路径下会默认把 store 放到
`~/项目/.pnpm-store`，安装时显式加 `--store-dir "$BUILD_SCRATCH_ROOT/pnpm-store"`。

## 集成补充

- 无额外门槛：按设备级规范第 5 节（solo）执行；`main` 已设分支保护（要求 CI `verify` 通过、线性历史），必须经 PR；改动涉及站点源码时 `site` 作业也须通过。
- 站点部署（Cloudflare）不随合并自动发生，见 `docs/HOSTING.md`。

## 发布

- 无版本化 Release（`Release: none`）；站点以持续部署方式发布，未启用前不得创建 tag 或 Release。

## 项目特殊限制

- 不得提交 `node_modules`、构建产物（`dist/`、`.astro/`）、`.wrangler/`、`.env*` 与任何凭据；`scripts/verify-repository.sh` 会拦截。
- 站点示意数据（首屏读数、实时面板）必须在界面上标注「示意数据」；3D 仪器是虚构的隐喻，不得暗示观澜是硬件产品。
- 站点文案引用产品事实（功能、平台、版本）时必须与产品仓库当前 `README.md` / Releases 对齐，不得编造未发布能力。
- 品牌名：中文显示「观澜」；英文名与字标未在产品仓库定案，官网不得自行发明（标识符沿用 `guanlan` 前缀）。
- 正式域名 `https://guanlan.igng.net/`，托管方案定为 Cloudflare Pages Direct Upload；域名或项目名变更要在 `docs/HOSTING.md` 登记，并同步 CI 的 `SITE_URL` 与 `astro.config.mjs` 缺省值。

## 环境事实

- 开发位置：NAS 共享卷 `~/项目`（ubuntu-dev 为 CIFS，macOS 设备为 NFSv3）；仓库锚点 `~/项目/项目网站/观澜-site`，任务 worktree 在 `~/项目/.wt/观澜-site/<slug>`。
- 本地构建只在本机盘可用的设备上做（见设备级规范第 11 节）；ubuntu-dev 根盘低于 20G 闸门时一律走 CI。
- 生产目标：Cloudflare Pages Direct Upload 项目，正式域名 `https://guanlan.igng.net/`；自动发布流程未启用，不写凭据。
