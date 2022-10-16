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
                ZStack {
                    Color.red
                        .ignoresSafeArea()
                    
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
                }
            },
            sideView: {
                ZStack {
                    Color.blue
                        .ignoresSafeArea()

                    ScrollView {
                        HStack {
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
                    }
                }
                .frame(width: 300)
            },
            isSideMenuOpen: $isOpen
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
    
    @State var width: CGFloat = 0
    @State var offset: CGFloat = 0
    @Binding var isSideMenuOpen: Bool
    
    private var dimLevel: Double {
        let maxDim: Double = 0.5
        let slideOutPercentage = (-offset)/width
        return maxDim - slideOutPercentage * maxDim
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack(alignment: .leading) {
                
                mainView()
                
                Color.black.opacity(dimLevel)
                    .ignoresSafeArea()
                
                sideView()
                    .readSize { size in
                        width = size.width
                        offset = -size.width - geometryProxy.safeAreaInsets.leading
                    }
                    .offset(x: calculateOffset(geometryProxy))
                    .animation(isDragging ? nil : .easeInOut, value: isSideMenuOpen)

            }
            .gesture(dragGesture(leadingSafeAreaInset: geometryProxy.safeAreaInsets.leading))
        }
    }
    
    private func calculateOffset(_ geometryProxy: GeometryProxy) -> CGFloat {
        if isDragging {
            return offset
        } else {
            return isSideMenuOpen ? 0 : (-width - geometryProxy.safeAreaInsets.leading)
        }
    }
    
    private func calculateClosedOffset(_ geometryProxy: GeometryProxy) -> CGFloat {
        -width - geometryProxy.safeAreaInsets.leading
    }
    
    // MARK: - Drag Gesture
    
    @State var previousTranslation: CGSize = .zero
    @State var isDragging: Bool = false
    
    private func dragGesture(leadingSafeAreaInset: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                isDragging = true
                let translationDelta = value.translation - previousTranslation
                previousTranslation = value.translation
                if translationDelta.width.magnitude > translationDelta.height.magnitude {
                    withAnimation {
                        let newOffset = offset + translationDelta.width
                        offset = newOffset.clamped(to: -width...leadingSafeAreaInset)
                    }
                }
            }
            .onEnded { value in
                isDragging = false
                previousTranslation = .zero
                withAnimation {
                    // TODO: add velocity into the mix as well.
                    if offset < (-width / 2) { // if is open less than half-way
                        self.offset = -width - leadingSafeAreaInset // fully closed side menu
                    } else {
                        self.offset = leadingSafeAreaInset // fully open side menu
                    }
                }
            }
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
