//
//  MainAndSideView1.swift
//  SlideOutMenu
//
//  Created by Mark Borazio [Personal] on 16/10/22.
//

import SwiftUI

struct MainAndSideView1<MainContent: View, SideContent: View>: View {
    
    @ViewBuilder let mainView: (() -> MainContent)
    @ViewBuilder let sideView: (() -> SideContent)
    
    private static var width: CGFloat { 300 }
    @State var offset: CGFloat = -Self.width
    
    private var dimLevel: Double {
        let maxDim: Double = 0.5
        let slideOutPercentage = (-offset)/Self.width
        return maxDim - slideOutPercentage * maxDim
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            mainView()
            
            Color.black.opacity(dimLevel)
                .ignoresSafeArea()

            sideView()
                .frame(width: Self.width)
                .offset(x: offset)
        }
        .gesture(dragGesture)
    }
    
    // MARK: - Drag Gesture
    
    @State var previousTranslation: CGSize = .zero
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let translationDelta = value.translation - previousTranslation
                previousTranslation = value.translation
                if translationDelta.width.magnitude > translationDelta.height.magnitude {
                    withAnimation {
                        let newOffset = offset + translationDelta.width
                        offset = newOffset.clamped(to: -Self.width...0)
                    }
                }
            }
            .onEnded { value in
                previousTranslation = .zero
                withAnimation {
                    // TODO: add velocity into the mix as well.
                    if offset < (-Self.width / 2) { // if is open less than half-way
                        offset = -Self.width // fully closed side menu
                    } else {
                        offset = 0 // fully open side menu
                    }
                }
            }
    }
}

struct MainAndSideView1_Previews: PreviewProvider {
    static var previews: some View {
        MainAndSideView1(
            mainView: {
                ZStack {
                    Color.blue
                        .ignoresSafeArea()
                    
                    Text("Main")
                }
            },
            sideView: {
                ZStack {
                    Color.red
                        .ignoresSafeArea()
                    
                    Text("Main")
                }
            }
        )
    }
}
