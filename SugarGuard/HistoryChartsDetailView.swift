import SwiftUI
import Charts

struct HistoryChartsDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod = 0 // 0: 周, 1: 月
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("周期", selection: $selectedPeriod) {
                    Text("近7天").tag(0)
                    Text("近30天").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 血糖趋势大图
                VStack(alignment: .leading) {
                    Text("血糖波动趋势")
                        .font(.headline)
                    
                    if dataManager.records.isEmpty {
                        ContentUnavailableView("暂无数据", systemImage: "chart.xyaxis.line")
                            .frame(height: 250)
                    } else {
                        Chart {
                            ForEach(filteredRecords) { record in
                                LineMark(
                                    x: .value("日期", record.date, unit: .day),
                                    y: .value("血糖", record.value)
                                )
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("日期", record.date, unit: .day),
                                    y: .value("血糖", record.value)
                                )
                                .foregroundStyle(record.value > 10 ? .red : .blue)
                            }
                            
                            RuleMark(y: .value("高血糖线", 10.0))
                                .foregroundStyle(.red.opacity(0.3))
                        }
                        .frame(height: 300)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // 达标率饼图
                VStack(alignment: .leading) {
                    Text("血糖达标率")
                        .font(.headline)
                    
                    if dataManager.records.isEmpty {
                        Text("暂无数据")
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Chart(distributionData, id: \.name) { element in
                                SectorMark(
                                    angle: .value("数量", element.count),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("状态", element.name))
                            }
                            .frame(height: 200)
                            
                            VStack(alignment: .leading) {
                                ForEach(distributionData, id: \.name) { element in
                                    HStack {
                                        Circle()
                                            .fill(element.color)
                                            .frame(width: 10, height: 10)
                                        Text(element.name)
                                            .font(.caption)
                                        Text("\(element.count)次")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .navigationTitle("统计分析")
    }
    
    var filteredRecords: [GlucoseRecord] {
        let days = selectedPeriod == 0 ? 7 : 30
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        return dataManager.records.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }
    
    struct DistributionItem {
        let name: String
        let count: Int
        let color: Color
    }
    
    var distributionData: [DistributionItem] {
        let normal = filteredRecords.filter { $0.value >= 4.4 && $0.value <= 10.0 }.count
        let high = filteredRecords.filter { $0.value > 10.0 }.count
        let low = filteredRecords.filter { $0.value < 4.4 }.count
        
        return [
            DistributionItem(name: "正常", count: normal, color: .green),
            DistributionItem(name: "偏高", count: high, color: .red),
            DistributionItem(name: "偏低", count: low, color: .orange)
        ]
    }
}

#Preview {
    HistoryChartsDetailView()
        .environmentObject(DataManager())
}
