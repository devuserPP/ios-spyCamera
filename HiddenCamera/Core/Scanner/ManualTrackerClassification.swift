//
//  ManualTrackerClassification.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation

struct ManualTrackerClassification {
    let kind: ManualTrackerKind
    let vendor: String
    let connectionStatus: ManualTrackerConnectionStatus
    
    init(kind: ManualTrackerKind, vendor: String, connectionStatus: ManualTrackerConnectionStatus = .unknown) {
        self.kind = kind
        self.vendor = vendor
        self.connectionStatus = connectionStatus
    }
}
