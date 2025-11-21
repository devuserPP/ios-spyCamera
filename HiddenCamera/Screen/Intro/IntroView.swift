//
//  IntroView.swift
//  HiddenCamera
//
//  Created by Duc apple on 9/1/25.
//

import SwiftUI
import SakuraExtension
import RxSwift

fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.width
    static let titleSize = screenWidth / 428 * 16
    static let normalSize = screenWidth / 428 * 14
}

struct IntroView: View {
    @ObservedObject var viewModel: IntroViewModel
    
    private let stepColors: [Color] = [
        Color(rgb: 0x4F9BFF),
        Color(rgb: 0xFFA63D),
        Color(rgb: 0x9747FF),
        Color(rgb: 0x0CDC08),
        Color(rgb: 0xFF4242)
    ]
    
    private let stepSymbols: [String] = [
        "dot.radiowaves.up.forward",
        "wifi",
        "viewfinder.circle",
        "eye.circle",
        "waveform.path"
    ]
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 12) {
                hero
                    .frame(height: 180)
                    .padding(.horizontal, 20)
                if viewModel.currentIndex < viewModel.intros.count {
                    VStack(alignment: .leading, spacing: 20) {
                        stepTimeline
                        stepCard
                    }
                    .padding(.horizontal, 20)
                } else {
                    introLast()
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.input.didTapContinue.onNext(())
                }, label: {
                    Text(viewModel.currentIndex >= viewModel.intros.count ? "Continue" : "Next")
                        .font(Poppins.medium.font(size: Const.titleSize))
                        .textColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.app(.main))
                        .cornerRadius(32, corners: .allCorners)
                })
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            .padding(.top, 0)
        }
        .statusBar(hidden: true)
    }
    
    private var header: some View {
        HStack {
            Text("Stay secure")
                .font(Poppins.bold.font(size: 18))
                .textColor(.app(.light12))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    private var hero: some View {
        ZStack {
            LinearGradient(colors: [Color.app(.main), Color(rgb: 0x6B7CFF)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(20, corners: .allCorners)
            VStack(spacing: 10) {
                Text("Stay secure")
                    .font(Poppins.medium.font(size: 14))
                    .textColor(.white.opacity(0.9))
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundColor(.white)
                Text(AppConfig.appName)
                    .font(Poppins.bold.font(size: 22))
                    .textColor(.white)
            }
        }
    }
    
    private var stepTimeline: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 12) {
                ForEach(0..<viewModel.intros.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(index == viewModel.currentIndex ? Color.app(.main) : Color.app(.light05))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(Poppins.semibold.font(size: 12))
                                    .textColor(index == viewModel.currentIndex ? .white : .app(.light11))
                            )
                        
                        if index != viewModel.intros.count - 1 {
                            Rectangle()
                                .fill(index < viewModel.currentIndex ? Color.app(.main) : Color.app(.light05))
                                .frame(width: 2, height: 28)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<viewModel.intros.count, id: \.self) { index in
                    let intro = viewModel.intros[index]
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(stepColors.indices.contains(index) ? stepColors[index] : .app(.main))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: stepSymbols.indices.contains(index) ? stepSymbols[index] : "shield")
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(intro.title)
                                .font(Poppins.semibold.font(size: Const.titleSize))
                                .textColor(.app(index == viewModel.currentIndex ? .light12 : .light10))
                            if index == viewModel.currentIndex {
                                Text(intro.description)
                                    .font(Poppins.regular.font(size: Const.normalSize))
                                    .textColor(.app(.light09))
                            }
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(index == viewModel.currentIndex ? Color.white : Color.white.opacity(0.8))
                    .cornerRadius(14, corners: .allCorners)
                    .shadow(color: .black.opacity(index == viewModel.currentIndex ? 0.08 : 0.02), radius: 8, x: 0, y: 3)
                    .opacity(index <= viewModel.currentIndex + 1 ? 1 : 0.35)
                    .animation(.easeInOut, value: viewModel.currentIndex)
                }
            }
        }
    }
    
    private var stepCard: some View {
        let idx = min(viewModel.currentIndex, viewModel.intros.count - 1)
        let intro = viewModel.intros[idx]
        return VStack(alignment: .leading, spacing: 12) {
            Text(intro.title )
                .font(Poppins.bold.font(size: Const.titleSize / 16 * 20))
                .textColor(.app(.light12))
            Text(intro.description )
                .font(Poppins.regular.font(size: Const.normalSize))
                .textColor(.app(.light10))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    private func introLast() -> some View {
        VStack(spacing: 12) {
            Text("Everything is safe and secure")
                .font(Poppins.bold.font(size: Const.titleSize / 16 * 20))
                .textColor(.app(.light12))
                .multilineTextAlignment(.center)
            
            Text("Protect your peace of mind and ensure your security with advanced hidden camera detection features, giving you confidence that your personal space is free from any unwanted surveillance.")
                .font(Poppins.regular.font(size: Const.normalSize))
                .textColor(.app(.light11))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    IntroView(viewModel: IntroViewModel())
}
