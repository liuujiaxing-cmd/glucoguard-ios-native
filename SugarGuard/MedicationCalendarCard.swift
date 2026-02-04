import SwiftUI

struct MedicationCalendarCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    // 获取本周日期
    var currentWeek: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
        return days
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("服药打卡 (本周)")
                    .font(.headline)
                Spacer()
                Image(systemName: "pill.fill")
                    .foregroundStyle(.blue)
            }
            .padding(.bottom, 10)
            
            if dataManager.medications.isEmpty {
                 Text("暂无药物，请去个人中心添加")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                HStack(spacing: 0) {
                    ForEach(currentWeek, id: \.self) { date in
                        VStack(spacing: 8) {
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            // 简单的打卡逻辑演示：如果是今天或过去，显示打卡状态
                            // 实际项目需要 MedicationRecord 模型来存储每天的打卡记录
                            // 这里仅演示 UI
                            ZStack {
                                Circle()
                                    .fill(isToday(date) ? Color.blue.opacity(0.2) : Color.clear)
                                    .frame(width: 32, height: 32)
                                
                                if isToday(date) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else if date < Date() {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.gray.opacity(0.3))
                                } else {
                                    Image(systemName: "circle.dotted")
                                        .foregroundStyle(.gray.opacity(0.3))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

#Preview {
    MedicationCalendarCard()
        .environmentObject(DataManager())
}
