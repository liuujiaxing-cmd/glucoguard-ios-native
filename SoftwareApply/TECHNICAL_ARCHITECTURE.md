# GlucoGuard 糖卫士 - 项目技术文档

## 1. 项目概述 (Project Overview)
**GlucoGuard 糖卫士** 是一款专为糖尿病患者设计的 iOS 原生健康管理应用。它采用**本地优先 (Local-First)** 架构，集成了 **AI 智能建议**、**OCR 图像识别** 和 **语音输入** 等先进技术，旨在为用户提供简单、高效且隐私安全的血糖管理体验。

本项目作为公益 App 系列的第一款产品，承诺不收集敏感隐私数据用于商业用途，核心功能完全离线可用。

## 2. 技术架构 (Technical Architecture)

### 2.1 架构图 (Architecture Diagram)

```mermaid
graph TD
    User[用户] --> UI[SwiftUI 界面层]
    
    subgraph "前端 (iOS Client)"
        UI --> VM[ViewModel / Logic]
        VM --> DM[DataManager (数据层)]
        
        subgraph "本地服务"
            DM --> CoreData[本地存储 (UserDefaults/File)]
            VM --> OCR[OCRService (Vision 框架)]
            VM --> Voice[VoiceManager (Speech 框架)]
        end
    end
    
    subgraph "外部服务 (仅联网时)"
        VM --> AI[AIService]
        AI --> LLM[DeepSeek API (大模型)]
        DM -.-> Cloud[CloudKit (可选同步)]
    end
```

### 2.2 核心技术栈
*   **语言**: Swift 5.0+
*   **UI 框架**: SwiftUI (MVVM 架构)
*   **AI 模型**: DeepSeek V3 (通过 REST API 调用)
*   **图像识别**: Apple Vision Framework (本地离线识别)
*   **语音识别**: Apple Speech Framework (本地/在线混合)
*   **数据存储**: Codable + JSON / UserDefaults (未来计划迁移至 SwiftData)

## 3. 功能模块详解 (Key Features)

### 3.1 智能记录 (Smart Logging)
*   **OCR 拍照**: 使用 `VNRecognizeTextRequest` 自动识别血糖仪屏幕上的数字，支持过滤干扰文本。
*   **语音输入**: 通过 `SFSpeechRecognizer` 实时将语音转为文字，并使用正则提取关键血糖数值。

### 3.2 AI 健康顾问 (AI Advisor)
*   **个性化建议**: 根据用户的年龄、糖尿病类型及最近 5 次血糖记录，构建 Prompt 发送给 DeepSeek 大模型。
*   **本地兜底**: 当网络不可用时，自动降级使用本地规则引擎（基于阈值判断）给出基础建议。

### 3.3 数据可视化 (Data Visualization)
*   **动态图表**: 使用 Swift Charts 绘制血糖趋势折线图，支持动态缩放和交互。
*   **统计分析**: 自动计算今日平均值、测量次数及达标率。

### 3.4 药物管理 (Medication)
*   **本地通知**: 利用 `UserNotifications` 框架实现准时的服药提醒。
*   **打卡日历**: 首页直观展示当日服药状态。

## 4. 目录结构说明 (Directory Structure)

```
SugarGuard/
├── App/
│   ├── SugarGuardApp.swift    // App 入口，环境对象注入
│   └── Theme.swift            // 全局配色与设计系统 (医疗蓝主题)
├── Views/
│   ├── DashboardView.swift    // 首页：概览卡片、AI建议、图表
│   ├── SmartLogView.swift     // 记录页：OCR、语音、表单输入
│   ├── HistoryView.swift      // 历史记录列表
│   ├── ProfileView.swift      // 个人中心、设置、关于我们
│   └── Components/            // 可复用组件
│       ├── GlucoseTrendChart.swift
│       ├── MedicationCalendarCard.swift
│       └── ImagePicker.swift
├── Services/
│   ├── AIService.swift        // 负责与 DeepSeek API 交互
│   ├── OCRService.swift       // 封装 Vision 框架的图片识别逻辑
│   └── VoiceManager.swift     // 封装 Speech 框架的录音与识别逻辑
├── Models/
│   ├── DataManager.swift      // 核心数据管理器 (单例)，负责 CRUD
│   └── DataManager+CloudKit.swift // CloudKit 同步扩展 (预留)
└── Resources/
    ├── Assets.xcassets        // 图片资源、App图标
    └── Info.plist             // 权限配置 (相机、麦克风、网络)
```

## 5. 开发指南 (Development Guide)

### 5.1 环境要求
*   Xcode 15.0+
*   iOS 16.0+ (使用了部分新 SwiftUI API)

### 5.2 快速开始
1.  克隆仓库到本地。
2.  在 `AIService.swift` 中填入你的 DeepSeek API Key (已配置)。
3.  选择模拟器 (iPhone 15 Pro) 运行。
4.  注意：真机调试需要 Apple 开发者账号签名。

### 5.3 常见问题
*   **API 调用失败**: 检查网络连接，或确认 API Key 是否过期。
*   **OCR 识别不准**: 尽量保持环境光线充足，且血糖仪屏幕无反光。

## 6. 版本规划 (Roadmap)
详情请见 [VERSION_HISTORY.md](../InformationAndVersion/VERSION_HISTORY.md)。
