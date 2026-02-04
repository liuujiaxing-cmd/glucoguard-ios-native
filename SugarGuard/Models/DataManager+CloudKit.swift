import Foundation
import CloudKit

// 扩展 DataManager 以支持 CloudKit
extension DataManager {
    
    // 将数据导出为 CSV 字符串
    func exportCSV() -> String {
        var csv = "日期,时间,类型,血糖值(mmol/L),备注\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for record in records {
            let date = formatter.string(from: record.date)
            let time = timeFormatter.string(from: record.date)
            let line = "\(date),\(time),\(record.type),\(record.value),\(record.note)\n"
            csv.append(line)
        }
        return csv
    }
    
    // 模拟 CloudKit 同步 (简化版)
    // 真实 CloudKit 需要在 Xcode Capabilities 中开启 iCloud -> CloudKit
    // 并创建 CKRecord
    func syncToCloudKit() {
        // 这里仅演示逻辑，因为没有真实开启 Capability 会报错
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        
        // 假设我们把最新的记录上传
        if let lastRecord = records.first {
            let recordID = CKRecord.ID(recordName: lastRecord.id.uuidString)
            let ckRecord = CKRecord(recordType: "Glucose", recordID: recordID)
            ckRecord["value"] = lastRecord.value
            ckRecord["date"] = lastRecord.date
            
            database.save(ckRecord) { record, error in
                if let error = error {
                    print("CloudKit Error: \(error.localizedDescription)")
                } else {
                    print("Saved to iCloud!")
                }
            }
        }
    }
}
