# App Store 审核反馈记录 (Review History)

本文档用于记录 App Store 审核过程中的拒稿原因及解决方案，作为后续迭代的避坑指南。

## 预设常见拒稿原因 (Pre-Check)

### 1. Guideline 2.1 - Performance (App Completeness)
*   **风险点**: 如果 AI 接口（DeepSeek）因为欠费或网络问题导致 App 崩溃或无响应。
*   **对策**: 我们已在代码中增加了本地兜底逻辑（Local Fallback），断网也能显示基础建议。

### 2. Guideline 5.1.1 - Data Collection and Storage
*   **风险点**: 申请了相机/麦克风权限，但在 App 里没有明确告诉用户为什么要用。
*   **对策**: `Info.plist` 已填写详细的 Usage Description ("用于拍摄血糖仪..." / "用于语音记录...")。

### 3. Guideline 4.2 - Minimum Functionality
*   **风险点**: App 功能过于简单，只是一个简单的记事本。
*   **对策**: 我们强调了 OCR、AI 分析和图表功能，体现了 App 的技术含量。

---

## 审核记录 (真实记录)

### Submission 1 (v1.0.0 Build 1)
*   **提交日期**: 2024-02-04
*   **状态**: *Waiting for Review*
*   **反馈**: (待更新)
    *   *如果通过*: ✅ Ready for Sale
    *   *如果被拒*: ❌ (记录拒稿条款和修改方案)

---
*模板说明：每次提交审核后，请在此处追加记录。*
