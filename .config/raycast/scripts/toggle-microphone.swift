// AppleScript の input volume はマスターチャンネルの音量しか扱えず、
// USB EarPods のようにマスターミュートのみを持つデバイスでは
// missing value が返るため、CoreAudio のマスターミュートを直接操作する。
import CoreAudio
import Foundation

var deviceID = AudioDeviceID(0)
var size = UInt32(MemoryLayout<AudioDeviceID>.size)
var defaultAddr = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultInputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain)
guard AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject), &defaultAddr, 0, nil, &size, &deviceID) == noErr,
    deviceID != 0
else {
    print("Error: no default input device")
    exit(1)
}

var muteAddr = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyMute,
    mScope: kAudioDevicePropertyScopeInput,
    mElement: kAudioObjectPropertyElementMain)
guard AudioObjectHasProperty(deviceID, &muteAddr) else {
    print("Error: input device has no mute control")
    exit(1)
}

var muted = UInt32(0)
var muteSize = UInt32(MemoryLayout<UInt32>.size)
guard AudioObjectGetPropertyData(deviceID, &muteAddr, 0, nil, &muteSize, &muted) == noErr else {
    print("Error: failed to read mute state")
    exit(1)
}

var newValue: UInt32 = muted == 0 ? 1 : 0
guard AudioObjectSetPropertyData(deviceID, &muteAddr, 0, nil, muteSize, &newValue) == noErr else {
    print("Error: failed to set mute state")
    exit(1)
}

print(newValue == 1 ? "Mute" : "Unmute")
