import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataManager: DataManager
    
    // 步骤控制
    @State private var currentStep = 0
    
    // 收集的数据
    @State private var age = ""
    @State private var gender = "男"
    @State private var diabetesType = "2型糖尿病"
    @State private var medicationStatus = "口服药"
    @State private var lastGlucose = ""
    
    let genders = ["男", "女", "其他"]
    let types = ["1型糖尿病", "2型糖尿病", "妊娠糖尿病", "糖尿病前期", "未确诊/关注健康"]
    let medications = ["口服药", "胰岛素", "口服+胰岛素", "仅饮食控制", "无/未治疗"]
    
    var body: some View {
        NavigationStack {
            VStack {
                // 进度条
                ProgressView(value: Double(currentStep), total: 3)
                    .padding()
                
                TabView(selection: $currentStep) {
                    // Step 0: 欢迎
                    VStack(spacing: 20) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                            .padding(.top, 40)
                        
                        Text("欢迎来到 SugarGuard")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("为了给您提供更精准的健康建议，我们需要了解一些基本情况。")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding()
                            
                        Spacer()
                        
                        Text("免责声明：本应用提供的所有健康建议和数据分析均基于通用医疗指南，仅供日常健康管理参考，不构成专业的医疗诊断或治疗建议。使用本应用时，请务必听从专业医生的指导。")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                    }
                    .tag(0)
                    
                    // Step 1: 基本信息
                    VStack(spacing: 20) {
                        Text("基本信息")
                            .font(.title)
                            .bold()
                        
                        Form {
                            Section("年龄") {
                                TextField("请输入年龄", text: $age)
                                    .keyboardType(.numberPad)
                            }
                            
                            Section("性别") {
                                Picker("性别", selection: $gender) {
                                    ForEach(genders, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    .tag(1)
                    
                    // Step 2: 病情与用药
                    VStack(spacing: 20) {
                        Text("健康状况")
                            .font(.title)
                            .bold()
                        
                        Form {
                            Section("糖尿病类型") {
                                Picker("类型", selection: $diabetesType) {
                                    ForEach(types, id: \.self) { Text($0) }
                                }
                            }
                            
                            Section("目前的治疗方式") {
                                Picker("治疗", selection: $medicationStatus) {
                                    ForEach(medications, id: \.self) { Text($0) }
                                }
                            }
                            
                            Section("最近一次测量的血糖 (选填)") {
                                TextField("mmol/L", text: $lastGlucose)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep) // 丝滑的弹簧动画
                .transition(.slide)
                
                // 底部按钮区
                HStack {
                    if currentStep > 0 {
                        Button("上一步") {
                            currentStep -= 1
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == 2 ? "完成" : "下一步") {
                        if currentStep < 2 {
                            currentStep += 1
                        } else {
                            completeOnboarding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("跳过") {
                        isPresented = false
                    }
                }
            }
        }
        .interactiveDismissDisabled() // 禁止下拉关闭，必须点完成或跳过
    }
    
    private func completeOnboarding() {
        // 保存用户画像
        var profile = UserProfile()
        profile.age = age
        profile.gender = gender
        profile.diabetesType = diabetesType
        profile.medicationStatus = medicationStatus
        if let glucose = Double(lastGlucose) {
            profile.lastKnownGlucose = glucose
            // 可选：如果填了血糖，自动帮他记一笔
            let record = GlucoseRecord(value: glucose, date: Date(), type: "首次记录", note: "引导页录入")
            dataManager.addRecord(record)
        }
        
        dataManager.updateUserProfile(profile)
        isPresented = false
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(DataManager())
}
