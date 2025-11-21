//
//  HomeTab.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation

enum HomeTab: String, CaseIterable {
    case scan
    case tools
    case history
    case setting
    
    var title: String {
        switch self {
        case .scan:
            "Scan"
        case .tools:
            "Tools"
        case .history:
            "History"
        case .setting:
            "Setting"
        }
    }
    
    var systemImage: String {
        switch self {
        case .scan:
            "viewfinder.circle"
        case .tools:
            "wrench.and.screwdriver"
        case .history:
            "clock.arrow.circlepath"
        case .setting:
            "gearshape"
        }
    }
}
