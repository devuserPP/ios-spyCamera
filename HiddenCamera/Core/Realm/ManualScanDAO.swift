//
//  ManualScanDAO.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation

fileprivate let manualScanBufferTime: TimeInterval = 200

final class ManualScanDAO: RealmDAO {
    func upsertDevices(_ items: [ManualScanDevice]) {
        let objects = items.map { $0.rlmObject() }
        try? addAndUpdateObject(objects)
        NotificationCenter.default.post(name: .updateManualScanDevices, object: nil)
    }
    
    func recentDevices() -> [ManualScanDevice] {
        guard let objects = try? objects(type: RlmManualScanDevice.self) else { return [] }
        let threshold = Date().addingTimeInterval(-manualScanBufferTime).timeIntervalSince1970
        return objects
            .filter { $0.lastSeen >= threshold }
            .map { ManualScanDevice(rlm: $0) }
            .sorted(by: { $0.lastSeen > $1.lastSeen })
    }
    
    func historyDevices() -> [ManualScanDevice] {
        guard let objects = try? objects(type: RlmManualScanDevice.self) else { return [] }
        let threshold = Date().addingTimeInterval(-manualScanBufferTime).timeIntervalSince1970
        return objects
            .filter { $0.lastSeen < threshold }
            .map { ManualScanDevice(rlm: $0) }
            .sorted(by: { $0.lastSeen > $1.lastSeen })
    }
    
    func clearAll() {
        guard let objects = try? objects(type: RlmManualScanDevice.self) else { return }
        try? deleteObject(Array(objects))
        NotificationCenter.default.post(name: .updateManualScanDevices, object: nil)
    }
}

extension ManualScanDevice {
    func rlmObject() -> RlmManualScanDevice {
        let rlm = RlmManualScanDevice()
        rlm.id = id
        rlm.name = name
        rlm.lastSeen = lastSeen.timeIntervalSince1970
        rlm.firstSeen = firstSeen.timeIntervalSince1970
        rlm.rssi = rssi
        rlm.isTrusted = isTrusted
        rlm.type = trackerKind.rawValue
        rlm.vendor = vendor
        rlm.connectionStatus = connectionStatus.rawValue
        rlm.eventCount = eventCount
        return rlm
    }
}

extension Notification.Name {
    static let updateManualScanDevices = Notification.Name("updateManualScanDevices")
}
