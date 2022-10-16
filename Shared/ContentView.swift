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
                ScrollView {
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
