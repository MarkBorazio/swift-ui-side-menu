//
//  ContentView.swift
//  Shared
//
//  Created by Mark Borazio [Personal] on 9/10/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var isOpen: Bool = false
    
    var body: some View {
        MainAndSideView(
            mainView: {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Main 1") {
                            isOpen.toggle()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color.red.ignoresSafeArea())
            },
            sideView: {
                HStack(alignment: .top) {
                    ForEach(1..<3) { index in
                        Text("\(index)")
                    }
                    Spacer()
                    VStack {
                        Spacer()
                        ForEach(1..<101) { index in
                            Text("\(index)")
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: 300)
                .background(Color.blue.ignoresSafeArea())
            },
            isSideViewOpen: $isOpen
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// MARK: - Experi


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
        let slideOutPercentage = (-calculateOffset(geometryProxy))/sideViewWidth
        return maxDim - slideOutPercentage * maxDim
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
                
                // If have just started dragging, set offset according to open state
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
