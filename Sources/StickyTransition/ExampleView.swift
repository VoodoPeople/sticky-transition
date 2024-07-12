//
//  ExampleView.swift
//  okkantor
//
//  Created by Ivan Shushka on 12/07/2024.
//  Copyright © 2024 any Finance. All rights reserved.
//

import SwiftUI

struct ExampleView<Content1: View, Content2: View>: View {
    @State var toggleView: Bool = true
    
    var contentView: Content1
    var contentView2: Content2
    var pullText1: String
    var pullText2: String
    
    var body: some View {
        if toggleView {
            contentView
                .transition(.opacity)
                .stickyInteraction(direction: .pullUp, transitionText: pullText1, onStateChange: { state in
                    if state == .released {
                        withAnimation(.bouncy(duration: 0.7)) {
                            toggleView.toggle()
                        }
                    }
                })
                
        } else {
            contentView2
                .transition(.opacity)
                .stickyInteraction(direction: .pullDown, transitionText: pullText2, onStateChange: { state in
                    if state == .released {
                        withAnimation(.bouncy(duration: 0.7)) {
                            toggleView.toggle()
                        }
                    }
                })
        }
    }
}

#Preview(body: {
    let contentView = VStack {
        Rectangle()
            .fill(.red)
            .overlay(content: {
                Text("View 1")
                    .foregroundColor(.white)
                    .font(.title)
            })
    }
    
    let contentView2 = VStack {
        Rectangle()
            .fill(.blue)
            .overlay(content: {
                Text("View 2")
                    .foregroundColor(.white)
                    .font(.title)
            })
    }
    
    return ExampleView(contentView: contentView, contentView2: contentView2, pullText1: "Open", pullText2: "Back")
})
