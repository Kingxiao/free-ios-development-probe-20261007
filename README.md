# 免费 Apple 账号开发 iOS：可复现验证

此仓库验证原生 SwiftUI App 在**没有 Apple 账号、没有开发者会员、没有签名证书**的 CI 环境中，是否能编译、在 iPhone 模拟器运行并通过界面交互测试。

## 已完成的实测（2026-10-07）

[GitHub Actions 运行记录](https://github.com/Kingxiao/free-ios-development-probe-20261007/actions/runs/37616567439)已成功，测试代码提交为 `5c1ec04296f84524f4c19418e8bd9fca662d32d5`。

- 环境日志：macOS 15.7.9、Xcode 16.4；选中的模拟器为 iPhone 17 Pro / iOS 26.2。
- 模拟器编译、Xcode 静态分析、模拟器安装和启动：通过。
- XCTest 真实界面交互：启动 App，读取初值 0，实际点击两次加一并分别断言 1、2，再点击重置并断言 0。**1 个测试，0 失败，14.098 秒**。日志记录了三次 `Tap` 和事件合成。
- 面向 iPhone 的 Release 未签名编译：通过；此产物仍不能直接安装到 iPhone。
- CI 整轮运行耗时 11 分 33 秒，包含环境准备、编译、模拟器启动、测试及证据上传；不代表每次迭代都需要同样时间。
- 已下载并核对完整日志、界面截图、`.xcresult` 测试包与模拟器 App；GitHub 证据下载入口在上述运行页面，保留 7 天。本地证据在忽略提交的 `artifacts/` 目录中。

结论：不用购买 Apple 开发者会员，可以开发原生 iOS App；当前只有 Linux 电脑时，已验证可用的是**本地编写代码 + 远程 macOS 构建与模拟器交互测试**。没有在 Linux 本机运行 Apple 模拟器，也没有实测免费 Apple Account 的真机签名安装。

## 验证范围

| 环节 | 需要付费 Apple Developer Program 吗 | 本测试 |
| --- | --- | --- |
| Linux 本地编写 Swift 源码和 Xcode 工程 | 否 | 本地创建 |
| Xcode 编译和 iOS 模拟器运行 | 否；需要 macOS/Xcode | GitHub macOS runner 实测 |
| 编译面向真机的未签名 App | 否；需要 macOS/Xcode | CI 实测；**不能直接安装** |
| 免费账号签名并安装个人 iPhone | 否；需要 Personal Team、设备、签名配置 | 未实测 |
| TestFlight 和常规 App Store 发布 | 需要开发者计划成员资格 | 不在本测试范围 |

CI 是远程 macOS 构建环境，不是 Linux 上运行的 iOS 模拟器。模拟器产物不能安装到 iPhone；未签名真机产物也不能直接安装。

## 在 Mac 上复现

安装 Xcode 及 iOS 模拟器运行时，完成 Xcode 首次启动初始化后：

```sh
bash scripts/verify-macos.sh
```

脚本执行工程语法检查、模拟器编译、Xcode 静态分析、模拟器安装和启动、XCTest 界面测试、未签名真机编译。界面测试检查 `0 → 1 → 2 → Reset → 0`。此最小项目没有单独配置第三方 linter。

`artifacts/` 包含环境版本、截图、日志、测试结果和模拟器 App。重复运行前，请先移动或清除旧的 `artifacts/UITests.xcresult`；Xcode 不覆盖已有结果包。GitHub 全新 runner 无此问题。

## 在个人 iPhone 上免费测试（需用户本机操作，未实测）

1. 用 Mac 的 Xcode 打开 `FreeIOSProbe.xcodeproj`。
2. 在 Xcode Settings → Accounts 登录免费 Apple Account。
3. 在 App target → Signing & Capabilities 选择个人 Personal Team，启用 Automatically manage signing，并把 Bundle Identifier 改为自己的唯一标识。
4. 连接 iPhone，完成设备信任并按 Xcode 提示开启 Developer Mode。
5. 选择该 iPhone 为运行目标，点击 Run。此时不要设置 `CODE_SIGNING_ALLOWED=NO`。

Apple 官方免费账号限制：最多 10 个 App ID、每个平台最多 3 台测试设备、每台设备最多 3 个 App；免费描述文件有效期 7 天，过期后需要重新构建和安装。高级 capability 需逐项核对资格。

## 安全及成本边界

仓库只包含人工创建的示例源码、工程、测试、脚本与说明。无需上传 Apple Account、证书、私钥、描述文件或 GitHub 个人 Token。CI 使用 GitHub 自动提供的只读权限，checkout 不保留凭据。公开仓库请勿后续加入真实客户数据或本地账号配置。

GitHub 官方说明公开仓库使用标准 hosted runner 免费；本工作流选择标准 `macos-15`，不使用收费 larger runner。证据产物保留 7 天，下载后可自行留存。免费会员不代表有 Mac、设备等硬件成本。

## 官方依据

- [Apple 开发者账号与 Personal Team 限制](https://developer.apple.com/help/account/basics/about-your-developer-account/)
- [Apple 会员能力对照](https://developer.apple.com/support/compare-memberships/)
- [Xcode 系统要求](https://developer.apple.com/xcode/system-requirements/)
- [设备 Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
- [GitHub 标准 hosted runner](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

实际测试结果以 GitHub Actions run 和 `artifacts/result.txt` 为准；运行未成功前不能宣称已验证通过。
