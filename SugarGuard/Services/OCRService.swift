import Foundation
import Vision
import UIKit

class OCRService {
    static let shared = OCRService()
    
    func recognizeText(from image: UIImage, completion: @escaping (Double?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // 寻找最像血糖值的数字
            // 策略：找最大的数字，且范围在 1.0 - 33.3 之间
            var foundValue: Double?
            
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                let text = candidate.string
                
                // 简单的正则匹配：提取浮点数
                if let value = Double(text), value > 1.0, value < 35.0 {
                    foundValue = value
                    break // 找到一个就返回，通常屏幕上最大的就是读数
                }
            }
            
            DispatchQueue.main.async {
                completion(foundValue)
            }
        }
        
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
