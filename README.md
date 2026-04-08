# TicketSave / 脱口秀票根收藏

一款面向脱口秀演员与演出创作者的 iOS 原生档案馆应用，用来持续收藏、整理和回看自己的演出记录。

项目代号：`XYSG`  
当前技术栈：`SwiftUI + SwiftData + PhotosPicker + 本地 ZIP 备份`

## 项目定位

这不是一款“后台录入工具”，而是一款偏收藏与回看体验的个人演出档案馆。

核心目标：

- 记录自己出演过的每一场演出
- 为每场演出生成一张高质量数字票卡
- 长期积累演员、厂牌、场地等结构化档案
- 保留后续扩展统计系统与成就系统的空间

## 当前功能

### 演出档案

- 新增、编辑、删除演出
- 首页档案流展示演出卡片
- 按内容形式、厂牌筛选
- 详情页查看完整演出信息
- 备注支持编辑与保存

### 结构化实体

- 演员、厂牌、场地均为独立实体
- 实体管理页支持新增与编辑
- 实体之间支持手动关联
- 演出录入时复用已有实体

### 视觉与交互

- 深色与亮色双主题
- 支持 `亮色 / 暗色 / 跟随系统`
- 首页、详情页、设置中心采用玻璃质感与渐变层次
- 常用操作包含细腻触感反馈

### 本地数据安全

- 图片导入后写入 app 沙盒，不依赖系统相册原图
- 支持导出本地 ZIP 备份
- 支持从 ZIP 备份恢复
- 备份格式带版本信息，尽量兼容未来字段扩展

## 页面结构

### Archive

- 演出统计摘要
- 筛选栏
- 演出卡片列表
- 首页右上角新增演出

### 演出详情

- 通栏封面 Hero
- 主信息卡
- 三张关键信息卡
- 更多资料
- 演员阵容
- 备注

### 设置中心

- 外观模式切换
- 实体管理入口
- 本地备份入口

## 目录结构

```text
xysg/
├── Packages/
│   ├── Sources/XYSGCore/      # 核心模型、展示逻辑、备份格式、测试辅助
│   └── Tests/XYSGCoreTests/   # 核心单元测试
├── XYSG/
│   ├── App/                   # App 启动、导航、设置中心
│   ├── Data/                  # SwiftData 模型、服务、备份映射
│   ├── DesignSystem/          # 颜色、卡片、按钮、主题组件
│   ├── Features/              # Archive / Composer / Detail / Catalog / More
│   ├── Resources/             # 资源与图标
│   └── Shared/                # 共享能力，如 Haptics
├── XYSG.xcodeproj
└── project.yml
```

## 开发环境

- Xcode 26+
- iOS 26 Simulator / 真机
- Swift 6

## 本地运行

```bash
xcodebuild -project XYSG.xcodeproj -scheme XYSG -destination 'generic/platform=iOS Simulator' build
```

核心包测试：

```bash
cd Packages
swift test
```

## 文档索引

- [产品需求文档](./docs/PRD.md)
- [设计文档](./docs/设计文档.md)
- [技术文档](./docs/技术文档.md)

## 当前状态

当前版本已经具备可用 MVP：

- 首页档案流
- 演出录入与详情
- 实体管理
- 亮暗主题切换
- 本地 ZIP 备份恢复

后续可以继续扩展：

- 统计页
- 成就系统
- 更多实体信息维度
- 更丰富的分享与导出能力
