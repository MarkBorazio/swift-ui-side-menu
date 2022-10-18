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
    @State var trailingSafeAreaInset: CGFloat = 0
    @State var isDragging: Bool = false
    @Binding var isSideViewOpen: Bool
    
    // MARK: - Views
    
    var body: some View {
        mainView
            .overlay(dimmingView, alignment: .topLeading)
            .overlay(sideViewOverlay, alignment: .topLeading)
            .gesture(dragGesture)
            .readSafeAreaInsets { safeAreaInsets in
                trailingSafeAreaInset = safeAreaInsets.trailing
                resetToClosed() // If safe area insets change then we want to close view, otherwise it may be not closed all the way.
            }
    }
    
    private var sideViewOverlay: some View {
        sideView
            .offset(x: offset)
            .animation(animation, value: isSideViewOpen)
            .readSize { size in
                sideViewWidth = size.width
                resetToClosed()
            }
    }
    
    private var dimmingView: some View {
        Color.black
            .opacity(dimLevel)
            .animation(animation)
            .ignoresSafeArea()
            .onTapGesture { resetToClosed() }
    }
    
    // MARK: - Convenience
    
    private static var openedOffset: CGFloat { 0 }
    
    private var closedOffset: CGFloat {
        -sideViewWidth - trailingSafeAreaInset
    }
    
    private var offset: CGFloat {
        if isDragging {
            return sideViewOffset
        } else {
            return isSideViewOpen ? Self.openedOffset : closedOffset
        }
    }
    
    private var dimLevel: Double {
        let maxDim: Double = 0.5
        let slideOutPercentage = offset/sideViewWidth
        return maxDim * (1 + slideOutPercentage)
    }
    
    private var animation: Animation? {
        isDragging ? nil : .easeInOut
    }
    
    private func resetToClosed() {
        withAnimation {
            self.sideViewOffset = closedOffset
            isSideViewOpen = false
            isDragging = false
            previousTranslation = .zero
        }
    }
    
    private func resetToOpen() {
        withAnimation {
            self.sideViewOffset = Self.openedOffset
            isSideViewOpen = true
            isDragging = false
            previousTranslation = .zero
        }
    }
    
    // If side view is closed, make sure that it can only be opened from the left edge.
    private func isIntendedGesture(_ startLocation: CGPoint) -> Bool {
        isSideViewOpen || startLocation.x < 30
    }
    
    // MARK: - Drag Gesture
    
    @State var previousTranslation: CGSize = .zero
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                
                guard isIntendedGesture(value.startLocation) else { return }
                
                // Calculate delta that will be applied to offset
                let translationDelta = value.translation - previousTranslation
                previousTranslation = value.translation
                
                if translationDelta.width.magnitude > translationDelta.height.magnitude {
                    // If we have only just started dragging, then set the offset according to opened/closed state
                    if !isDragging {
                        sideViewOffset = offset
                    }
                    isDragging = true
                    
                    withAnimation {
                        let newOffset = sideViewOffset + translationDelta.width
                        sideViewOffset = newOffset.clamped(to: closedOffset...0)
                    }
                }
            }
            .onEnded { value in
                previousTranslation = .zero
                let translationDelta = value.translation - previousTranslation
                let wasDraggingFast = translationDelta.width.magnitude > 100
                let wasIntendedGesture = isIntendedGesture(value.startLocation)
                
                if wasDraggingFast && wasIntendedGesture {
                    if translationDelta.width >= 0 { // Going right
                        resetToOpen()
                    } else { // Going left
                        resetToClosed()
                    }
                } else {
                    let isOpenLessThanHalfway = sideViewOffset < (closedOffset / 2)
                    if isOpenLessThanHalfway {
                        resetToClosed()
                    } else {
                        resetToOpen()
                    }
                }
            }
        

    }
    
}
