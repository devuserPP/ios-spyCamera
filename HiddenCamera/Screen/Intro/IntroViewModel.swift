//
//  IntroViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import UIKit
import RxSwift
import SwiftUI
import AppTrackingTransparency
import FirebaseAnalytics
import CoreBluetooth

struct IntroItem {
    var title: String
    var description: String
}

struct IntroViewModelInput: InputOutputViewModel {
    var didTapContinue = PublishSubject<()>()
}

struct IntroViewModelOutput: InputOutputViewModel {
    
}

struct IntroViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var showConsent = PublishSubject<()>()
}

final class IntroViewModel: BaseViewModel<IntroViewModelInput, IntroViewModelOutput, IntroViewModelRouting> {
    @Published var currentIndex: Int = 0
    @Published var intros: [IntroItem] = [
        .init(title: "Bluetooth Locator", description: "Use Bluetooth technology right on your phone to determine the location and distance of suspicious devices around you."),
        .init(title: "Wifi Devices Finder", description: "Scan your local network for hidden cameras or suspicious devices connected alongside you."),
        .init(title: "AI Camera Scanner", description: "Use your phone's camera and AI to spot hidden lenses in real time."),
        .init(title: "IR Vision Camera", description: "Reveal infrared cameras quickly with a bright color filter."),
        .init(title: "Magnetometer", description: "Detect hidden electronics using your device's magnetic sensor.")
    ]
    @Published var isRequested: Bool = false
    @Published var isRequestingPermission: Bool = false
    
    override func config() {
        super.config()
        self.isRequested = ATTrackingManager.trackingAuthorizationStatus != .notDetermined
        
        if !isRequested {
            Analytics.logEvent("permission_att", parameters: nil)
        }
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapContinue.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if isRequested {
                handleStep()
            } else {
                requestTracking()
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func requestTracking() {
        self.routing.showConsent.onNext(())
    }
    
    private func handleStep() {
        if isRequestingPermission { return }
        isRequestingPermission = true
        
        Analytics.logEvent("intro_\(self.currentIndex + 1)", parameters: nil)
        
        requestPermission(for: currentIndex) { [weak self] in
            guard let self else { return }
            self.isRequestingPermission = false
            
            if self.currentIndex >= intros.count {
                self.routing.stop.onNext(())
            } else {
                withAnimation {
                    self.currentIndex += 1
                }
            }
        }
    }
    
    private func requestPermission(for index: Int, completion: @escaping () -> Void) {
        switch index {
        case 0:
            // Trigger Bluetooth prompt by starting a short scan
            BluetoothScanner.shared.startScanning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                BluetoothScanner.shared.stopScanning()
                completion()
            }
        case 1:
            Task {
                _ = try? await requestLocalNetworkAuthorization()
                await MainActor.run {
                    completion()
                }
            }
        case 2:
            Permission.requestCamera { _ in
                DispatchQueue.main.async {
                    completion()
                }
            }
        default:
            completion()
        }
    }
}
