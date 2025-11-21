//
//  ManualScanManager.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation
import CoreBluetooth

protocol ManualScanManagerDelegate: AnyObject {
    func manualScanManager(_ manager: ManualScanManager, didUpdate devices: [ManualScanDevice])
    func manualScanManager(_ manager: ManualScanManager, didChangeState state: CBManagerState)
}

final class ManualScanManager: NSObject {
    static let shared = ManualScanManager()
    
    weak var delegate: ManualScanManagerDelegate?
    
    private var devices: [String: ManualScanDevice] = [:]
    private var previousDelegate: BluetoothScannerDelegate?
    private var timer: Timer?
    private let dao = ManualScanDAO()
    private let eventDAO = ManualScanEventDAO()
    
    private override init() {
        super.init()
    }
    
    func start() {
        devices.removeAll()
        BluetoothScanner.shared.stopScanning()
        previousDelegate = BluetoothScanner.shared.delegate
        BluetoothScanner.shared.delegate = self
        BluetoothScanner.shared.startScanning()
    }
    
    func stop() {
        BluetoothScanner.shared.stopScanning()
        BluetoothScanner.shared.delegate = previousDelegate
        timer?.invalidate()
        timer = nil
    }
    
    private func persist() {
        let list = Array(devices.values)
        dao.upsertDevices(list)
        delegate?.manualScanManager(self, didUpdate: list.sorted(by: { $0.lastSeen > $1.lastSeen }))
    }
}

extension ManualScanManager: BluetoothScannerDelegate {
    func bluetoothScanner(_ scanner: BluetoothScanner, updateListDevice devices: [BluetoothDevice]) {
        let now = Date()
        var updated = self.devices
        
        for device in devices {
            let isTrusted = device.isSafe()
            let name = device.deviceName() ?? ""
            let existing = updated[device.id]
            let firstSeen = existing?.firstSeen ?? now
            let classification = device.trackerClassification
            let events = existing?.eventCount ?? eventDAO.events(for: device.id).count
            updated[device.id] = ManualScanDevice(id: device.id,
                                                  name: name,
                                                  rssi: device.rssi.doubleValue,
                                                  isTrusted: isTrusted,
                                                  trackerKind: classification.kind,
                                                  vendor: classification.vendor,
                                                  connectionStatus: classification.connectionStatus,
                                                  eventCount: events + 1,
                                                  firstSeen: firstSeen,
                                                  lastSeen: now)
            
            let event = ManualScanEvent(deviceId: device.id, timestamp: now, rssi: device.rssi.doubleValue)
            eventDAO.addEvent(event)
        }
        
        self.devices = updated
        persist()
    }
    
    func bluetoothScanner(_ scanner: BluetoothScanner, didUpdateState state: CBManagerState) {
        delegate?.manualScanManager(self, didChangeState: state)
    }
}
