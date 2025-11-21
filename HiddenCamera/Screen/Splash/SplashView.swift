import SwiftUI

fileprivate struct Const {
    static let iconWidth: CGFloat = UIScreen.main.bounds.width / 2
    static let iconHeight: CGFloat = iconWidth // SF Symbols jsou čtvercové
}

struct SplashView: View {
    @State private var didAppear = false
    @State private var showSecondIcon = false
    @State private var isAnimatingText = false
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                ZStack {
                    // 1) First icon (big scaling animation)
                    Image(systemName: "tag.slash")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.black)
                        .frame(width: Const.iconWidth * 0.5)
                        .scaleEffect(didAppear ? 1 : UIScreen.main.bounds.height / Const.iconWidth)
                        .animation(.easeInOut(duration: 1.8), value: didAppear)

                    // 2) Fade-in second icon
                    Image(systemName: "tag.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(width: Const.iconWidth)
                        .opacity(showSecondIcon ? 1 : 0)
                        .animation(.easeInOut(duration: 1), value: showSecondIcon)
                }
                .zIndex(1)
                
                // 3) Animated text reveal
                Text(AppConfig.appName)
                    .font(Poppins.semibold.font(size: 30))
                    .padding(.top, 10)
                    .overlay(
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Color.app(.light03)
                                    .frame(width: isAnimatingText ? 0 : geometry.size.width)
                                Spacer()
                            }
                            .animation(.easeInOut(duration: 1), value: isAnimatingText)
                        }
                    )
            }
            .offset(y: -Const.iconHeight / 2)
        }
        .onAppear {
            didAppear = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showSecondIcon = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                isAnimatingText = true
            }
        }
    }
}

#Preview {
    SplashView()
}
