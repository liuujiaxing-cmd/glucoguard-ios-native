import Foundation

class AIService {
    static let shared = AIService()
    
    // 替换为你的真实 API Key (为了演示，这里使用模拟请求，但结构是真实的)
    // 推荐使用 DeepSeek 或 MiniMax，性价比高
    private let apiKey = "sk-41d23cc4e0ba437ab0a87ccf43748ecb"
    private let apiURL = URL(string: "https://api.deepseek.com/v1/chat/completions")!
    
    func generateHealthAdvice(records: [GlucoseRecord], profile: UserProfile) async throws -> String {
        // 1. 构建 Prompt
        let recentRecords = records.prefix(5).map { "\($0.date.formatted()): \($0.value) \($0.type)" }.joined(separator: "; ")
        let prompt = """
        你是一位专业的内分泌科医生助手。
        患者资料：\(profile.age)岁，\(profile.gender)，\(profile.diabetesType)，正在使用\(profile.medicationStatus)。
        最近5次血糖记录：\(recentRecords)。
        
        请根据以上数据，给出一条简短、温暖且专业的健康建议（50字以内）。如果血糖异常，请提醒注意饮食或复查。
        """
        
        // 2. 真实网络请求
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [["role": "user", "content": prompt]],
            "temperature": 0.7
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // 解析 JSON
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        // 如果解析失败，回退到本地规则
        throw URLError(.cannotParseResponse)
    }
}
