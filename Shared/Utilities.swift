//
//  Utilities.swift
//  SlideOutMenu
//
//  Created by Mark Borazio [Personal] on 16/10/22.
//

import SwiftUI

extension CGSize {
    
    public static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    public static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Read Size

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
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

// MARK: - Read Safe Area Insets

private struct SafeAreaInsetsPreferenceKey: PreferenceKey {
    static var defaultValue: EdgeInsets = EdgeInsets()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {}
}

extension View {
    func readSafeAreaInsets(onChange: @escaping (EdgeInsets) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SafeAreaInsetsPreferenceKey.self, value: geometryProxy.safeAreaInsets)
            }
        )
        .onPreferenceChange(SafeAreaInsetsPreferenceKey.self, perform: onChange)
    }
}
