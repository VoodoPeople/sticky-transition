//
//  StickyTransitionModifier.swift
//  StickyTransition
//
//  Created by Ivan Shushka on 11/07/2024.
//  Copyright © 2024 any Finance. All rights reserved.
//

import SwiftUI

// MARK: - Public

public enum PullDirection {
    case pullDown
    case pullUp
}

public enum TransitionState {
    case pull
    case release
    case released
}

public extension View {
    func stickyInteraction(direction: PullDirection, transitionText: String, onStateChange onChange: @escaping (TransitionState) -> Void) -> some View {
        modifier(StickyTransitionModifier(pullViewText: transitionText, direction: direction, stateChange: onChange))
    }
}

// MARK: - Internal

struct StickyTransitionModifier: ViewModifier {
    @State var pullViewText: String = ""
    
    var transitionThreashold: CGFloat = 130
    @State var scrollProgress: CGFloat = 0.0
    @State var pullViewHeight: CGFloat = 20
    @State var pullingState: TransitionState = .pull {
        didSet {
            stateChange(pullingState)
        }
    }
    
    var direction: PullDirection
    var stateChange: (TransitionState) -> Void
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            ZStack(alignment: direction == .pullDown ? .top : .bottom)
            {
                pullView()
                ScrollView {
                    LazyVStack {
                        content
                            .containerRelativeFrame(.horizontal)
                            .containerRelativeFrame(.vertical)
                    }
                    .containerRelativeFrame(.horizontal)
                    .containerRelativeFrame(.vertical)
                    .scrollTargetLayout()
                    .onChangeOffset { handle(offset: $0) }
                    .visualEffect { content, geometryProxy in
                        content.offset(y: scrollOffset(geometryProxy))
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .scrollTargetBehavior(CustomScrollTargetBehavior(velocity: {
                    handle(velocity: $0)
                }))
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private func pullView() -> some View {
        HStack {
            Text( "\(pullingState == .pull ? "Pull to" : "Release to")")
            Text(pullViewText).bold()
            Image(systemName: "arrow.down.circle.dotted").font(.title2)
        }
        .frame(height: pullViewHeight)
        .opacity(pullViewOpacity(for: scrollProgress))
        .scaleEffect(pullViewScaleFactor(for: scrollProgress))
        .offset(y: scrollProgress / 2)
    }
         
     // MARK: - Private
     private func pullViewOpacity(for progress: CGFloat) -> CGFloat {
         let progressVal = abs(min(progress, 100))
         return (progressVal - 20) / 50
     }
     
     private func pullViewScaleFactor(for progress: CGFloat) -> CGFloat {
         // TODO: add scale
         1.0
     }
     
     private func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
         let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
         return direction == .pullUp
         ? (minY > 0 ? -minY : 0)
         : (minY < 0 ? -minY : 0)
     }
     
     private func handle(offset value: CGFloat) {
         scrollProgress = value
         let newState: TransitionState = abs(value) > transitionThreashold ? .release : .pull
         if pullingState == newState { return }
         if newState == .release {
             #if os(iOS)
             HapticSupportiOSImpl.generateHapticFeedback()
             #endif
         }
         pullingState = newState
     }
    
    private func handle(velocity: CGVector) {
        if pullingState == .pull { return }
        if pullingState == .release
            && direction == .pullDown ? velocity.dy <= 0 : velocity.dy >= 0 {
            pullingState = .released
        }
    }
}

// MARK: - ScrollTargetBehavior to track view velocity

struct CustomScrollTargetBehavior: ScrollTargetBehavior {
    var velocity: (CGVector) -> Void
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        self.velocity(context.velocity)
    }
}

// MARK: - Track scrollView scroll offset

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func onChangeOffset(_ completion: @escaping (CGFloat) -> Void) -> some View {
        self.overlay {
            GeometryReader {
                let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
                Color.clear
                    .preference(key: OffsetKey.self, value: minY)
                    .onPreferenceChange(OffsetKey.self, perform: completion)
            }
        }
    }
}

#if os(iOS)
import UIKit

protocol HapticSupport {
    static func generateHapticFeedback()
}

final class HapticSupportiOSImpl: HapticSupport {
    private init() {}

    private static let generator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()

    static func generateHapticFeedback() {
        generator.impactOccurred()
    }
}

final class HapticSupportFallbackImpl: HapticSupport {
    static func generateHapticFeedback() {
      // DO nothing
    }
}
#endif
