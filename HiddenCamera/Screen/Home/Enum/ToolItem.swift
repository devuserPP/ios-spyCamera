//
//  ToolItem.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation
import SwiftUI

enum ToolItem: String, CaseIterable {
    case bluetoothScanner
    case wifiScanner
    case cameraDetector
    case infraredCamera
    case magnetic
    
    var symbolName: String {
        switch self {
        case .bluetoothScanner:
            "dot.radiowaves.left.and.right"
        case .cameraDetector:
            "viewfinder.circle"
        case .infraredCamera:
            "eye.circle"
        case .magnetic:
            "waveform.path"
        case .wifiScanner:
            "wifi"
        }
    }
    
    var name: String {
        switch self {
        case .bluetoothScanner:
            "Bluetooth Locator"
        case .cameraDetector:
            "AI Camera Scanner"
        case .infraredCamera:
            "IR Vision Camera"
        case .magnetic:
            "Magnetometer"
        case .wifiScanner:
            "Wifi Devices Finder"
        }
    }
    
    var color: Color {
        switch self {
        case .bluetoothScanner:
            Color.app(.main)
        case .cameraDetector:
            Color(rgb: 0x9747FF)
        case .infraredCamera:
            Color(rgb: 0x0CDC08)
        case .magnetic:
            Color(rgb: 0xFF4242)
        case .wifiScanner:
            Color(rgb: 0xFFA63D)
        }
    }
    
    var description: String {
        switch self {
        case .bluetoothScanner:
            "Locate bluetooth devices around you"
        case .wifiScanner:
            "Find all devices on your wifi"
        case .cameraDetector:
            "Detects hidden cameras with AI tool"
        case .magnetic:
            "Detect spy cam via magnetic sensor"
        case .infraredCamera:
            "Effortlessly spot infrared cameras"
        }
    }
}
