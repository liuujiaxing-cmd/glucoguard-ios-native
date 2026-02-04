import Foundation
import SwiftUI
import Combine

struct GlucoseRecord: Identifiable, Codable {
    var id = UUID()
    var value: Double
    var date: Date
    var type: String // e.g., "空腹", "早餐后" - 保留此字段作为标签，但主要逻辑依赖时间
    var note: String
    
    // 简单的时段判断逻辑
    static func determineType(from date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<9: return "早餐段"
        case 11..<14: return "午餐段"
        case 17..<20: return "晚餐段"
        default: return "其他"
        }
    }
}

struct Medication: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dosage: String
    var time: Date
    var isEnabled: Bool = true
}

struct UserProfile: Codable {
    var age: String = ""
    var gender: String = "未选择" // 男, 女, 其他
    var diabetesType: String = "未选择" // 1型, 2型, 妊娠, 前期
    var medicationStatus: String = "未选择" // 口服药, 胰岛素, 饮食控制, 联合治疗
    var lastKnownGlucose: Double?
}

class DataManager: ObservableObject {
    @Published var records: [GlucoseRecord] = []
    @Published var medications: [Medication] = []
    @Published var userProfile: UserProfile = UserProfile()
    
    private let recordsKey = "glucose_records"
    private let medicationsKey = "medications"
    private let profileKey = "user_profile"
    
    init() {
        loadData()
    }
    
    func addRecord(_ record: GlucoseRecord) {
        records.insert(record, at: 0) // 最新在最前
        saveRecords()
    }
    
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveRecords()
    }
    
    func addMedication(_ med: Medication) {
        medications.append(med)
        saveMedications()
    }
    
    func deleteMedication(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
        saveMedications()
    }
    
    func toggleMedication(_ med: Medication) {
        if let index = medications.firstIndex(where: { $0.id == med.id }) {
            medications[index].isEnabled.toggle()
            saveMedications()
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        saveUserProfile()
    }
    
    private func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    private func saveMedications() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: medicationsKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([GlucoseRecord].self, from: data) {
            records = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: medicationsKey),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
    
    // 获取今日平均血糖
    var todayAverage: Double {
        let today = Calendar.current.startOfDay(for: Date())
        let todayRecords = records.filter { $0.date >= today }
        guard !todayRecords.isEmpty else { return 0.0 }
        let sum = todayRecords.reduce(0) { $0 + $1.value }
        return sum / Double(todayRecords.count)
    }
    
    // 获取今日测量次数
    var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return records.filter { $0.date >= today }.count
    }
}
