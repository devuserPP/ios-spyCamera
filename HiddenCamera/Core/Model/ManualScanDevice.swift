//
//  ManualScanDevice.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation

enum ManualTrackerKind: String {
    case airtag
    case findMy
    case smarttag
    case tile
    case chipolo
    case google
    case pebblebee
    case findMyMobile
    case generic
    case unknown
    
    var displayName: String {
        switch self {
        case .airtag: return "Apple AirTag"
        case .findMy: return "Find My"
        case .smarttag: return "Samsung SmartTag"
        case .tile: return "Tile"
        case .chipolo: return "Chipolo"
        case .google: return "Google"
        case .pebblebee: return "Pebblebee"
        case .findMyMobile: return "Find My Mobile"
        case .generic: return "Bluetooth"
        case .unknown: return "Unknown"
        }
    }
}

struct ManualScanDevice: Identifiable {
    var id: String
    var name: String
    var firstSeen: Date
    var lastSeen: Date
    var rssi: Double
    var isTrusted: Bool
    var trackerKind: ManualTrackerKind
    var vendor: String
    var connectionStatus: ManualTrackerConnectionStatus
    var eventCount: Int
    
    var displayName: String {
        name.isEmpty ? "Unknown" : name
    }
    
    var isPotentialRisk: Bool {
        return !isTrusted && trackerKind != .generic && trackerKind != .unknown
    }
    
    init(id: String, name: String, rssi: Double, isTrusted: Bool, trackerKind: ManualTrackerKind, vendor: String, connectionStatus: ManualTrackerConnectionStatus, eventCount: Int = 0, firstSeen: Date = Date(), lastSeen: Date = Date()) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.isTrusted = isTrusted
        self.trackerKind = trackerKind
        self.vendor = vendor
        self.connectionStatus = connectionStatus
        self.eventCount = eventCount
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
        self.trackerKind = ManualTrackerKind(rawValue: rlm.type) ?? .unknown
        self.vendor = rlm.vendor
        self.connectionStatus = ManualTrackerConnectionStatus(rawValue: rlm.connectionStatus) ?? .unknown
        self.eventCount = rlm.eventCount
    }
}
