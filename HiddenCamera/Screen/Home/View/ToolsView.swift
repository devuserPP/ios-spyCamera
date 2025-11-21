//
//  ToolsView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI
import SakuraExtension
import RxSwift

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

struct ToolsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                LazyVGrid(columns: [.init(), .init()], content: {
                    ForEach(ToolItem.allCases, id: \.self) { tool in
                        Button(action: {
                            viewModel.input.didSelectTool.onNext(tool)
                        }, label: {
                            ToolItemView(tool: tool)
                        })
                    }
                })
            }
            .padding(.horizontal, Const.padding)
            .padding(.bottom, Const.padding)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - ToolItemView
struct ToolItemView: View {
    let tool: ToolItem
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            Circle()
                .fill(tool.color.opacity(0.12))
                .frame(height: Const.circleHeight)
                .overlay(
                    Image(systemName: tool.symbolName)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(tool.color)
                        .font(.system(size: Const.circleHeight / 72 * 32, weight: .semibold))
                        .padding(12)
                )
            
            Text(tool.name)
                .multilineTextAlignment(.center)
                .font(Poppins.semibold.font(size: Const.fontSize))
                .padding(.top, Const.circleHeight / 72 * 16)
                .foreColor(.app(.light12))
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                
            
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
