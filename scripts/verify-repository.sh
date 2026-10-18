#!/usr/bin/env bash
# 仓库契约检查：本地与 CI 共用。新增契约项时同步更新本文件与 CI。
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

required_files=(
  AGENTS.md README.md CONTRIBUTING.md SECURITY.md LICENSE
  .gitignore .gitattributes .editorconfig
  docs/SITE.md docs/HOSTING.md docs/WORKSPACE.md
  .github/workflows/ci.yml .github/pull_request_template.md .github/CODEOWNERS
  package.json pnpm-lock.yaml astro.config.mjs tsconfig.json playwright.config.ts
  src/data/product.ts
  design/DESIGN.md design/observatory.json design/blender/build_observatory.py design/blender/guanlan_observatory.blend
  public/models/observatory.glb
)
for file in "${required_files[@]}"; do
  test -f "$file" || { echo "missing required file: $file" >&2; exit 1; }
done

# AGENTS.md 的模式行必须保持可被设备级钩子安装器解析
mode=$(grep -m1 -oE 'Collaboration: [a-z]+' AGENTS.md | cut -d' ' -f2 || true)
case "$mode" in
  solo|collaborative|frozen) ;;
  *) echo "AGENTS.md 缺少合法的 Collaboration 行: ${mode:-<missing>}" >&2; exit 1 ;;
esac
grep -qE '^Baseline: main$' AGENTS.md || { echo "AGENTS.md 缺少 Baseline: main" >&2; exit 1; }

# 凭据类文件不得被跟踪
if git ls-files -z | grep -E -z '(^|/)(\.env|\.dev\.vars)$|\.(pem|key|p12|jks|keystore)$' >/dev/null; then
  echo "tracked credential-like file detected" >&2
  exit 1
fi

# 依赖与本地状态目录不得被跟踪
if git ls-files -z | grep -E -z '(^|/)(node_modules|\.wrangler|\.output|\.astro|dist|test-results|playwright-report)/' >/dev/null; then
  echo "tracked dependency/build-state directory detected" >&2
  exit 1
fi

# 站点资产体积预算：模型与单个静态资源不得失控（Cloudflare 单文件上限 25 MiB，首屏要轻）
while IFS= read -r -d '' f; do
  size=$(wc -c <"$f" | tr -d ' ')
  limit=1572864
  case "$f" in
    design/blender/*.blend) limit=8388608 ;;
  esac
  if [ "$size" -gt "$limit" ]; then
    echo "asset over budget ($size > $limit bytes): $f" >&2
    exit 1
  fi
done < <(git ls-files -z -- 'public/*' 'src/assets/*' 'design/blender/*')

# design/observatory.json 必须是合法 JSON（Blender 与站点共用）
if command -v node >/dev/null 2>&1; then
  node -e "JSON.parse(require('fs').readFileSync('design/observatory.json','utf8'))" || { echo "design/observatory.json 不是合法 JSON" >&2; exit 1; }
fi

# 文本内容中的凭据模式（与设备级规范第 9 节一致）
if grep -RIlE 'gh[pousr]_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----' \
    --exclude-dir=.git --exclude='*.png' --exclude='*.jpg' --exclude='*.jpeg' --exclude='*.webp' --exclude='*.ico' . >/dev/null 2>&1; then
  echo "credential-like material detected in repository text" >&2
  exit 1
fi

echo "repository verification passed"
