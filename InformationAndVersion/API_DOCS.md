# API 接口与数据定义文档 (API & Data Schema)

## 1. 外部 API 接口 (External APIs)

本项目目前主要依赖 **DeepSeek** 的大模型接口来提供 AI 健康建议。

### 1.1 AI 健康建议 (Health Advice)
*   **服务商**: DeepSeek
*   **接口地址**: `https://api.deepseek.com/v1/chat/completions`
*   **请求方式**: `POST`
*   **鉴权方式**: Bearer Token (API Key)

#### 请求参数 (Request Body)
```json
{
  "model": "deepseek-chat",
  "messages": [
    {
      "role": "user",
      "content": "你是一位专业的内分泌科医生助手... (包含脱敏后的患者年龄、性别、最近5次血糖记录)"
    }
  ],
  "temperature": 0.7
}
```

#### 响应参数 (Response)
```json
{
  "choices": [
    {
      "message": {
        "content": "您的血糖控制良好，建议继续保持..."
      }
    }
  ]
}
```

## 2. 本地数据模型 (Local Data Schema)

本项目采用 **Codable** 协议将数据序列化为 JSON 存储在 iOS 沙盒的 `Documents` 目录下。

### 2.1 血糖记录 (GlucoseRecord)
*   **存储文件**: `glucose_records.json`

| 字段名 | 类型 | 说明 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | UUID | 唯一标识符 | `E621E1F8-C36C-495A-93FC-0C247A3E6E5F` |
| `value` | Double | 血糖值 (mmol/L) | `5.6` |
| `date` | Date | 测量时间 | `2024-02-04T08:00:00Z` |
| `type` | String | 测量时段 | `"空腹"`, `"餐后2小时"` |
| `note` | String | 备注 (可选) | `"吃了一块蛋糕"` |

### 2.2 药物计划 (Medication)
*   **存储文件**: `medications.json`

| 字段名 | 类型 | 说明 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | UUID | 唯一标识符 | `...` |
| `name` | String | 药物名称 | `"二甲双胍"` |
| `dosage` | String | 服用剂量 | `"0.5g"` |
| `time` | Date | 提醒时间 | `08:00` |
| `isEnabled` | Bool | 开关状态 | `true` |

### 2.3 用户资料 (UserProfile)
*   **存储方式**: `UserDefaults` (轻量级存储)

| Key | 类型 | 说明 |
| :--- | :--- | :--- |
| `user_age` | Int | 用户年龄 |
| `user_gender` | String | 性别 |
| `diabetes_type` | String | 糖尿病类型 (1型/2型/妊娠) |
| `onboarding_completed` | Bool | 是否已完成新手引导 |
