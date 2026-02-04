import SwiftUI
import Charts

struct GlucoseTrendChart: View {
    @EnvironmentObject var dataManager: DataManager
    
    // 过滤最近7天的数据
    var recentRecords: [GlucoseRecord] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return dataManager.records.filter { $0.date >= oneWeekAgo }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("血糖趋势 (近7天)")
                .font(.headline)
                .padding(.bottom, 5)
            
            if recentRecords.isEmpty {
                ContentUnavailableView("暂无数据", systemImage: "chart.xyaxis.line")
                    .frame(height: 200)
            } else {
                Chart {
                    ForEach(recentRecords) { record in
                        LineMark(
                            x: .value("时间", record.date),
                            y: .value("血糖", record.value)
                        )
                        .foregroundStyle(record.value > 10 ? .red : .blue)
                        .symbol(by: .value("类型", record.value > 10 ? "偏高" : "正常"))
                        
                        PointMark(
                            x: .value("时间", record.date),
                            y: .value("血糖", record.value)
                        )
                        .foregroundStyle(record.value > 10 ? .red : .blue)
                    }
                    
                    // 正常范围辅助线
                    RuleMark(y: .value("上限", 10.0))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .annotation(position: .leading) { Text("10.0").font(.caption2).foregroundStyle(.secondary) }
                        
                    RuleMark(y: .value("下限", 4.4))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .annotation(position: .leading) { Text("4.4").font(.caption2).foregroundStyle(.secondary) }
                }
                .frame(height: 220)
                .chartYScale(domain: 0...20)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    GlucoseTrendChart()
        .environmentObject(DataManager())
}
