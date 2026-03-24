import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var isLoggedIn = false
    @State private var showLoginAlert = false
    @State private var notificationsEnabled = true
    @State private var targetHigh: Double = 10.0
    @State private var targetLow: Double = 4.4
    @AppStorage("hasAgreedToAIDataSharing") private var hasAgreedToAIDataSharing = false
    
    // 药物添加状态
    @State private var showingAddMedication = false
    @State private var newMedName = ""
    @State private var newMedDosage = ""
    @State private var newMedTime = Date()
    
    var body: some View {
        NavigationStack {
            List {
                // 用户信息部分
                Section("个人信息") {
                    HStack {
                        Image(systemName: isLoggedIn ? "person.circle.fill" : "person.crop.circle.badge.question")
                            .font(.system(size: 60))
                            .foregroundStyle(isLoggedIn ? .blue : .gray)
                        VStack(alignment: .leading) {
                            Text(isLoggedIn ? "用户 8802" : "未登录")
                                .font(.headline)
                            if !isLoggedIn {
                                Button("点击登录同步数据") {
                                    // 模拟登录
                                    isLoggedIn = true
                                    showLoginAlert = true
                                }
                                .font(.caption)
                                .foregroundStyle(.blue)
                            } else {
                                Button("退出登录") {
                                    isLoggedIn = false
                                }
                                .font(.caption)
                                .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // 药物管理部分
                Section("药物管理") {
                    ForEach(dataManager.medications) { med in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(med.name)
                                    .font(.headline)
                                Text(med.dosage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(med.time.formatted(date: .omitted, time: .shortened))
                                .font(.subheadline)
                            
                            Toggle("", isOn: Binding(
                                get: { med.isEnabled },
                                set: { _ in dataManager.toggleMedication(med) }
                            ))
                            .labelsHidden()
                        }
                    }
                    .onDelete { indexSet in
                        dataManager.deleteMedication(at: indexSet)
                    }
                    
                    Button(action: { showingAddMedication = true }) {
                        Label("添加药物", systemImage: "plus")
                    }
                }
                
                Section("数据管理") {
                    ShareLink(item: dataManager.exportCSV(), preview: SharePreview("导出血糖数据.csv")) {
                        Label("导出所有数据 (CSV)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        dataManager.syncToCloudKit()
                    }) {
                        Label("立即备份到 iCloud", systemImage: "icloud.and.arrow.up")
                    }
                }
                
                Section("血糖目标") {
                    HStack {
                        Text("最高值")
                        Spacer()
                        TextField("10.0", value: $targetHigh, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("最低值")
                        Spacer()
                        TextField("4.4", value: $targetLow, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }
                
                Section("隐私与安全") {
                    Toggle("允许 AI 健康建议数据分析", isOn: $hasAgreedToAIDataSharing)
                        .font(.subheadline)
                    
                    if hasAgreedToAIDataSharing {
                        Text("开启后，您的基础身体数据和近期血糖记录将被发送至第三方提供商(DeepSeek)用于生成个性化建议。")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Link("查看隐私政策", destination: URL(string: "https://github.com/liuujiaxing-cmd/glucoguard-ios-native/blob/main/InformationAndVersion/PRIVACY_POLICY.md")!)
                        .font(.subheadline)
                }
                
                Section("关于我们") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("GlucoGuard 糖卫士 是一款致力于公益的健康管理应用。")
                            .font(.subheadline)
                            .bold()
                        
                        Text("我们的初心是利用科技帮助糖尿病患者更轻松地生活。为了维系项目的持续开发和服务器成本，应用内可能会包含少量非侵入式广告，感谢您的理解与支持。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("本项目承诺不收集任何敏感隐私数据用于商业用途。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Link("访问官网 (技术支持)", destination: URL(string: "https://github.com/liuujiaxing-cmd/glucoguard-support")!)
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("个人中心")
            .sheet(isPresented: $showingAddMedication) {
                NavigationStack {
                    Form {
                        TextField("药物名称 (如: 二甲双胍)", text: $newMedName)
                        TextField("剂量 (如: 0.5g)", text: $newMedDosage)
                        DatePicker("服用时间", selection: $newMedTime, displayedComponents: .hourAndMinute)
                    }
                    .navigationTitle("添加药物")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") { showingAddMedication = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                let newMed = Medication(name: newMedName, dosage: newMedDosage, time: newMedTime)
                                dataManager.addMedication(newMed)
                                showingAddMedication = false
                                // Reset
                                newMedName = ""
                                newMedDosage = ""
                            }
                            .disabled(newMedName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .alert("登录成功", isPresented: $showLoginAlert) {
                Button("好", role: .cancel) { }
            } message: {
                Text("您的数据已开始云端同步。")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataManager())
}
