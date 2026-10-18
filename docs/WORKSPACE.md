# 工作区、分支与集成

## 目录布局

项目根为 `~/项目`（各设备挂载点不同，`wt` 用 `WT_ROOT_DIR` 指定）。本仓库的 Git 锚点目录是：

```text
~/项目/项目网站/观澜-site/                 # .git + 仓库锚点，不用于开发
~/项目/.wt/观澜-site/<task-slug>/          # 任务 worktree，唯一开发位置
```

远端 `main` 是唯一开发基线；不在主目录检出源码、改文件或建提交。

## 创建任务 worktree

```bash
REPO="$HOME/项目/项目网站/观澜-site"
git -C "$REPO" fetch origin --prune
BASE=$(git -C "$REPO" symbolic-ref --quiet --short refs/remotes/origin/HEAD | sed 's|^origin/||')
test "$BASE" = main
PATH="$HOME/.local/bin:$PATH" wt new 观澜-site site-homepage
```

`wt new` 会从 `origin/main` 创建 `agent/site-homepage` 与对应目录；slug 使用可读 ASCII 名称，不使用随机名。
`wt` 不可用时的等价命令：

```bash
git -C "$REPO" worktree add ~/项目/.wt/观澜-site/site-homepage -b agent/site-homepage origin/main
```

使用等价命令时也必须确认 worktree 的 `HEAD` 与创建时的 `origin/main` 一致。

## 开发与同步

- 不使用 `git pull`；需要同步时先 `git fetch origin --prune`；
- 任务进行中不因基线前进擅自 rebase / merge；只有集成前、冲突阻塞或任务确实依赖基线更新时才处理，并重跑全部验证；
- 不修改、不复用其他任务的 worktree，不在 worktree 内再建 worktree；
- 构建产物与依赖缓存不进工作区：在 `$BUILD_SCRATCH_ROOT/观澜-site/<slug>/` 的同步副本里安装与构建（见 `AGENTS.md`「技术栈」）。

## 收尾

```bash
git status --short
git diff --check
bash scripts/verify-repository.sh
git push -u origin agent/<task-slug>
PATH="$HOME/.local/bin:$PATH" wt done 观澜-site <task-slug>
```

`wt done` 遇到未提交或未推送内容会保护性停止；清理前必须确认没有未提交改动。

## 集成

`main` 受分支保护：必须经 PR，CI `verify` 通过且分支与 `main` 保持最新（线性历史、Squash 合并；
无人工 review 要求，solo 模式验证通过后 Agent 可自行合并，见设备级规范第 5 节）。部署不随合并自动发生。
