# Free iOS Development Probe：原生 iOS 测试工程

这是一个原生 SwiftUI 计数器，支持加减、0–99 边界、重置、重启持久化、中英界面与动态字体。项目保留 Linux 可测试的 `CounterKit`，通过 XcodeGen 生成 Xcode 工程，在 GitHub 的 macOS runner 编译和测试 iOS App。

## 不购买 Apple 开发者会员能做什么

| 环节 | 条件与当前验证范围 |
| --- | --- |
| Linux 本地开发 | 编写源码；用 Swift 或 Docker 跑业务逻辑测试、Python 跑静态预检 |
| iOS 编译和模拟器交互测试 | 需要 macOS/Xcode；本项目使用远程 GitHub macOS runner，不在 Linux 本机运行 Apple 模拟器 |
| 面向 iPhone 的未签名编译 | CI 生成 Release App 和未签名 IPA；此 IPA **不能直接安装到 iPhone** |
| 免费账号个人真机测试 | Apple 官方支持 Xcode Personal Team；需要 Mac、免费 Apple Account 和 iPhone，本项目未实测签名安装 |
| 常规 App Store、TestFlight 分发 | 需要 Apple Developer Program 成员资格，本项目未验证发布 |

免费 Personal Team 有每台设备最多 3 个 App、免费描述文件 7 天有效期等限制，过期后需要重新构建安装。参见 [Apple 账号说明](https://developer.apple.com/help/account/basics/about-your-developer-account/)与 [Xcode 系统要求](https://developer.apple.com/xcode/system-requirements/)。公开仓库的标准 hosted runner 免费，本工作流不使用 larger runner；硬件及私有仓库等费用另计。[GitHub 官方说明](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

## Linux 本地检查

有 Swift 6.2 时：

```sh
swift test --package-path Packages/CounterKit
```

没有 Swift 时，用 Docker 在只读挂载的源码上测试：

```sh
docker run --rm -v "$PWD/Packages/CounterKit:/src:ro" -w /src swift:6.2 \
  swift test --scratch-path /tmp/build
python3 scripts/preflight.py
python3 -m unittest discover -s scripts/tests -v
bash -n scripts/ci/ui-test.sh
```

`CounterKit` 有 4 个边界与重置单元测试。证据导出测试验证缺图、缺步骤截图和 PNG 签名错误不能被当成完整证据。导出器不执行完整图像解码，下载后仍需核对图片能打开及画面内容。`preflight.py` 是源码与产物静态检查，不能代替 Apple 审核。项目未配置独立第三方 linter；Swift 编译和 UI 测试在 macOS CI 执行。

仓库提供 `.githooks/pre-push`，可按需执行 `git config core.hooksPath .githooks` 启用。Docker 不可用时，该 hook 会提示并跳过业务测试，不能把这次 push 视作本地业务测试已通过；GitHub CI 仍执行业务测试。

## CI 触发与覆盖

在 [Actions 页面](https://github.com/Kingxiao/free-ios-development-probe-20261007/actions/workflows/ios.yml)选择分支和 `scope`；也可以使用当前环境的 CLI：

```sh
gh-axi workflow run ios.yml --repo Kingxiao/free-ios-development-probe-20261007 --ref <分支名> --field scope=quick
gh-axi workflow run ios.yml --repo Kingxiao/free-ios-development-probe-20261007 --ref <分支名> --field scope=full
```

| 触发 | 检查 |
| --- | --- |
| main 代码 push | Linux 业务测试、证据导出回归和静态预检 |
| 代码 PR / 手动 quick | 上述检查，加 iPhone SE 最新预装 iOS、浅色 UI 回归 |
| 手动 full / `v*` tag | 上述检查，加 SE、Pro Max、iPad 的深浅色矩阵、iOS 18 回归，以及 Release 未签名真机构建 |

UI 测试实际执行按钮点击并断言状态：

- 核心流程：初始 0 → 加到 3 → 减到 2 → 重置 0 → 下限保持 0 → 加到 5 并重启仍为 5，保留 6 张步骤截图。
- 语言与字号矩阵：英语/简体中文 × 默认/最大无障碍字号，逐次验证 `0 → 1 → 2 → Reset → 0`，每组保存计数 2 和重置 0 两张图。点击前通过有限次滚动确认控件完整位于视口且可点击；不要求所有内容挤在单屏内。
- Apple 无障碍审计：每个被测机型、系统、外观上的默认英语/默认字号页面执行完整审计。它**没有覆盖所有语言和字号组合的审计**；语言/字号矩阵另外验证布局、操作与状态。

一次成功的 quick/iOS 18 单外观运行应导出 **14 张主动截图**；full 的三个双外观机型各 **22 张**，另 iOS 18 **14 张**，合计 **80 张**。自动失败附件可能额外增加文件，不能只以图片数量判断测试通过。

## 在 Mac 上复现

安装兼容的 Xcode、相应 iOS 模拟器运行时和 XcodeGen，完成 Xcode 首次初始化：

```sh
brew install xcodegen
xcodegen generate
scripts/ci/ui-test.sh iPhone-SE-3rd-generation latest "light dark"
```

设备类型必须存在并与所选运行时兼容。重复运行前请先移走旧的 `build/*.xcresult` 和 `out/`；Xcode 不覆盖已有结果包。CI 使用全新 runner。iOS 18 检查使用指定的 Xcode 26.3 和预装运行时，runner 软件变化时需重新核验可用路径。

## 如何复查证据

下载对应 run 的 `ui-*` artifact：

- `out/screenshots/`：命名图片，例如 `iPhone-SE-3rd-generation-ios265-light-zh-Hans-ax-xxxl-count-2.png`。
- `build/light.xcresult`、`build/dark.xcresult`：原始 XCTest 结果包，包含断言、操作、附件及失败信息，可在 Mac 上用 Xcode 打开。
- `logs/`：构建与测试日志、环境和源码提交标识、每轮结构化测试摘要、导出日志。
- `ipa` artifact：Release 未签名 IPA 与真机构建日志，不能据此宣称签名或安装已经验证。

测试失败、摘要导出失败、截图导出失败或必需截图缺失都会让任务失败；仍尽力上传日志与原始结果包。产物保留 7 天，下载到本地后可长期留存。运行结果以对应提交的 CI 日志和测试包为准；分支中存在测试代码不等于测试已经通过。

## 凭据与提交边界

CI 显式使用 `contents: read`，checkout 不保留认证凭据。无需提供 Apple 账号、私钥、描述文件或个人 GitHub Token。证书、私钥、`.env`、构建和证据输出目录均加入忽略规则；提交前仍需检查实际暂存文件，忽略规则不能代替密钥检查。

## 已知回归与验收

原始 `6aac133` 的 [full 运行](https://github.com/Kingxiao/ios-hello-test/actions/runs/37326944043)中，SE 的浅色与深色无障碍审计报告 Reset 的动态字体支持不完整；业务交互与截图矩阵通过。迁移版本调整了大字号按钮布局，并保留原审计和更严格的滚动/状态检查。

2026-10-07，本仓库源码提交 `87f0f2e50b5a02010f65bb4083a29b6758253707` 的 [quick 运行](https://github.com/Kingxiao/free-ios-development-probe-20261007/actions/runs/37621698802)、[PR 检查](https://github.com/Kingxiao/free-ios-development-probe-20261007/actions/runs/37623122093)和 [full 运行](https://github.com/Kingxiao/free-ios-development-probe-20261007/actions/runs/37623731149)全部通过。后续 README 验收更新仅修改文档，没有修改该被测代码。

| 完整回归环境 | UI 测试执行次数 | 主动截图 | 原始结果包 |
| --- | ---: | ---: | ---: |
| iPhone SE 3 / iOS 26.5 / 深浅色 | 5 | 22 | 2 |
| iPhone 17 Pro Max / iOS 26.5 / 深浅色 | 5 | 22 | 2 |
| iPad A16 / iOS 26.5 / 深浅色 | 5 | 22 | 2 |
| iPhone 16 / iOS 18.6 / 浅色 | 3 | 14 | 1 |
| 合计 | **18，零失败** | **80** | **7** |

Linux 的 4 个业务测试、4 个证据导出回归和 17 项源码预检通过；Release 未签名真机构建通过。SE 两种外观的完整 Apple 无障碍审计通过，原来的 Reset 动态字体问题在本次环境中未重现。

完整产物已下载到本地项目的 `artifacts/migration-full-37623731149/`：80 张 PNG 均通过完整解码检查，7 份 `.xcresult`、结构化摘要和测试日志保留；`local-verification.json` 记录逐轮核对结果，`ipa/out/HelloApp-unsigned.ipa` 保留未签名产物。人工查看了 SE 深色中文最大字号、iPad 深色中文最大字号及 iOS 18 中文最大字号等代表截图。大字号的长内容需要滚动，截图不代表所有控件同时位于单屏内。

这些结果证明 Linux 编写/逻辑测试加远程 macOS 编译/模拟器测试的路径可行；仍未验证免费 Apple Account 的真机签名安装或商店发布。

## 迁移来源和历史证据

工程结构、业务模块和原始测试迁自用户指定的 [ios-hello-test 的 6aac133](https://github.com/Kingxiao/ios-hello-test/tree/6aac133e145d7b21b05c7857625b49d0772405a8)，随后补充了布局修正、状态断言、步骤截图、原始结果保留和 CI 安全配置。没有迁入其 Agent/MCP 配置。

本仓库原始最小探针的 [通过记录](https://github.com/Kingxiao/free-ios-development-probe-20261007/actions/runs/37616567439)对应 `5c1ec04`，只覆盖原先的单设备计数流程，不代表迁移后完整矩阵已通过。旧源码可从 Git 历史找回，旧本地证据仍在忽略提交的 `artifacts/`。迁移版本的验收结果以本仓库的新 CI 运行记录为准。
