//
//  MainAndSideView.swift
//  SlideOutMenu
//
//  Created by Mark Borazio [Personal] on 16/10/22.
//

import SwiftUI

extension View {
    
    func withSideView<SideContent: View>(isOpen: Binding<Bool>, @ViewBuilder sideView: (() -> SideContent)) -> some View {
        MainAndSideView(
            mainView: self,
            sideView: sideView(),
            isSideViewOpen: isOpen
        )
    }
}

struct MainAndSideView<MainContent: View, SideContent: View>: View {
    
    let mainView: MainContent
    let sideView: SideContent
    
    @State var sideViewWidth: CGFloat = 0
    @State var sideViewOffset: CGFloat = 0
    @State var isDragging: Bool = false
    @Binding var isSideViewOpen: Bool
    
    // MARK: - Views
    
    var body: some View {
        GeometryReader { geometryProxy in
            mainView
                .overlay(dimmingView(geometryProxy), alignment: .topLeading)
                .overlay(sideView(geometryProxy), alignment: .topLeading)
                .gesture(dragGesture(geometryProxy))
        }
    }
    
    private func sideView(_ geometryProxy: GeometryProxy) -> some View {
        sideView
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
