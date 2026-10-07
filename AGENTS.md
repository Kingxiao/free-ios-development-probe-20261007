# 项目工作约定

本项目验证 Linux 开发纯 Swift 业务逻辑、远程 macOS 编译与 iOS 模拟器交互测试。最低系统 iOS 18，界面使用 SwiftUI。以 README 和对应提交的测试结果为准，历史资料只作来源参考。

- 多文件或有歧义的任务，编辑前说明文件、方法和风险；分步骤验证，保留已有工作。
- 改 SwiftUI 界面或做评审时，按需读取 `.agents/skills/swiftui-pro/SKILL.md`；涉及动态字号、辅助操作、对比度或无障碍验收时，再读取 `.agents/skills/ios-accessibility/SKILL.md`。引用文件相对各 Skill 根目录解析，按需加载。
- Skill 是项目参考。遵循当前用户要求和项目约定；API 选择先核对 Apple/Swift 官方资料与最低系统可用性，避免仅为较新写法重构正常代码。
- 业务逻辑放在 `Packages/`，不得引入 SwiftUI/UIKit/XCTest UI 测试依赖到 Linux 业务包。沿用现有组件与命名，新增 helper 前先搜索已有实现。
- 实际用到硬件能力时，按 `docs/development-testing.md` 隔离依赖，记录模拟与真机覆盖范围；不要提前搭建未使用的空框架。
- 代码和 CI 改动后运行下列检查，并检查最终 diff。失败需修复或明确报告，不能把静态检查、截图存在或构建通过等同于完整验收。
- 提交使用明确文件清单。证书、私钥、Token、本机配置、历史对话、截图与构建产物不得提交到公开仓库。实际扫描与 diff 检查优先于只依赖忽略规则。

在仓库根目录执行：

```sh
docker run --rm -v "$PWD/Packages/CounterKit:/src:ro" -w /src swift:6.2 \
  swift test --scratch-path /tmp/build
python3 -m unittest discover -s scripts/tests -v
python3 scripts/preflight.py
bash -n scripts/ci/ui-test.sh
git diff --check
```

本项目没有独立第三方 linter/typechecker。纯 Swift 编译由上面的业务测试覆盖；SwiftUI 编译、交互和无障碍审计由 macOS CI 覆盖。CI 输入改动核对 PR、手动 quick/full、版本标签和 main push 的分支行为，并实际运行受影响的入口。PR 固定 SE 浅色，手动 quick 可选机型，完整矩阵用于跨设备验收。
