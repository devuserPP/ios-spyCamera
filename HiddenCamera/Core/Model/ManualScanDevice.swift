//
//  ManualScanDevice.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation

struct ManualScanDevice: Identifiable {
    var id: String
    var name: String
    var firstSeen: Date
    var lastSeen: Date
    var rssi: Double
    var isTrusted: Bool
    
    var displayName: String {
        name.isEmpty ? "Unknown" : name
    }
    
    var isPotentialRisk: Bool {
        return !isTrusted
    }
    
    init(id: String, name: String, rssi: Double, isTrusted: Bool, firstSeen: Date = Date(), lastSeen: Date = Date()) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.isTrusted = isTrusted
        self.firstSeen = firstSeen
        self.lastSeen = lastSeen
    }
    
    init(rlm: RlmManualScanDevice) {
        self.id = rlm.id
        self.name = rlm.name
        self.firstSeen = Date(timeIntervalSince1970: rlm.firstSeen)
        self.lastSeen = Date(timeIntervalSince1970: rlm.lastSeen)
        self.rssi = rlm.rssi
        self.isTrusted = rlm.isTrusted
    }
}
