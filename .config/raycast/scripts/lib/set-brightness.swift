// macOS には内蔵ディスプレイ輝度の公開 API がない(Intel 時代の IODisplay API は
// Apple Silicon で動作しない)ため、私用フレームワーク DisplayServices を
// dlopen で呼ぶ。macOS 更新で壊れた場合はこのシンボル名の変更を疑う。
import CoreGraphics
import Foundation

guard CommandLine.arguments.count == 2,
    let value = Float(CommandLine.arguments[1]),
    (0.0...1.0).contains(value)
else {
    print("Error: usage: set-brightness <0.0-1.0>")
    exit(1)
}

let frameworkPath =
    "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices"
guard let handle = dlopen(frameworkPath, RTLD_NOW) else {
    print("Error: failed to load DisplayServices framework")
    exit(1)
}
guard let symbol = dlsym(handle, "DisplayServicesSetBrightness") else {
    print("Error: DisplayServicesSetBrightness not found")
    exit(1)
}

typealias SetBrightness = @convention(c) (CGDirectDisplayID, Float) -> Int32
let setBrightness = unsafeBitCast(symbol, to: SetBrightness.self)
guard setBrightness(CGMainDisplayID(), value) == 0 else {
    print("Error: failed to set brightness")
    exit(1)
}
print("Brightness \(value)")
