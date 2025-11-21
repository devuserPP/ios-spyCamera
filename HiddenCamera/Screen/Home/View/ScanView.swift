//
//  ScanView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie

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

// MARK: - Scan View
struct ScanView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack {
                Text("Press the button below to run a full scan")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .padding(.top, 20)
                
                Button(action: {
                    viewModel.input.didTapScanFull.onNext(())
                }, label: {
                    LottieView(animation: .named("blueCircle"))
                        .playing(loopMode: .loop)
                        .overlay(
                            Image(systemName: "eye.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.white, Color.app(.main))
                                .font(.system(size: 64, weight: .semibold))
                        )
                        .frame(height: UIScreen.main.bounds.width - 40 * 2)
                })
                .buttonStyle(.plain)
                
                HStack {
                    Button(action: {
                        viewModel.input.didTapQuickScan.onNext(())
                    }, label: {
                        ScanItemView(color: .init(rgb: 0x9747FF), symbolName: "bolt.shield", name: "Quick Scan")
                    })
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.input.didTapScanOption.onNext(())
                    }, label: {
                        ScanItemView(color: .init(rgb: 0xFFA63D), symbolName: "slider.horizontal.3", name: "Scan Options")
                    })
                    .buttonStyle(.plain)
                }
                            
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Const.padding)
            .padding(.bottom, 50)
        }
        .frame(width: UIScreen.main.bounds.width)
        .navigationBarHidden(true)
    }
}

// MARK: - ScanOptionView
struct ScanOptionView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            viewModel.isShowingScanOption = false
                        }
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.app(.light12))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    })
                    .buttonStyle(.plain)
                    
                    Text("Scan Options")
                        .textColor(.app(.light12))
                        .font(Poppins.semibold.font(size: 18))
                    
                    Spacer()
                    
                    if !viewModel.scanOptions.isEmpty {
                        Button(action: {
                            withAnimation {
                                viewModel.input.removeAllScanOption.onNext(())
                            }
                        }, label: {
                            Text("Cancel")
                                .textColor(.app(.main))
                                .font(Poppins.semibold.font(size: 16))
                                .padding(20)
                        })
                    }
                }
                .frame(height: AppConfig.navigationBarHeight)
                
                Text("Choose options to scan")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .padding(.top, 16)
                
                ScrollView(.vertical) {
                    VStack {
                        LazyVGrid(columns: [.init(), .init()],spacing: 20, content: {
                            ForEach(ToolItem.allCases, id: \.self) { tool in
                                Button(action: {
                                    viewModel.input.didSelectToolOption.onNext(tool)
                                }, label: {
                                    ToolItemView(tool: tool)
                                        .overlay(alignment: .topTrailing) {
                                            Image(systemName: viewModel.isSelected(tool: tool) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(viewModel.isSelected(tool: tool) ? .app(.main) : .app(.light06))
                                                .padding(10)
                                        }
                                })
                                .buttonStyle(.plain)
                            }
                        })
                    }.padding(Const.padding)
                }
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    viewModel.input.didTapStartScanOption.onNext(())
                }, label: {
                    Text("Scan now")
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.white)
                        .padding(.horizontal, 71)
                        .padding(.vertical, 16)
                        .background(Color.app(.main))
                        .cornerRadius(36, corners: .allCorners)
                }).opacity(viewModel.scanOptions.isEmpty ? 0 : 1)
                
                if !viewModel.isPremium && viewModel.isShowingScanOption {
//                    BannerContentView(isCollapse: true, needToReload: nil)
                }
            }
        }
    }
}

// MARK: - ScanItemView
fileprivate struct ScanItemView: View {
    var color: Color
    var symbolName: String
    var name: String
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            Circle()
                .fill(color.opacity(0.12))
                .frame(height: Const.circleHeight)
                .overlay(
                    Image(systemName: symbolName)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(color)
                        .font(.system(size: Const.circleHeight / 72 * 32, weight: .semibold))
                        .padding(12)
                )
            
            Text(name)
                .multilineTextAlignment(.center)
                .font(Poppins.semibold.font(size: Const.fontSize))
                .padding(.top, Const.circleHeight / 72 * 16)
                .foreColor(.app(.light12))
            
            Spacer(minLength: 0)
        }
        .padding(Const.itemPadding)
        .frame(width: Const.itemWidth,
               height: Const.itemHeight)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
