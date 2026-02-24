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

/// A disclosure group with a customizable initial expansion state
struct InitialStateDisclosureGroup<Label, Content>: View where Label: View, Content: View {
    var label: Label
    var content: () -> Content
    @State private var isExpanded: Bool
    
    init(isInitiallyExpanded: Bool, @ViewBuilder content: @escaping () -> Content, @ViewBuilder label: () -> Label) {
        self.label = label()
        self._isExpanded = State(initialValue: isInitiallyExpanded)
        self.content = content
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: content, label: { label })
    }
}
