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
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                scanningStatus
                    .padding(.horizontal, 20)
                
                if !viewModel.potentialTrackers.isEmpty {
                    deviceSection(title: "Potential trackers", devices: viewModel.potentialTrackers, accent: .app(.warning))
                }
                
                deviceSection(title: "Nearby devices", devices: viewModel.nearbySafeDevices, accent: .app(.light11))
                
                Button(action: {
                    showHistory = true
                }, label: {
                    HStack {
                        Text("Previously found")
                            .font(Poppins.medium.font(size: 15))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                })
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                
                Spacer()
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
    
    private var scanningStatus: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.app(.main), Color(rgb: 0x6AB9FF)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Image(systemName: "dot.radiowaves.up.forward")
                            .foregroundColor(.white)
                            .font(.system(size: 48, weight: .semibold))
                    )
                    .shadow(color: .app(.main).opacity(0.25), radius: 20, x: 0, y: 12)
            }
            
            Text(viewModel.isScanning ? "Scanning for nearby trackers..." : viewModel.bluetoothProblemMessage)
                .font(Poppins.regular.font(size: 14))
                .textColor(.app(.light09))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
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
                        Text("Last seen \(device.lastSeen.string(format: "HH:mm dd/MM"))")
                            .font(Poppins.regular.font(size: 12))
                            .textColor(.app(.light09))
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%.0f dBm", device.rssi))
                        .font(Poppins.medium.font(size: 12))
                        .textColor(accent)
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
                                    Text("Last seen \(device.lastSeen.string(format: "HH:mm dd/MM/yyyy"))")
                                        .font(Poppins.regular.font(size: 12))
                                        .textColor(.app(.light09))
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
