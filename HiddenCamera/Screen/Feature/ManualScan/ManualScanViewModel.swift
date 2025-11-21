//
//  ManualScanViewModel.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation
import CoreBluetooth
import SwiftUI

final class ManualScanViewModel: NSObject, ObservableObject {
    @Published var recentDevices: [ManualScanDevice] = []
    @Published var historyDevices: [ManualScanDevice] = []
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var isScanning: Bool = false
    @Published var isShowingPermissionDialog: Bool = false
    
    private let dao = ManualScanDAO()
    private let clock = Date()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHistory), name: .updateManualScanDevices, object: nil)
    }
    
    func startScanning() {
        isScanning = true
        ManualScanManager.shared.delegate = self
        ManualScanManager.shared.start()
        reloadHistory()
    }
    
    func stopScanning() {
        isScanning = false
        ManualScanManager.shared.stop()
    }
    
    var potentialTrackers: [ManualScanDevice] {
        recentDevices.filter { $0.isPotentialRisk }
    }
    
    var nearbySafeDevices: [ManualScanDevice] {
        recentDevices.filter { !$0.isPotentialRisk }
    }
    
    var bluetoothProblemTitle: String {
        switch bluetoothState {
        case .unauthorized:
            return "Bluetooth access denied"
        case .poweredOff:
            return "Bluetooth is off"
        default:
            return "Bluetooth unavailable"
        }
    }
    
    var bluetoothProblemMessage: String {
        switch bluetoothState {
        case .unauthorized:
            return "Enable Bluetooth permission in Settings to scan for trackers nearby."
        case .poweredOff:
            return "Turn on Bluetooth to start manual scanning."
        default:
            return "Bluetooth is not ready. Try again in a moment."
        }
    }
    
    @objc private func reloadHistory() {
        historyDevices = dao.historyDevices()
    }
}

extension ManualScanViewModel: ManualScanManagerDelegate {
    func manualScanManager(_ manager: ManualScanManager, didUpdate devices: [ManualScanDevice]) {
        DispatchQueue.main.async {
            self.recentDevices = devices
        }
    }
    
    func manualScanManager(_ manager: ManualScanManager, didChangeState state: CBManagerState) {
        DispatchQueue.main.async {
            self.bluetoothState = state
            self.isShowingPermissionDialog = state == .unauthorized
            if state == .poweredOff {
                self.isScanning = false
            }
        }
    }
}
