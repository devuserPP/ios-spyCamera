//
//  ManualScanEvent.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation

struct ManualScanEvent: Identifiable {
    var id: String
    var deviceId: String
    var timestamp: Date
    var rssi: Double
    
    init(deviceId: String, timestamp: Date = Date(), rssi: Double) {
        self.id = UUID().uuidString
        self.deviceId = deviceId
        self.timestamp = timestamp
        self.rssi = rssi
    }
    
    init(rlm: RlmManualScanEvent) {
        self.id = rlm.id
        self.deviceId = rlm.deviceId
        self.timestamp = Date(timeIntervalSince1970: rlm.timestamp)
        self.rssi = rlm.rssi
    }
}
