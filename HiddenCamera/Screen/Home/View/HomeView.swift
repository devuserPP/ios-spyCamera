//
//  HomeView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI
import SakuraExtension
import Lottie
import RxSwift
import GoogleMobileAds
import FirebaseAnalytics

fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.width
    static let padding = 20.0
    static let itemSpacing = 16.0
    static let itemWidth = (screenWidth - padding * 2 - itemSpacing) / 2
    static let itemHeight = itemWidth / 186 * 172
    static let fontSize = itemWidth / 186 * 16
    static let itemPadding = itemWidth / 186 * 18
    static let circleHeight = itemHeight / 186 * 72
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isAnimatingCrown = false
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar.padding(.horizontal, 24)
                content
                tabbar
            }
            
            ScanOptionView(viewModel: viewModel)
                .offset(x: viewModel.isShowingScanOption ? 0 : UIScreen.main.bounds.width)
            
            ZStack {
                BlurSwiftUIView(effect: .init(style: .dark)).ignoresSafeArea()
                ProgressView().circleprogressColor(.white)
            }
            .opacity(viewModel.isShowingLoading ? 1 : 0)
        }
        .environmentObject(viewModel)
        .navigationBarHidden(true)
    }
    
    // MARK: - NavigationBar
    var navigationBar: some View {
        HStack {
            Text(viewModel.currentTab == .scan ? AppConfig.appName : viewModel.currentTab.title)
                .font(Poppins.bold.font(size: 20))
            
            
            Spacer()
            
            if !viewModel.isPremium {
                Button(action: {
                    Analytics.logEvent("tap_premium_home", parameters: nil)
                    viewModel.input.didTapPremiumButton.onNext(())
                }, label: {
                    Image(systemName: "crown.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(rgb: 0xFFA81F), Color(rgb: 0xF4C76A))
                        .font(.system(size: 24, weight: .semibold))
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        .scaleEffect(isAnimatingCrown ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimatingCrown)
                })
                .buttonStyle(.plain)
                .onAppear {
                    isAnimatingCrown = true
                }
            }
        }.frame(height: AppConfig.navigationBarHeight)
    }
    
    // MARK: - Tabbar
    // MARK: - Tabbar
    var tabbar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(HomeTab.allCases, id: \.rawValue) { tab in
                    TabBarItem(tab: tab, isActive: tab == viewModel.currentTab) {
                        viewModel.input.selectTab.onNext(tab)
                    }
                }
            }

            if !viewModel.isPremium && viewModel.didAppear {
                // BannerContentView(isCollapse: true, needToReload: nil)
            }
        }
        .background(
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea(edges: .bottom)

                // Jemný horní stín přesně jako na screenshotu
                Color.black
                    .opacity(0.06)
                    .frame(height: 1)
                    .blur(radius: 4)
            }
        )
    }

    
    // MARK: - Content
    var content: some View {
        ZStack {
            if viewModel.didLoadTab.contains(where: { $0 == .scan}) {
                ScanView().opacity(viewModel.currentTab == .scan ? 1 : 0)
            }
            
            if viewModel.didLoadTab.contains(where: { $0 == .tools}) {
                ToolsView().opacity(viewModel.currentTab == .tools ? 1 : 0)
            }
            
            if viewModel.didLoadTab.contains(where: { $0 == .history}) {
                HistoryView().opacity(viewModel.currentTab == .history ? 1 : 0)
            }
            
            if viewModel.didLoadTab.contains(where: { $0 == .setting}) {
                SettingView().opacity(viewModel.currentTab == .setting ? 1 : 0)
            }
        }
    }
}

private struct TabBarItem: View {
    let tab: HomeTab
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            VStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.app(isActive ? .main : .light06))
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 28, height: 24)
                
                Text(tab.title)
                    .font(Poppins.medium.font(size: 13))
                    .foreColor(.app(isActive ? .main : .light06))
                    .frame(height: 18)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
