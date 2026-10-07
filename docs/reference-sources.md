# 参考资料来源与项目适配

2026-10-07 从用户提供的 `ios-dev-20261007.zip` 择取两套文本 Skill，安装到本仓库 `.agents/skills/`。原包 SHA-256 为 `4047a9955f2800387d557b6027a3609254dfca479b64f842798d1a3ab7631ccf`。归档未记录上游提交，不能宣称等同于当前上游版本。

| 项目参考 | 归档记录的上游来源 | 许可 |
| --- | --- | --- |
| [swiftui-pro](../.agents/skills/swiftui-pro/SKILL.md) | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | [MIT，Paul Hudson 2026](../.agents/skills/swiftui-pro/LICENSE) |
| [ios-accessibility](../.agents/skills/ios-accessibility/SKILL.md) | [dadederk/iOS-Accessibility-Agent-Skill](https://github.com/dadederk/iOS-Accessibility-Agent-Skill) | [MIT，Daniel Devesa Derksen-Staats 2025](../.agents/skills/ios-accessibility/LICENSE.txt) |

保留全部 27 个参考/许可文件及原作者版权，9＋14 个 references 路径完整。每个文件的原归档哈希、适配后哈希与修改标记在 [reference-sources.json](reference-sources.json) 中。该记录便于确认本次适配范围，不替代技术正确性验证。

本次对 7 个文件作内容适配：两份 SKILL 入口；SwiftUI 的 api、data、accessibility 参考；无障碍的 testing-automated、dynamic-type-swiftui 参考。另外清理了 good-practices、voiceover-swiftui 参考中的行尾空白，共 9 个文件的哈希发生变化。主要改动：

- Claude 路径占位符改为相对 Skill 根目录引用，缩小入口描述，注明最低 iOS 18、SwiftUI、Linux 业务包与 macOS UI 测试的边界。
- API 建议遵循可用性与现有架构。直接使用 enumerated 集合需检查标准库和系统可用性，保留适当旧系统写法；依据 [Swift SE-0459](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0459-enumerated-collection.md)。没有为这个参考示例新增 App 代码或声称已实测编译失败。
- MainActor/Observable 按 UI 状态与实际隔离需求选择；自定义 Binding 用于转换、校验或代理状态时有效，不将风格偏好报告成缺陷。
- 图片按钮按有效无障碍标签评估，承认显式 accessibilityLabel，不要求一定包含 Text。
- 字号启动参数沿用当前已验证矩阵的 `UICTContentSizeCategoryAccessibilityXXXL`；去掉无测量口径的“30%/70%”覆盖率；上限示例改为范围，提示条件分支需验证状态保留。

在仓库目录启动 Codex，显式 `$swiftui-pro` 或 `$ios-accessibility` 可选择项目 Skill，也可根据任务描述匹配。项目级发现规则与更新方式参见 [官方 Codex 文档](https://learn.chatgpt.com/docs/build-skills)。本次不修改用户级 Skill 或 MCP 配置；历史 CLAUDE 文档、对话、旧设备/价格快照保留在仓库外。
