//
//  RlmManualScanEvent.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation
import RealmSwift

final class RlmManualScanEvent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var deviceId: String = ""
    @objc dynamic var timestamp: Double = 0
    @objc dynamic var rssi: Double = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
