import SwiftUI

struct MedicationManagerSheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    // 添加新药状态
    @State private var showingAddForm = false
    @State private var newMedName = ""
    @State private var newMedDosage = ""
    @State private var newMedTime = Date()
    
    var body: some View {
        NavigationStack {
            List {
                if dataManager.medications.isEmpty {
                    ContentUnavailableView(
                        "暂无药物计划",
                        systemImage: "pill",
                        description: Text("点击右上角添加您的第一个药物提醒")
                    )
                } else {
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
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
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
                }
            }
            .navigationTitle("药物管理")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddForm = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                NavigationStack {
                    Form {
                        TextField("药物名称 (如: 二甲双胍)", text: $newMedName)
                        TextField("剂量 (如: 0.5g)", text: $newMedDosage)
                        DatePicker("服用时间", selection: $newMedTime, displayedComponents: .hourAndMinute)
                    }
                    .navigationTitle("添加新药")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") { showingAddForm = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                let newMed = Medication(name: newMedName, dosage: newMedDosage, time: newMedTime)
                                dataManager.addMedication(newMed)
                                showingAddForm = false
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
        }
    }
}

#Preview {
    MedicationManagerSheet()
        .environmentObject(DataManager())
}
