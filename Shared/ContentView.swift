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
        mainView
            .withSideView(isOpen: $isOpen) {
                sideView
            }
    }
    
    private var mainView: some View {
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
    }
    
    private var sideView: some View {
        ScrollView {
            HStack(alignment: .top) {
                VStack {
                    Spacer()
                    ForEach(1..<101) { index in
                        Text("\(index)")
                    }
                    Spacer()
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
                VStack {
                    Spacer()
                    ForEach(1..<101) { index in
                        Text("\(index)")
                    }
                    Spacer()
                }
            }
        }
        .frame(width: 300)
        .background(Color.blue.ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
