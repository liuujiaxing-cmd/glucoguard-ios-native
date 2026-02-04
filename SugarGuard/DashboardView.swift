import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var aiAdvice: String = "正在分析您的健康数据..."
    @State private var isAnalyzing = false
    @State private var showingMedicationSheet = false
    @State private var showingQuickLog = false // 快速记录 Sheet
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 自定义 Header
                    VStack(spacing: 8) {
                        Text("GlucoGuard")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("愿您今天的血糖平稳，心情如阳光般灿烂 ☀️")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // 今日摘要卡片
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("今日概览")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textSecondary)
                            Spacer()
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("平均血糖")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text(String(format: "%.1f", dataManager.todayAverage))
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundStyle(dataManager.todayAverage > 10 ? AppTheme.warning : AppTheme.primary)
                                    Text("mmol/L")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .padding(.bottom, 6)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 1, height: 40)
                                .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("测量次数")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(dataManager.todayCount)")
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.success)
                                    Text("次")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .padding(.bottom, 6)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .modernCard()
                    
                    // AI 建议卡片 (高级渐变风格)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title3)
                            Text("AI 健康建议")
                                .font(.headline)
                            Spacer()
                            if isAnalyzing {
                                ProgressView()
                                    .tint(.white)
                                    .controlSize(.small)
                            } else {
                                Button(action: refreshAdvice) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                        .padding(6)
                                        .background(.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .foregroundStyle(.white)
                        
                        Text(aiAdvice)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.white.opacity(0.95))
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.primaryGradient) // 使用渐变背景
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 4)
                    .onAppear {
                        if aiAdvice == "正在分析您的健康数据..." {
                            refreshAdvice()
                        }
                    }
                    
                    // 趋势图表
                    GlucoseTrendChart()
                        .modernCard() // 应用统一卡片样式
                    
                    // 药物打卡
                    VStack(spacing: 0) {
                        MedicationCalendarCard()
                        
                        Button(action: { showingMedicationSheet = true }) {
                            HStack(spacing: 4) {
                                Text("管理药物计划")
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primary)
                            .padding(.top, 12)
                        }
                    }
                    .modernCard()
                    
                    // 最近记录
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("最近记录")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                        }
                        
                        if dataManager.records.isEmpty {
                            ContentUnavailableView("暂无数据", systemImage: "list.bullet.clipboard")
                                .frame(height: 100)
                        } else {
                            ForEach(dataManager.records.prefix(3)) { record in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(record.type)
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(AppTheme.textPrimary)
                                        Text(record.date.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text(String(format: "%.1f", record.value))
                                        .font(.system(.title3, design: .rounded))
                                        .bold()
                                        .foregroundStyle(record.value > 10 ? AppTheme.warning : AppTheme.success)
                                }
                                .padding(.vertical, 8)
                                if record.id != dataManager.records.prefix(3).last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .modernCard()
                }
                .padding()
            }
            // .navigationTitle("GlucoGuard") // 移除原生标题
            .toolbar(.hidden, for: .navigationBar) // 隐藏原生导航栏
            .background(AppTheme.background.ignoresSafeArea()) // 全局背景色
            .sheet(isPresented: $showingMedicationSheet) {
                MedicationManagerSheet()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingQuickLog) {
                SmartLogView()
            }
        }
    }
    
    private func refreshAdvice() {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        aiAdvice = "正在思考中..."
        
        Task {
            do {
                let advice = try await AIService.shared.generateHealthAdvice(
                    records: dataManager.records,
                    profile: dataManager.userProfile
                )
                await MainActor.run {
                    self.aiAdvice = advice
                    self.isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    self.aiAdvice = "网络开小差了，暂时无法获取建议。"
                    self.isAnalyzing = false
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
}
