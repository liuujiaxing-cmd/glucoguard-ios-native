import SwiftUI

struct SmartLogView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var voiceManager = VoiceManager()
    @State private var glucoseValue: String = ""
    @State private var selectedDate = Date()
    @State private var notes: String = ""
    
    // 相机/OCR 相关
    @State private var showingCamera = false
    @State private var inputImage: UIImage?
    @State private var isRecognizing = false
    
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. 核心输入区 (大字号)
                    VStack(spacing: 16) {
                        Text("血糖数值")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            TextField("0.0", text: $glucoseValue)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primary)
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                                .frame(height: 80)
                            
                            Text("mmol/L")
                                .font(.title3)
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.bottom, 12)
                        }
                        
                        Divider()
                        
                        DatePicker("测量时间", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                            .tint(AppTheme.primary)
                    }
                    .modernCard()
                    
                    // 2. 智能输入区 (按钮组)
                    HStack(spacing: 16) {
                        // 拍照按钮
                        Button(action: { showingCamera = true }) {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 32))
                                Text(isRecognizing ? "识别中..." : "拍照识别")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(AppTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(AppTheme.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isRecognizing)
                        .buttonStyle(ScaleButtonStyle())
                        
                        // 语音按钮
                        Button(action: {
                            if voiceManager.isRecording {
                                voiceManager.stopRecording()
                                if let value = voiceManager.extractGlucoseValue() {
                                    glucoseValue = String(value)
                                    notes = "语音备注: \(voiceManager.recognizedText)"
                                }
                            } else {
                                try? voiceManager.startRecording()
                            }
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: voiceManager.isRecording ? "waveform" : "mic.fill")
                                    .font(.system(size: 32))
                                    .symbolEffect(.variableColor, isActive: voiceManager.isRecording)
                                Text(voiceManager.isRecording ? "停止录音" : "语音记录")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(voiceManager.isRecording ? AppTheme.danger : AppTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(voiceManager.isRecording ? AppTheme.danger.opacity(0.1) : AppTheme.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    
                    if !voiceManager.recognizedText.isEmpty {
                        Text(voiceManager.recognizedText)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal)
                    }
                    
                    // 3. 备注区
                    VStack(alignment: .leading, spacing: 12) {
                        Text("备注 (可选)")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden) // 去掉默认灰色背景
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .modernCard()
                    
                    Spacer(minLength: 20)
                    
                    // 4. 保存按钮
                    Button(action: saveRecord) {
                        Text("保存记录")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryGradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AppTheme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("新记录")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $inputImage)
            }
            .onChange(of: inputImage) { _, newImage in
                if let image = newImage {
                    isRecognizing = true
                    OCRService.shared.recognizeText(from: image) { value in
                        isRecognizing = false
                        if let val = value {
                            glucoseValue = String(val)
                        } else {
                            notes = "OCR 识别失败，请手动输入"
                        }
                    }
                }
            }
            .alert("请输入有效的血糖数值", isPresented: $showAlert) {
                Button("好", role: .cancel) { }
            }
        }
    }
    
    private func saveRecord() {
        guard let value = Double(glucoseValue) else {
            showAlert = true
            return
        }
        
        let newRecord = GlucoseRecord(
            value: value,
            date: selectedDate,
            type: GlucoseRecord.determineType(from: selectedDate),
            note: notes
        )
        
        dataManager.addRecord(newRecord)
        
        // 重置表单
        glucoseValue = ""
        notes = ""
        selectedDate = Date()
        
        dismiss()
    }
}

#Preview {
    SmartLogView()
        .environmentObject(DataManager())
}
