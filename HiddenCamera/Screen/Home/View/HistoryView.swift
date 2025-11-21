//
//  HistoryView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie

// MARK: - HistoryView
struct HistoryView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    @ViewBuilder
    var body: some View {
        if viewModel.historyItems.isEmpty {
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.app(.light08))
                    .font(.system(size: 56, weight: .semibold))
                
                Text("You have never scanned before. Scan now to ensure the safety of your area.")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 44)
                
                Button(action: {
                    viewModel.currentTab = .scan
                }, label: {
                    Text("Scan now")
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.white)
                        .padding(.horizontal, 71)
                        .padding(.vertical, 16)
                        .background(Color.app(.main))
                        .cornerRadius(36, corners: .allCorners)
                })
                .padding(.top, 28)
                
//                NativeContentView().padding(.top, 20)
                
                Spacer()
            }.navigationBarHidden(true)
        } else {
            ScrollView(.vertical) {
                VStack {
                    ForEach(viewModel.historyItems.indices, id: \.self) { index in
                        let item = viewModel.historyItems[index]
                        
                        if index % 4 == 0 && !UserSetting.isPremiumUser {
//                            NativeContentView()
                        }
                        
                        HistoryItemView(item: item)
                            .onTapGesture {
                                viewModel.routing.routeToHistoryDetail.onNext(item)
                            }
                    }
                }.padding(.horizontal, 20)
            }.navigationBarHidden(true)
        }
    }
}

fileprivate struct HistoryItemView: View {
    var item: ScanOptionItem
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: imageName)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(color)
                        .font(.system(size: 20, weight: .semibold))
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(titleString)
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.app(.light12))
                
                Text(dateString)
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.light09))
            }.padding(.leading, 16)
            
            
            Spacer(minLength: 0)
            
            Image(systemName: isSafe ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isSafe ? .app(.safe) : .app(.warning))
                .font(.system(size: 20, weight: .semibold))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    var dateString: String {
        let date = item.date ?? Date()
        return date.string(format: "HH:mm dd/MM/yyyy")
    }
    
    var titleString: String {
        switch item.type {
        case .quick:
            "Quick Scan"
        case .full:
            "Scan Full"
        case .option:
            "Scan Options"
        }
    }
    
    var imageName: String {
        switch item.type {
        case .quick:
            "bolt.shield"
        case .full:
            "viewfinder.circle"
        case .option:
            "slider.horizontal.3"
        }
    }
    
    var color: Color {
        switch item.type {
        case .quick:
                .init(rgb: 0x9747FF)
        case .full:
                .init(rgb: 0x0090FF)
        case .option:
                .init(rgb: 0xFFA63D)
        }
    }
    
    var isSafe: Bool {
        return !item.suspiciousResult.contains(where: { $0.value > 0})
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
