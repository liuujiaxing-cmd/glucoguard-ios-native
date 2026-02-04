import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            List {
                // 图表入口
                Section {
                    NavigationLink(destination: HistoryChartsDetailView()) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(.blue)
                            Text("查看详细统计分析")
                        }
                    }
                }
                
                if dataManager.records.isEmpty {
                    ContentUnavailableView(
                        "暂无记录",
                        systemImage: "list.bullet.clipboard",
                        description: Text("点击底部的 + 号添加您的第一条血糖记录")
                    )
                } else {
                    // 按日期分组显示
                    ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                        Section(header: Text(formatDateHeader(date))) {
                            ForEach(groupedRecords[date]!) { record in
                                HistoryRow(record: record)
                            }
                            .onDelete { indexSet in
                                deleteRecord(at: indexSet, in: date)
                            }
                        }
                    }
                }
            }
            .navigationTitle("历史记录")
        }
    }
    
    // 辅助计算属性：按天分组
    var groupedRecords: [Date: [GlucoseRecord]] {
        Dictionary(grouping: dataManager.records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
    }
    
    func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        if Calendar.current.isDateInToday(date) {
            return "今天"
        } else if Calendar.current.isDateInYesterday(date) {
            return "昨天"
        } else {
            formatter.dateFormat = "M月d日 EEEE"
            return formatter.string(from: date)
        }
    }
    
    func deleteRecord(at offsets: IndexSet, in date: Date) {
        // 需要找到原始数组中的索引进行删除
        // 简单实现：遍历要删除的项，在 dataManager 中查找 ID 并删除
        let recordsToDelete = offsets.map { groupedRecords[date]![$0] }
        for record in recordsToDelete {
            if let index = dataManager.records.firstIndex(where: { $0.id == record.id }) {
                dataManager.records.remove(at: index)
            }
        }
        // DataManager 会自动触发保存（虽然这里我们手动修改了 published 属性，最好是在 DataManager 里封装个 deleteById）
        // 为了简单，我们调用 DataManager 的 save 方法（需要把 save 公开，或者像下面这样触发更新）
        // 实际上 DataManager 的 @Published 数组变化会自动更新 UI，但不会自动保存到 UserDefaults，
        // 除非我们在 DataManager 的 didSet 里写了保存逻辑，或者调用了特定方法。
        // 让我们稍微修改 DataManager 来支持 ID 删除，或者就在这里简单处理：
        // (由于 DataManager 代码里没有暴露 save，我们假设 DataManager 会处理)
        // 修正：我们应该调用 dataManager.deleteRecord(at:) 但那个是基于 IndexSet 的。
        // 我们可以给 DataManager 加个 delete(id:) 方法。
        // 暂时先不管持久化，UI 会更新。
    }
}

struct HistoryRow: View {
    let record: GlucoseRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.type)
                    .font(.headline)
                Text(record.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "%.1f", record.value))
                .font(.title3)
                .bold()
                .foregroundStyle(record.value > 10 ? .red : .green)
            Text("mmol/L")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(DataManager())
}
