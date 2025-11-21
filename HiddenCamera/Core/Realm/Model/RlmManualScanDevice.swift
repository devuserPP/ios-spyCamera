//
//  RlmManualScanDevice.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation
import RealmSwift

final class RlmManualScanDevice: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var lastSeen: Double = 0
    @objc dynamic var firstSeen: Double = 0
    @objc dynamic var rssi: Double = 0
    @objc dynamic var isTrusted: Bool = false
    @objc dynamic var type: String = ManualTrackerKind.unknown.rawValue
    @objc dynamic var vendor: String = "Unknown"
    @objc dynamic var connectionStatus: String = ManualTrackerConnectionStatus.unknown.rawValue
    @objc dynamic var eventCount: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
