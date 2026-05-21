//===----------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0
//===----------------------------------------------------------------------===//

import Foundation
import SwiftUI

/// A VSplitView with a show-hide button that enforces a minimum height on its footer
struct SnappingVSplitView<Content: View, Footer: View>: View {
    let minimumBottomHeight: Double
    let hideDragBottomHeightThreshold: Double
    
    init(defaultBottomHeight: Double = 350, minimumBottomHeight: Double = 150, hideDragBottomHeightThreshold: Double = 75,
         @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self._bottomHeight = .init(initialValue: defaultBottomHeight >= minimumBottomHeight ? defaultBottomHeight : 0)
        self.minimumBottomHeight = minimumBottomHeight
        self.hideDragBottomHeightThreshold = hideDragBottomHeightThreshold
        self.content = content()
        self.footer = footer()
    }

    // Negative means hidden. Preserve the negative value so if the user shows with a button press,
    // we can restore their old height
    @State private var bottomHeight: Double
    @ViewBuilder var content: Content
    @ViewBuilder var footer: Footer
    
    @State private var bottomHeightOnGestureStart: Double?
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                content
                
                Group {
                    Divider()
                    HStack {
                        Spacer()
                        Button {
                            bottomHeight = -bottomHeight
                        } label: {
                            Image(systemName: "inset.filled.bottomthird.square")
                                .foregroundStyle(bottomHeight > hideDragBottomHeightThreshold ? .blue : .secondary)
                        }
                        .buttonStyle(.borderless)
                        .padding([.trailing])
                        .focusable(false)
                        .pointerStyle(.default)
                    }
                    .frame(height: 32)
                    Divider()
                }
                .background(.background)
                .contentShape(Rectangle())
                .pointerStyle(.rowResize(directions: bottomHeight >= minimumBottomHeight ? .all : .up))
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("SnappingVSplitView.VStack"))
                        .onChanged { x in
                            if bottomHeightOnGestureStart == nil {
                                bottomHeightOnGestureStart = max(bottomHeight, 0)
                            }
                            else {
                                bottomHeight = min(bottomHeightOnGestureStart! - x.translation.height, proxy.size.height)
                            }
                        }
                        .onEnded { x in
                            bottomHeightOnGestureStart = nil
                            
                            if bottomHeight > minimumBottomHeight { /* pass */ }
                            else if bottomHeight > hideDragBottomHeightThreshold { bottomHeight = minimumBottomHeight }
                            else { bottomHeight = -minimumBottomHeight }
                        }
                )
                
                if bottomHeight > hideDragBottomHeightThreshold {
                    footer
                        .frame(height: max(min(bottomHeight, proxy.size.height), minimumBottomHeight))
                }
            }
        }
        .coordinateSpace(name: "SnappingVSplitView.VStack")
    }
}

extension View {
    /// Puts `self` within a `SnappingVSplitView` with the argument as the footer
    func withSnappingVSplitView<Footer: View>(@ViewBuilder footer: () -> Footer) -> some View {
        SnappingVSplitView  {
            self
        } footer: {
            footer()
        }
    }
}
