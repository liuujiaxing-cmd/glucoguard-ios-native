import Foundation
import SwiftUI
import Combine
import Speech
import AVFoundation

class VoiceManager: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var errorMsg: String?
    
    override init() {
        super.init()
        requestPermission()
    }
    
    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("语音识别已授权")
                case .denied, .restricted, .notDetermined:
                    self.errorMsg = "请在设置中允许访问语音识别"
                @unknown default:
                    break
                }
            }
        }
    }
    
    func startRecording() throws {
        // 取消已有任务
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isRecording = false
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        try audioEngine.start()
        isRecording = true
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    // 从文本中提取数字 (简单解析)
    func extractGlucoseValue() -> Double? {
        // 例如："我刚测了血糖是五点六" -> 5.6
        // 正则匹配数字或中文数字
        let pattern = "(\\d+(\\.\\d+)?)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: recognizedText, range: NSRange(recognizedText.startIndex..., in: recognizedText)) {
            let range = Range(match.range, in: recognizedText)!
            return Double(recognizedText[range])
        }
        // 中文数字转换逻辑较复杂，暂只支持阿拉伯数字
        return nil
    }
}
