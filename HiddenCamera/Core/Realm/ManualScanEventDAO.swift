//
//  ManualScanEventDAO.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation

final class ManualScanEventDAO: RealmDAO {
    func addEvent(_ event: ManualScanEvent) {
        let rlm = event.rlmObject()
        try? addAndUpdateObject([rlm])
    }
    
    func events(for deviceId: String) -> [ManualScanEvent] {
        guard let objects = try? objects(type: RlmManualScanEvent.self) else { return [] }
        return objects
            .filter { $0.deviceId == deviceId }
            .map { ManualScanEvent(rlm: $0) }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
}

extension ManualScanEvent {
    func rlmObject() -> RlmManualScanEvent {
        let rlm = RlmManualScanEvent()
        rlm.id = id
        rlm.deviceId = deviceId
        rlm.timestamp = timestamp.timeIntervalSince1970
        rlm.rssi = rssi
        return rlm
    }
}
