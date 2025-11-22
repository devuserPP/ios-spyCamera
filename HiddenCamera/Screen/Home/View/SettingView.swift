//
//  SettingView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import Foundation
import SwiftUI
import RxSwift
import SakuraExtension

enum SettingItem: String {
    case rate
    case share
    case policy
    case term
    case contact
    case restore
}

struct SettingView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !viewModel.isPremium {
                    Image("setting_banner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20, corners: .allCorners)
                        .overlay(
                            GeometryReader(content: { geometry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        Button(action: {
                                            viewModel.input.didTapPremiumButton.onNext(())
                                        }, label: {
                                            ZStack {
//                                                Color.app(.main)
                                                Text("Get Premium")
                                                    .textColor(.yellow)
                                                    .font(Poppins.medium.font(size: 15))
                                            }
                                            .frame(height: 30)
                                            .cornerRadius(30, corners: .allCorners)
                                        })
                                    }
                                    
                                    Spacer(minLength: geometry.size.width / 2.5)
                                }.padding(20)
                            })
                        )
                }
                
                Text("App interaction")
                    .font(Poppins.semibold.font(size: 14))
                    .padding(.top, 20)
                VStack(alignment: .leading, spacing: 0) {
                    itemView(systemName: "square.and.arrow.up", title: "Share app") {
                        viewModel.input.selectSettingItem.onNext(.share)
                    }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(systemName: "star.fill", title: "Rate app") {
                        viewModel.input.selectSettingItem.onNext(.rate)
                    }
                }
                .foreColor(.app(.light12))
                .background(Color.white)
                .cornerRadius(24, corners: .allCorners)
                .padding(.top, 12)
                
                Text("Legal info")
                    .font(Poppins.semibold.font(size: 14))
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    itemView(systemName: "lock.shield", title: "Privacy Policy") {
                        viewModel.input.selectSettingItem.onNext(.policy)
                    }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(systemName: "doc.text", title: "Term of Condition") {
                        viewModel.input.selectSettingItem.onNext(.term)
                    }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(systemName: "envelope.badge", title: "Contact Us") {
                        viewModel.input.selectSettingItem.onNext(.contact)
                    }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(systemName: "arrow.uturn.backward", title: "Restore") {
                        viewModel.input.selectSettingItem.onNext(.restore)
                    }
                }
                .foreColor(.app(.light12))
                .background(Color.white)
                .cornerRadius(24, corners: .allCorners)
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .navigationBarHidden(true)
    }
    
    func itemView(systemName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            HStack(spacing: 0) {
                Image(systemName: systemName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.app(.light12))
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 24)
                
                Text(title)
                    .font(Poppins.regular.font(size: 14))
                    .padding(.leading, 12)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.app(.light08))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(20)
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
