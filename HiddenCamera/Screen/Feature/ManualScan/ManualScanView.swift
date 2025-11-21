//
//  ManualScanView.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import SwiftUI
import SakuraExtension

fileprivate struct ManualConst {
    static let cardSpacing = 12.0
}

struct ManualScanView: View {
    @ObservedObject var viewModel: ManualScanViewModel
    @State private var showHistory = false
    @State private var showMap = true
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                scanningPanel
                    .padding(.horizontal, 20)
                
                mapToggle
                    .padding(.horizontal, 20)
                
                if showMap {
                    ManualScanMapView(devices: viewModel.recentDevices)
                        .frame(height: 220)
                        .padding(.horizontal, 20)
                }
                
                if !viewModel.potentialTrackers.isEmpty {
                    deviceSection(title: "Potential trackers", devices: viewModel.potentialTrackers, accent: .app(.warning))
                }
                
                deviceSection(title: "Nearby devices", devices: viewModel.nearbySafeDevices, accent: .app(.light11))
                
                historyLink
                    .padding(.horizontal, 20)
                
                Spacer(minLength: 12)
            }
            .sheet(isPresented: $showHistory) {
                ManualScanHistoryView(devices: viewModel.historyDevices)
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .alert(isPresented: $viewModel.isShowingPermissionDialog) {
            Alert(title: Text(viewModel.bluetoothProblemTitle),
                  message: Text(viewModel.bluetoothProblemMessage),
                  primaryButton: .default(Text("Settings"), action: {
                    UIApplication.shared.openSetting()
                  }),
                  secondaryButton: .cancel())
        }
    }
    
    private var header: some View {
        HStack {
            Text("Manual Scan")
                .font(Poppins.bold.font(size: 22))
                .textColor(.app(.light12))
            Spacer()
            if !UserSetting.isPremiumUser {
                Image(systemName: "crown.fill")
                    .foregroundColor(Color(rgb: 0xF4C76A))
                    .font(.system(size: 20, weight: .semibold))
            }
        }
    }
    
    private var scanningPanel: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.app(.main), Color(rgb: 0x6AB9FF)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 160, height: 160)
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 6)
                                .scaleEffect(viewModel.showSecondaryHint ? 1.05 : 0.95)
                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: viewModel.showSecondaryHint)
                            Image(systemName: "dot.radiowaves.up.forward")
                                .foregroundColor(.white)
                                .font(.system(size: 52, weight: .semibold))
                        }
                    )
                    .shadow(color: .app(.main).opacity(0.25), radius: 20, x: 0, y: 12)
            }
            
            VStack(spacing: 6) {
                Text(viewModel.isScanning ? primaryHint : viewModel.bluetoothProblemMessage)
                    .font(Poppins.semibold.font(size: 15))
                    .textColor(.app(.light12))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                
                Text(secondaryHint)
                    .font(Poppins.regular.font(size: 13))
                    .textColor(.app(.light09))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
    }
    
    private func deviceSection(title: String, devices: [ManualScanDevice], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !devices.isEmpty {
                Text(title)
                    .font(Poppins.semibold.font(size: 15))
                    .textColor(.app(.light11))
                    .padding(.horizontal, 20)
            }
            
            ForEach(devices) { device in
                HStack {
                    Circle()
                        .fill(accent.opacity(0.12))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: device.isPotentialRisk ? "exclamationmark.triangle" : "waveform")
                                .foregroundColor(accent)
                                .font(.system(size: 18, weight: .semibold))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(device.displayName)
                            .font(Poppins.semibold.font(size: 14))
                            .textColor(.app(.light12))
                        Text("\(device.trackerKind.displayName) • \(device.vendor)")
                            .font(Poppins.regular.font(size: 12))
                            .textColor(.app(.light10))
                        Text("Last seen \(device.lastSeen.string(format: "HH:mm dd/MM"))")
                            .font(Poppins.regular.font(size: 12))
                            .textColor(.app(.light09))
                        Text(device.connectionStatus.description)
                            .font(Poppins.regular.font(size: 12))
                            .textColor(device.connectionStatus.isTrackingMode ? .app(.warning) : .app(.light09))
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%.0f dBm", device.rssi))
                        .font(Poppins.medium.font(size: 12))
                        .textColor(accent)
                    Text("\(device.eventCount)x")
                        .font(Poppins.medium.font(size: 12))
                        .textColor(.app(.light09))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var historyLink: some View {
        Button(action: { showHistory = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Previously found")
                        .font(Poppins.medium.font(size: 15))
                        .textColor(.app(.light12))
                    Text("View older trackers outside scan window")
                        .font(Poppins.regular.font(size: 12))
                        .textColor(.app(.light09))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.app(.light11))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var primaryHint: String {
        if !viewModel.isScanning { return viewModel.bluetoothProblemMessage }
        let count = viewModel.recentDevices.count
        if count == 0 { return "Scanning for nearby trackers..." }
        return "Detected \(count) device\(count > 1 ? "s" : "") around you"
    }
    
    private var secondaryHint: String {
        if !viewModel.isScanning { return "" }
        if viewModel.showSecondaryHint {
            return "Not all nearby trackers are dangerous. Review and mark safe if needed."
        }
        let remaining = max(0, 60 - Int(viewModel.elapsedSeconds))
        if remaining > 0 {
            return "Full scan may take \(remaining)s."
        }
        return "Mark your own devices as safe to filter them out."
    }
    
    private var mapToggle: some View {
        HStack {
            Text("View")
                .font(Poppins.medium.font(size: 13))
                .textColor(.app(.light11))
            Spacer()
            Picker(selection: $showMap, label: Text("")) {
                Text("Map").tag(true)
                Text("List").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 160)
        }
    }
}

struct ManualScanHistoryView: View {
    var devices: [ManualScanDevice]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    if devices.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.app(.light08))
                                .font(.system(size: 32, weight: .semibold))
                            Text("No previous trackers found")
                                .font(Poppins.regular.font(size: 14))
                                .textColor(.app(.light09))
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(devices) { device in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(device.displayName)
                                        .font(Poppins.semibold.font(size: 14))
                                        .textColor(.app(.light12))
                                    Text("\(device.trackerKind.displayName) • \(device.vendor)")
                                        .font(Poppins.regular.font(size: 12))
                                        .textColor(.app(.light10))
                                    Text("Last seen \(device.lastSeen.string(format: "HH:mm dd/MM/yyyy"))")
                                        .font(Poppins.regular.font(size: 12))
                                        .textColor(.app(.light09))
                                    Text(device.connectionStatus.description)
                                        .font(Poppins.regular.font(size: 12))
                                        .textColor(device.connectionStatus.isTrackingMode ? .app(.warning) : .app(.light09))
                                }
                                Spacer()
                                Text(String(format: "%.0f dBm", device.rssi))
                                    .font(Poppins.medium.font(size: 12))
                                    .textColor(.app(.light11))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Manual Scan History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Radar Map
struct ManualScanMapView: View {
    var devices: [ManualScanDevice]
    
    private func radius(for rssi: Double, in size: CGSize) -> CGFloat {
        let minRSSI: Double = -100
        let maxRSSI: Double = -30
        let clamped = max(minRSSI, min(maxRSSI, rssi))
        let normalized = (clamped - minRSSI) / (maxRSSI - minRSSI) // 0...1
        let maxRadius = min(size.width, size.height) / 2 - 20
        return CGFloat(1 - normalized) * maxRadius + 12
    }
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                ForEach(0..<3) { idx in
                    Circle()
                        .stroke(Color.app(.light05), lineWidth: 1)
                        .frame(width: geo.size.width - CGFloat(idx * 30),
                               height: geo.size.width - CGFloat(idx * 30))
                        .opacity(0.6)
                }
                
                ForEach(devices) { device in
                    let radius = radius(for: device.rssi, in: geo.size)
                    let angle = Double(abs(device.id.hashValue % 360))
                    let radians = angle * .pi / 180
                    let x = center.x + CGFloat(cos(radians)) * radius
                    let y = center.y + CGFloat(sin(radians)) * radius
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill((device.isPotentialRisk ? Color.app(.warning) : Color.app(.safe)).opacity(0.18))
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: device.isPotentialRisk ? "exclamationmark.triangle.fill" : "waveform")
                                    .foregroundColor(device.isPotentialRisk ? .app(.warning) : .app(.safe))
                                    .font(.system(size: 14, weight: .semibold))
                            )
                        Text(device.trackerKind.displayName)
                            .font(Poppins.medium.font(size: 10))
                            .textColor(.app(.light11))
                            .lineLimit(1)
                    }
                    .position(x: x, y: y)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}
