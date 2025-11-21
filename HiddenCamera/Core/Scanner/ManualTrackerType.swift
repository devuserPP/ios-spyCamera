//
//  ManualTrackerType.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import Foundation
import CoreBluetooth

enum ManualTrackerConnectionStatus: String {
    case connected
    case prematureOffline
    case offline
    case overmatureOffline
    case unknown
    
    var description: String {
        switch self {
        case .connected: return "Owner connected"
        case .prematureOffline: return "Owner recently disconnected"
        case .offline: return "Owner disconnected"
        case .overmatureOffline: return "Owner long disconnected"
        case .unknown: return "Status unknown"
        }
    }
    
    var isTrackingMode: Bool {
        return self == .offline || self == .overmatureOffline || self == .unknown
    }
}

enum ManualTrackerType: String {
    case airtag
    case findMy
    case smarttag
    case tile
    case chipolo
    case google
    case pebblebee
    case findMyMobile
    case generic
    
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
        }
    }
}

struct ManualTrackerSignature {
    var nameKeywords: [String]
    var manufacturerPrefixes: [String]
    var serviceUUIDPrefixes: [String]
    var connectionStatusExtractor: (([String: Any]) -> ManualTrackerConnectionStatus)?
    
    static let airtag = ManualTrackerSignature(
        nameKeywords: ["airtag", "find my"],
        manufacturerPrefixes: ["4c00"],
        serviceUUIDPrefixes: ["7dfc9000"],
        connectionStatusExtractor: nil)
    
    static let smarttag = ManualTrackerSignature(
        nameKeywords: ["smarttag", "galaxy tag"],
        manufacturerPrefixes: ["7500"],
        serviceUUIDPrefixes: ["fd5a"],
        connectionStatusExtractor: ManualTrackerSignature.extractSmartTagStatus)
    
    static let tile = ManualTrackerSignature(
        nameKeywords: ["tile"],
        manufacturerPrefixes: ["e000"],
        serviceUUIDPrefixes: ["feed"],
        connectionStatusExtractor: nil)
    
    static let chipolo = ManualTrackerSignature(
        nameKeywords: ["chipolo"],
        manufacturerPrefixes: ["3301"],
        serviceUUIDPrefixes: [],
        connectionStatusExtractor: nil)
    
    static func extractSmartTagStatus(advertisementData: [String: Any]) -> ManualTrackerConnectionStatus {
        // service data keyed by UUIDs
        guard let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] else {
            return .unknown
        }
        let targetKey = CBUUID(string: "FD5A")
        guard let data = serviceData[targetKey] else {
            return .unknown
        }
        // need at least two bytes
        guard data.count > 1 else { return .unknown }
        let secondByte = data[1]
        // bits 1..3 (from MSB) per inspiration
        let bit5 = (secondByte & 0b0100) != 0
        let bit6 = (secondByte & 0b0010) != 0
        let bit7 = (secondByte & 0b0001) != 0
        if !bit5 && bit6 && bit7 {
            return .overmatureOffline
        } else if !bit5 && bit6 && !bit7 {
            return .offline
        } else if !bit5 && !bit6 && bit7 {
            return .prematureOffline
        } else {
            return .connected
        }
    }
}

struct ManualTrackerClassifier {
    static func classify(advertisementData: [String: Any], name: String?) -> ManualTrackerClassification {
        let lowerName = (name ?? "").lowercased()
        let signatures: [(ManualTrackerType, ManualTrackerSignature)] = [
            (.airtag, .airtag),
            (.findMy, ManualTrackerSignature(nameKeywords: ["findmy"], manufacturerPrefixes: ["4c00"], serviceUUIDPrefixes: ["7dfc9000"], connectionStatusExtractor: nil)),
            (.smarttag, .smarttag),
            (.tile, .tile),
            (.chipolo, .chipolo),
            (.google, ManualTrackerSignature(nameKeywords: ["google"], manufacturerPrefixes: [], serviceUUIDPrefixes: ["fea0", "feaa"], connectionStatusExtractor: nil)),
            (.pebblebee, ManualTrackerSignature(nameKeywords: ["pebblebee"], manufacturerPrefixes: [], serviceUUIDPrefixes: ["fd5b"], connectionStatusExtractor: nil)),
            (.findMyMobile, ManualTrackerSignature(nameKeywords: ["findmymobile"], manufacturerPrefixes: ["7500"], serviceUUIDPrefixes: [], connectionStatusExtractor: nil))
        ]
        
        let serviceUUIDs = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
        let serviceData = (advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]) ?? [:]
        let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        let manufacturerPrefix = manufacturer.map { data in
            data.prefix(2).map { String(format: "%02x", $0) }.joined()
        }
        
        func matches(prefixes: [String], uuidStrings: [String]) -> Bool {
            let lower = uuidStrings.map { $0.lowercased() }
            return prefixes.contains(where: { prefix in lower.contains(where: { $0.hasPrefix(prefix.lowercased()) }) })
        }
        
        for (type, signature) in signatures {
            if signature.nameKeywords.contains(where: { lowerName.contains($0) }) {
                let status = signature.connectionStatusExtractor?(advertisementData) ?? .unknown
                return ManualTrackerClassification(kind: convert(type), vendor: vendor(for: convert(type)), connectionStatus: status)
            }
            if let man = manufacturerPrefix, signature.manufacturerPrefixes.contains(where: { man.hasPrefix($0) }) {
                let status = signature.connectionStatusExtractor?(advertisementData) ?? .unknown
                return ManualTrackerClassification(kind: convert(type), vendor: vendor(for: convert(type)), connectionStatus: status)
            }
            let serviceUUIDStrings = serviceUUIDs.map { $0.uuidString }
            let serviceDataStrings = serviceData.keys.map { $0.uuidString }
            if matches(prefixes: signature.serviceUUIDPrefixes, uuidStrings: serviceUUIDStrings + serviceDataStrings) {
                let status = signature.connectionStatusExtractor?(advertisementData) ?? .unknown
                return ManualTrackerClassification(kind: convert(type), vendor: vendor(for: convert(type)), connectionStatus: status)
            }
        }
        
        return ManualTrackerClassification(kind: .generic, vendor: "Bluetooth", connectionStatus: .unknown)
    }
    
    private static func convert(_ type: ManualTrackerType) -> ManualTrackerKind {
        switch type {
        case .airtag: return .airtag
        case .findMy: return .findMy
        case .smarttag: return .smarttag
        case .tile: return .tile
        case .chipolo: return .chipolo
        case .google: return .google
        case .pebblebee: return .pebblebee
        case .findMyMobile: return .findMyMobile
        case .generic: return .generic
        }
    }
    
    private static func vendor(for kind: ManualTrackerKind) -> String {
        switch kind {
        case .airtag, .findMy: return "Apple"
        case .smarttag, .findMyMobile: return "Samsung"
        case .tile: return "Tile"
        case .chipolo: return "Chipolo"
        case .google: return "Google"
        case .pebblebee: return "Pebblebee"
        case .generic: return "Bluetooth"
        case .unknown: return "Unknown"
        }
    }
}
