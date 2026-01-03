import Foundation
import AVFoundation

// デリゲート（終了処理に必要）
class RecorderDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    let session: AVCaptureSession
    
    init(session: AVCaptureSession) {
        self.session = session
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        session.stopRunning()
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("File saved to: \(outputFileURL.path)")
        }
        exit(error == nil ? 0 : 1)
    }
}

// --- 設定 ---
let saveDirectory = NSString(string: "~/Downloads").expandingTildeInPath
let args = CommandLine.arguments
let provided = args.count > 1 ? args[1] : nil
let safeName = provided?.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "-")
let dateString = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
let fileName = "rec_\(safeName ?? dateString).m4a"
let fileURL = URL(fileURLWithPath: "\(saveDirectory)/\(fileName)")

try? FileManager.default.createDirectory(atPath: saveDirectory, withIntermediateDirectories: true)

// --- デバイスの選択 ---
let session = AVCaptureSession()

// 利用可能なオーディオデバイスを取得
let discoverySession = AVCaptureDevice.DiscoverySession(
    deviceTypes: [.microphone, .external], // Bluetoothはexternal扱いが多い
    mediaType: .audio,
    position: .unspecified
)

let devices = discoverySession.devices
// Bluetoothまたは外部マイクを優先して探す
let selectedDevice = devices.first { $0.localizedName.contains("Bluetooth") || !$0.isSuspended } 
                     ?? AVCaptureDevice.default(for: .audio)

guard let inputDevice = selectedDevice else {
    print("Error: No audio device found.")
    exit(1)
}

print("Using device: \(inputDevice.localizedName)")

do {
    let input = try AVCaptureDeviceInput(device: inputDevice)
    if session.canAddInput(input) { session.addInput(input) }
    
    let output = AVCaptureAudioFileOutput()
    if session.canAddOutput(output) { session.addOutput(output) }
    
    let delegate = RecorderDelegate(session: session)
    
    session.startRunning()
    output.startRecording(
        to: fileURL,
        outputFileType: .m4a,
        recordingDelegate: delegate
    )
    
    print("Recording started... (Press Ctrl+C to stop)")
    print("Output: \(fileURL.path)")
    
    // シグナルハンドリング (Ctrl+C と kill コマンド両対応)
    let stopHandler: @convention(c) (Int32) -> Void = { _ in
        print("\nStopping recording...")
        if let output = session.outputs.first as? AVCaptureAudioFileOutput {
            output.stopRecording()
        }
    }
    signal(SIGINT, stopHandler)  // Ctrl+C
    signal(SIGTERM, stopHandler) // kill コマンド
    
    RunLoop.current.run()
} catch {
    print("Error setting up session: \(error)")
    exit(1)
}
