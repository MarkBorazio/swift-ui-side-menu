//
//  MainAndSideView.swift
//  SlideOutMenu
//
//  Created by Mark Borazio [Personal] on 16/10/22.
//

import SwiftUI

struct MainAndSideView<MainContent: View, SideContent: View>: View {
    
    @ViewBuilder let mainView: (() -> MainContent)
    @ViewBuilder let sideView: (() -> SideContent)
    
    @State var sideViewWidth: CGFloat = 0
    @State var sideViewOffset: CGFloat = 0
    @State var isDragging: Bool = false
    @Binding var isSideViewOpen: Bool
    
    var body: some View {
        GeometryReader { geometryProxy in
            mainView()
                .overlay(dimmingView(geometryProxy), alignment: .topLeading)
                .overlay(sideView(geometryProxy), alignment: .topLeading)
                .gesture(dragGesture(geometryProxy))
        }
    }
    
    // MARK: - Convenience
    
    private static var openedOffset: CGFloat { 0 }
    
    private func calculateClosedOffset(_ geometryProxy: GeometryProxy) -> CGFloat {
        -sideViewWidth - geometryProxy.safeAreaInsets.leading
    }
    
    private func calculateOffset(_ geometryProxy: GeometryProxy) -> CGFloat {
        if isDragging {
            return sideViewOffset
        } else {
            return isSideViewOpen ? Self.openedOffset : calculateClosedOffset(geometryProxy)
        }
    }
    
    private func calculateDimLevel(_ geometryProxy: GeometryProxy) -> Double {
        let maxDim: Double = 0.5
        let slideOutPercentage = (calculateOffset(geometryProxy))/sideViewWidth
        return maxDim * (1 + slideOutPercentage)
    }
    
    private func getAnimation() -> Animation? {
        isDragging ? nil : .easeInOut
    }
    
    // MARK: - Views
    
    private func sideView(_ geometryProxy: GeometryProxy) -> some View {
        sideView()
            .offset(x: calculateOffset(geometryProxy))
            .animation(getAnimation(), value: isSideViewOpen)
            .readSize { size in
                sideViewWidth = size.width
                sideViewOffset = calculateClosedOffset(geometryProxy)
            }
    }
    
    private func dimmingView(_ geometryProxy: GeometryProxy) -> some View {
        Color.black
            .opacity(calculateDimLevel(geometryProxy))
            .animation(getAnimation())
            .ignoresSafeArea()
            .onTapGesture { isSideViewOpen = false }
    }
    
    // MARK: - Drag Gesture
    
    @State var previousTranslation: CGSize = .zero
    
    private func dragGesture(_ geometryProxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                
                // If we have only just started dragging, then set the offset according to opened/closed state
                if !isDragging {
                    sideViewOffset = calculateOffset(geometryProxy)
                }
                isDragging = true
                
                // Calculate delta that will be applied to offset
                let translationDelta = value.translation - previousTranslation
                previousTranslation = value.translation
                
                if translationDelta.width.magnitude > translationDelta.height.magnitude {
                    withAnimation {
                        let newOffset = sideViewOffset + translationDelta.width
                        sideViewOffset = newOffset.clamped(to: calculateClosedOffset(geometryProxy)...0)
                    }
                }
            }
            .onEnded { value in
                previousTranslation = .zero
                let closedOffset = calculateClosedOffset(geometryProxy)
                withAnimation {
                    let isOpenLessThanHalfway = sideViewOffset < (closedOffset / 2)
                    if isOpenLessThanHalfway {
                        self.sideViewOffset = closedOffset
                        isSideViewOpen = false
                    } else {
                        self.sideViewOffset = Self.openedOffset
                        isSideViewOpen = true
                    }
                    isDragging = false
                }
            }
    }
}


struct MainAndSideView_Previews: PreviewProvider {
    @State static var isSideViewOpen = true
    static var previews: some View {
        MainAndSideView(
            mainView: {
                VStack {
                    Spacer()
                    Button("Open Menu") {
                        isSideViewOpen.toggle()
                    }
                    .background(Color.yellow.ignoresSafeArea())
                    Spacer()
                }
            },
            sideView: {
                Text("Side Menu")
                    .background(Color.red.ignoresSafeArea())
            },
            isSideViewOpen: $isSideViewOpen
        )
    }
}
