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
            .onChange(of: isUpdatingDrag) { newIsUpdatingDrag in
                if !newIsUpdatingDrag {
                    onDragGestureEnd()
                }
            }
            .readSafeAreaInsets { safeAreaInsets in
                trailingSafeAreaInset = safeAreaInsets.trailing
                resetToClosed() // If safe area insets change then we want to close view, otherwise it may be not closed all the way.
            }
    }
    
    private var sideViewOverlay: some View {
        sideView
            .offset(x: offset)
            .animation(Self.offsetAnimation, value: isSideViewOpen)
            .readSize { size in
                sideViewWidth = size.width
                resetToClosed()
            }
    }
    
    private var dimmingView: some View {
        Color.black
            .opacity(dimLevel)
            .animation(Self.offsetAnimation)
            .ignoresSafeArea()
            .onTapGesture { resetToClosed() }
    }
    
    // MARK: - Convenience
    
    private static var offsetAnimation: Animation { .easeInOut }
    
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
    @GestureState var isUpdatingDrag: Bool = false // Used purely to detect if drag cancelled (onChanged or onEnded don't get called)
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .updating($isUpdatingDrag) { _, state, _ in
                state = true
            }
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
                    
                    let newOffset = sideViewOffset + translationDelta.width
                    sideViewOffset = newOffset.clamped(to: closedOffset...0)
                }
            }
            .onEnded { value in
                let translationDelta = value.translation - previousTranslation
                let wasDraggingFast = translationDelta.width.magnitude > 5
                let wasIntendedGesture = isIntendedGesture(value.startLocation)
                
                if wasDraggingFast && wasIntendedGesture {
                    if translationDelta.width >= 0 { // Going right
                        resetToOpen()
                    } else { // Going left
                        resetToClosed()
                    }
                } else {
                    onDragGestureEnd()
                }
            }
    }
    
    private func onDragGestureEnd() {
        let isOpenLessThanHalfway = sideViewOffset < (closedOffset / 2)
        if isOpenLessThanHalfway {
            resetToClosed()
        } else {
            resetToOpen()
        }
    }
}
