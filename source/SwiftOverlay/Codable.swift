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

/*
 Important: These Codable conformances are provided primarily for debugging purposes.
 If you're working with scene description data, the right way to serialize it is by
 reading/writing it as USD data using either UsdStage or SdfLayer.

 Last updated for v25.05.01. Note that the functionality/behavior of types can change
 between versions of OpenUSD, such as v25.05 when UsdTimeCode gained support for PreTime()
 values. SwiftUsd tries to ensure that changes in Codable conformances are handled gracefully
 between OpenUSD versions, but can't guarantee backwards/forwards compatibility.
 


 Implementation note: we can't guarantee that changes to OpenUSD that require updating
 Codable conformances will be caught at compile time. But, judicious use of `as` type hints
 in encoding implementations can catch changes to types that would otherwise not be caught
 due to type inference
 */


// MARK: Tf

extension pxr.TfToken: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode(String.self)

        self.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let x = String(self)
        
        try container.encode(x)
    }
}

// MARK: Gf

extension pxr.GfBBox3d: Codable {
    public enum CodingKeys: String, CodingKey {
        case box // pxr.GfRange3d
        case matrix // pxr.GfMatrix4d
        case hasZeroAreaPrimitives // Bool
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let box = try container.decode(pxr.GfRange3d.self, forKey: .box)
        let matrix = try container.decode(pxr.GfMatrix4d.self, forKey: .matrix)
        let hasZeroAreaPrimitives = try container.decode(Bool.self, forKey: .hasZeroAreaPrimitives)
        
        self.init(box, matrix)
        self.SetHasZeroAreaPrimitives(hasZeroAreaPrimitives)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.GetBox() as pxr.GfRange3d, forKey: .box)
        try container.encode(self.GetMatrix() as pxr.GfMatrix4d, forKey: .matrix)
        try container.encode(self.HasZeroAreaPrimitives() as Bool, forKey: .hasZeroAreaPrimitives)
    }
}

extension pxr.GfCamera.Projection: Codable {}

extension pxr.GfCamera: Codable {
    public enum CodingKeys: String, CodingKey {
        case transform // pxr.GfMatrix4d
        case projection // Projection
        case horizontalAperture // Float
        case verticalAperture // Float
        case horizontalApertureOffset // Float
        case verticalApertureOffset // Float
        case focalLength // Float
        case clippingRange // pxr.GfRange1f
        case clippingPlanes // std.vector<pxr.GfVec4f> => [pxr.GfVec4f]
        case fStop // Float
        case focusDistance // Float
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let transform = try container.decode(pxr.GfMatrix4d.self, forKey: .transform)
        let projection = try container.decode(pxr.GfCamera.Projection.self, forKey: .projection)
        let horizontalAperture = try container.decode(Float.self, forKey: .horizontalAperture)
        let verticalAperture = try container.decode(Float.self, forKey: .verticalAperture)
        let horizontalApertureOffset = try container.decode(Float.self, forKey: .horizontalApertureOffset)
        let verticalApertureOffset = try container.decode(Float.self, forKey: .verticalApertureOffset)
        let focalLength = try container.decode(Float.self, forKey: .focalLength)
        let clippingRange = try container.decode(pxr.GfRange1f.self, forKey: .clippingRange)
        let clippingPlanes = try container.decode([pxr.GfVec4f].self, forKey: .clippingPlanes)
        let fStop = try container.decode(Float.self, forKey: .fStop)
        let focusDistance = try container.decode(Float.self, forKey: .focusDistance)
        
        self.init(transform, projection, horizontalAperture, verticalAperture,
                  horizontalApertureOffset, verticalApertureOffset, focalLength,
                  clippingRange,
                  .init(clippingPlanes), // std.vector<pxr.GfVec4f>.init(clippingPlanes)
                  fStop, focusDistance)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.GetTransform() as pxr.GfMatrix4d, forKey: .transform)
        try container.encode(self.GetProjection() as pxr.GfCamera.Projection, forKey: .projection)
        try container.encode(self.GetHorizontalAperture() as Float, forKey: .horizontalAperture)
        try container.encode(self.GetVerticalAperture() as Float, forKey: .verticalAperture)
        try container.encode(self.GetHorizontalApertureOffset() as Float, forKey: .horizontalApertureOffset)
        try container.encode(self.GetVerticalApertureOffset() as Float, forKey: .verticalApertureOffset)
        try container.encode(self.GetFocalLength() as Float, forKey: .focalLength)
        try container.encode(self.GetClippingRange() as pxr.GfRange1f, forKey: .clippingRange)
        try container.encode(Array(self.GetClippingPlanes() as Overlay.GfVec4f_Vector), forKey: .clippingPlanes)
        try container.encode(self.GetFStop() as Float, forKey: .fStop)
        try container.encode(self.GetFocusDistance() as Float, forKey: .focusDistance)
    }
}

extension pxr.GfColor: Codable {
    public enum CodingKeys: String, CodingKey {
        case colorSpace // pxr.GfColorSpace
        case rgb // pxr.GfVec3f
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let colorSpace = try container.decode(pxr.GfColorSpace.self, forKey: .colorSpace)
        let rgb = try container.decode(pxr.GfVec3f.self, forKey: .rgb)

        self.init(rgb, colorSpace)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetColorSpace() as pxr.GfColorSpace, forKey: .colorSpace)
        try container.encode(self.GetRGB() as pxr.GfVec3f, forKey: .rgb)
    }
}

extension pxr.GfColorSpace: Codable {
    public enum CodingKeys: String, CodingKey {
        // Always present
        case name // pxr.TfToken

        // Present if not constructed only by a name
        case gamma // Float
        case linearBias // Float
        case rgbToXYZ // pxr.GfMatrix3f
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(pxr.TfToken.self, forKey: .name)

        if !container.contains(.gamma) {
            // Construct only by name
            if pxr.GfColorSpace.IsValid(name) {
                self.init(name)
                return

            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath,
                                                        debugDescription: "Invalid GfColorSpace name '\(name)'"))
            }
        }

        let gamma = try container.decode(Float.self, forKey: .gamma)
        let linearBias = try container.decode(Float.self, forKey: .linearBias)
        let rgbToXYZ = try container.decode(pxr.GfMatrix3f.self, forKey: .rgbToXYZ)
        self.init(name, rgbToXYZ, gamma, linearBias)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetName() as pxr.TfToken, forKey: .name)
        if self == pxr.GfColorSpace(self.GetName()) { return }

        try container.encode(self.GetGamma() as Float, forKey: .gamma)
        try container.encode(self.GetLinearBias() as Float, forKey: .linearBias)
        try container.encode(self.GetRGBToXYZ() as pxr.GfMatrix3f, forKey: .rgbToXYZ)
    }
}

extension pxr.GfDualQuatd: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // pxr.GfQuatd
        case dual // pxr.GfQuatd        
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(pxr.GfQuatd.self, forKey: .real)
        let dual = try container.decode(pxr.GfQuatd.self, forKey: .dual)

        self.init(real, dual)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as pxr.GfQuatd, forKey: .real)
        try container.encode(self.GetDual() as pxr.GfQuatd, forKey: .dual)
    }
}

extension pxr.GfDualQuatf: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // pxr.GfQuatf
        case dual // pxr.GfQuatf        
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(pxr.GfQuatf.self, forKey: .real)
        let dual = try container.decode(pxr.GfQuatf.self, forKey: .dual)

        self.init(real, dual)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as pxr.GfQuatf, forKey: .real)
        try container.encode(self.GetDual() as pxr.GfQuatf, forKey: .dual)
    }
}

extension pxr.GfDualQuath: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // pxr.GfQuath
        case dual // pxr.GfQuath        
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(pxr.GfQuath.self, forKey: .real)
        let dual = try container.decode(pxr.GfQuath.self, forKey: .dual)

        self.init(real, dual)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as pxr.GfQuath, forKey: .real)
        try container.encode(self.GetDual() as pxr.GfQuath, forKey: .dual)
    }
}

extension pxr.GfFrustum.ProjectionType: Codable {}

extension pxr.GfFrustum: Codable {
    public enum CodingKeys: String, CodingKey {
        case position // pxr.GfVec3d
        case rotation // pxr.GfRotation
        case window // pxr.GfRange2d
        case nearFar // pxr.GfRange1d
        case viewDistance // Double
        case projectionType // pxr.GfFrustum.ProjectionType
        // _planes intentionally omitted
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let position = try container.decode(pxr.GfVec3d.self, forKey: .position)
        let rotation = try container.decode(pxr.GfRotation.self, forKey: .rotation)
        let window = try container.decode(pxr.GfRange2d.self, forKey: .window)
        let nearFar = try container.decode(pxr.GfRange1d.self, forKey: .nearFar)
        let viewDistance = try container.decode(Double.self, forKey: .viewDistance)
        let projectionType = try container.decode(pxr.GfFrustum.ProjectionType.self, forKey: .projectionType)

        self.init(position, rotation, window, nearFar, projectionType, viewDistance)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetPosition() as pxr.GfVec3d, forKey: .position)
        try container.encode(self.GetRotation() as pxr.GfRotation, forKey: .rotation)
        try container.encode(self.GetWindow() as pxr.GfRange2d, forKey: .window)
        try container.encode(self.GetNearFar() as pxr.GfRange1d, forKey: .nearFar)
        try container.encode(self.GetViewDistance() as Double, forKey: .viewDistance)
        try container.encode(self.GetProjectionType() as pxr.GfFrustum.ProjectionType, forKey: .projectionType)
    }
}

extension pxr.GfHalf: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode(Float.self)
        
        self.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()

        let x = Float(self)

        try container.encode(x)
    }
}

extension pxr.GfInterval: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // Double
        case max // Double
        case minClosed // Bool
        case maxClosed // Bool
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(Double.self, forKey: .min)
        let max = try container.decode(Double.self, forKey: .max)
        let minClosed = try container.decode(Bool.self, forKey: .minClosed)
        let maxClosed = try container.decode(Bool.self, forKey: .maxClosed)

        self.init(min, max, minClosed, maxClosed)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as Double, forKey: .min)
        try container.encode(self.GetMax() as Double, forKey: .max)
        try container.encode(self.IsMinClosed() as Bool, forKey: .minClosed)
        try container.encode(self.IsMaxClosed() as Bool, forKey: .maxClosed)
    }
}

extension pxr.GfLine: Codable {
    public enum CodingKeys: String, CodingKey {
        case point // pxr.GfVec3d
        case direction // pxr.GfVec3d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let point = try container.decode(pxr.GfVec3d.self, forKey: .point)
        let direction = try container.decode(pxr.GfVec3d.self, forKey: .direction)

        self.init(point, direction)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetPoint(0) as pxr.GfVec3d, forKey: .point)
        try container.encode(self.GetDirection() as pxr.GfVec3d, forKey: .direction)
    }
}

extension pxr.GfLine2d: Codable {
    public enum CodingKeys: String, CodingKey {
        case point // pxr.GfVec2d
        case direction // pxr.GfVec2d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let point = try container.decode(pxr.GfVec2d.self, forKey: .point)
        let direction = try container.decode(pxr.GfVec2d.self, forKey: .direction)

        self.init(point, direction)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetPoint(0) as pxr.GfVec2d, forKey: .point)
        try container.encode(self.GetDirection() as pxr.GfVec2d, forKey: .direction)
    }
}

extension pxr.GfLineSeg: Codable {
    public enum CodingKeys: String, CodingKey {
        case p0 // pxr.GfVec3d
        case p1 // pxr.GfVec3d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let p0 = try container.decode(pxr.GfVec3d.self, forKey: .p0)
        let p1 = try container.decode(pxr.GfVec3d.self, forKey: .p1)

        self.init(p0, p1)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetPoint(0) as pxr.GfVec3d, forKey: .p0)
        try container.encode(self.GetPoint(1) as pxr.GfVec3d, forKey: .p1)
    }
}

extension pxr.GfMatrix2d: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let row0 = try container.decode(pxr.GfVec2d.self)
        let row1 = try container.decode(pxr.GfVec2d.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfMatrix2d should be two rows")
        }

        self.init(row0[0], row0[1],
                  row1[0], row1[1])
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self.GetRow(0) as pxr.GfVec2d)
        try container.encode(self.GetRow(1) as pxr.GfVec2d)
    }
}

extension pxr.GfMatrix2f: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let row0 = try container.decode(pxr.GfVec2f.self)
        let row1 = try container.decode(pxr.GfVec2f.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfMatrix2f should be two rows")
        }

        self.init(row0[0], row0[1],
                  row1[0], row1[1])
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self.GetRow(0) as pxr.GfVec2f)
        try container.encode(self.GetRow(1) as pxr.GfVec2f)
    }
}

extension pxr.GfMatrix3d: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let row0 = try container.decode(pxr.GfVec3d.self)
        let row1 = try container.decode(pxr.GfVec3d.self)
        let row2 = try container.decode(pxr.GfVec3d.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfMatrix3d should be three rows")
        }

        self.init(row0[0], row0[1], row0[2],
                  row1[0], row1[1], row1[2],
                  row2[0], row2[1], row2[2])
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self.GetRow(0) as pxr.GfVec3d)
        try container.encode(self.GetRow(1) as pxr.GfVec3d)
        try container.encode(self.GetRow(2) as pxr.GfVec3d)
    }
}

extension pxr.GfMatrix3f: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let row0 = try container.decode(pxr.GfVec3f.self)
        let row1 = try container.decode(pxr.GfVec3f.self)
        let row2 = try container.decode(pxr.GfVec3f.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfMatrix3f should be three rows")
        }

        self.init(row0[0], row0[1], row0[2],
                  row1[0], row1[1], row1[2],
                  row2[0], row2[1], row2[2])
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self.GetRow(0) as pxr.GfVec3f)
        try container.encode(self.GetRow(1) as pxr.GfVec3f)
        try container.encode(self.GetRow(2) as pxr.GfVec3f)
    }
}

extension pxr.GfMatrix4d: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let row0 = try container.decode(pxr.GfVec4d.self)
        let row1 = try container.decode(pxr.GfVec4d.self)
        let row2 = try container.decode(pxr.GfVec4d.self)
        let row3 = try container.decode(pxr.GfVec4d.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfMatrix4d should be four rows")
        }

        self.init(row0[0], row0[1], row0[2], row0[3],
                  row1[0], row1[1], row1[2], row1[3],
                  row2[0], row2[1], row2[2], row2[3],
                  row3[0], row3[1], row3[2], row3[3])
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self.GetRow(0) as pxr.GfVec4d)
        try container.encode(self.GetRow(1) as pxr.GfVec4d)
        try container.encode(self.GetRow(2) as pxr.GfVec4d)
        try container.encode(self.GetRow(3) as pxr.GfVec4d)
    }
}

extension pxr.GfMatrix4f: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let row0 = try container.decode(pxr.GfVec4f.self)
        let row1 = try container.decode(pxr.GfVec4f.self)
        let row2 = try container.decode(pxr.GfVec4f.self)
        let row3 = try container.decode(pxr.GfVec4f.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfMatrix4f should be four rows")
        }

        self.init(row0[0], row0[1], row0[2], row0[3],
                  row1[0], row1[1], row1[2], row1[3],
                  row2[0], row2[1], row2[2], row2[3],
                  row3[0], row3[1], row3[2], row3[3])
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self.GetRow(0) as pxr.GfVec4f)
        try container.encode(self.GetRow(1) as pxr.GfVec4f)
        try container.encode(self.GetRow(2) as pxr.GfVec4f)
        try container.encode(self.GetRow(3) as pxr.GfVec4f)
    }
}

extension pxr.GfMultiInterval: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode([pxr.GfInterval].self)

        self.init(.init(x)) // std.vector<GfInterval>.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()

        let x = Array(self)

        try container.encode(x)
    }
}

extension pxr.GfPlane: Codable {
    public enum CodingKeys: String, CodingKey {
        case normal // pxr.GfVec3d
        case distance // Double
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let normal = try container.decode(pxr.GfVec3d.self, forKey: .normal)
        let distance = try container.decode(Double.self, forKey: .distance)

        self.init(normal, distance)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetNormal() as pxr.GfVec3d, forKey: .normal)
        try container.encode(self.GetDistanceFromOrigin() as Double, forKey: .distance)
    }
}

extension pxr.GfQuatd: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // Double
        case imaginary // pxr.GfVec3d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(Double.self, forKey: .real)
        let imaginary = try container.decode(pxr.GfVec3d.self, forKey: .imaginary)

        self.init(real, imaginary)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as Double, forKey: .real)
        try container.encode(self.GetImaginary() as pxr.GfVec3d, forKey: .imaginary)
    }
}

extension pxr.GfQuaternion: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // Double
        case imaginary // pxr.GfVec3d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(Double.self, forKey: .real)
        let imaginary = try container.decode(pxr.GfVec3d.self, forKey: .imaginary)

        self.init(real, imaginary)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as Double, forKey: .real)
        try container.encode(self.GetImaginary() as pxr.GfVec3d, forKey: .imaginary)
    }
}

extension pxr.GfQuatf: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // Double
        case imaginary // pxr.GfVec3f
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(Float.self, forKey: .real)
        let imaginary = try container.decode(pxr.GfVec3f.self, forKey: .imaginary)

        self.init(real, imaginary)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as Float, forKey: .real)
        try container.encode(self.GetImaginary() as pxr.GfVec3f, forKey: .imaginary)
    }
}

extension pxr.GfQuath: Codable {
    public enum CodingKeys: String, CodingKey {
        case real // Double
        case imaginary // pxr.GfVec3h
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let real = try container.decode(pxr.GfHalf.self, forKey: .real)
        let imaginary = try container.decode(pxr.GfVec3h.self, forKey: .imaginary)

        self.init(real, imaginary)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetReal() as pxr.GfHalf, forKey: .real)
        try container.encode(self.GetImaginary() as pxr.GfVec3h, forKey: .imaginary)
    }
}

extension pxr.GfRange1d: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // Double
        case max // Double
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(Double.self, forKey: .min)
        let max = try container.decode(Double.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as Double, forKey: .min)
        try container.encode(self.GetMax() as Double, forKey: .max)
    }
}

extension pxr.GfRange1f: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // Float
        case max // Float
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(Float.self, forKey: .min)
        let max = try container.decode(Float.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as Float, forKey: .min)
        try container.encode(self.GetMax() as Float, forKey: .max)
    }
}

extension pxr.GfRange2d: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // pxr.GfVec2d
        case max // pxr.GfVec2d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(pxr.GfVec2d.self, forKey: .min)
        let max = try container.decode(pxr.GfVec2d.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as pxr.GfVec2d, forKey: .min)
        try container.encode(self.GetMax() as pxr.GfVec2d, forKey: .max)
    }
}

extension pxr.GfRange2f: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // pxr.GfVec2f
        case max // pxr.GfVec2f
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(pxr.GfVec2f.self, forKey: .min)
        let max = try container.decode(pxr.GfVec2f.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as pxr.GfVec2f, forKey: .min)
        try container.encode(self.GetMax() as pxr.GfVec2f, forKey: .max)
    }
}

extension pxr.GfRange3d: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // pxr.GfVec3d
        case max // pxr.GfVec3d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(pxr.GfVec3d.self, forKey: .min)
        let max = try container.decode(pxr.GfVec3d.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as pxr.GfVec3d, forKey: .min)
        try container.encode(self.GetMax() as pxr.GfVec3d, forKey: .max)
    }
}

extension pxr.GfRange3f: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // pxr.GfVec3f
        case max // pxr.GfVec3f
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(pxr.GfVec3f.self, forKey: .min)
        let max = try container.decode(pxr.GfVec3f.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as pxr.GfVec3f, forKey: .min)
        try container.encode(self.GetMax() as pxr.GfVec3f, forKey: .max)
    }
}

extension pxr.GfRay: Codable {
    public enum CodingKeys: String, CodingKey {
        case startPoint // pxr.GfVec3d
        case direction // pxr.GfVec3d        
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let startPoint = try container.decode(pxr.GfVec3d.self, forKey: .startPoint)
        let direction = try container.decode(pxr.GfVec3d.self, forKey: .direction)

        self.init(startPoint, direction)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetStartPoint() as pxr.GfVec3d, forKey: .startPoint)
        try container.encode(self.GetDirection() as pxr.GfVec3d, forKey: .direction)
    }
}

extension pxr.GfRect2i: Codable {
    public enum CodingKeys: String, CodingKey {
        case min // pxr.GfVec2i
        case max // pxr.GfVec2i
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let min = try container.decode(pxr.GfVec2i.self, forKey: .min)
        let max = try container.decode(pxr.GfVec2i.self, forKey: .max)

        self.init(min, max)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetMin() as pxr.GfVec2i, forKey: .min)
        try container.encode(self.GetMax() as pxr.GfVec2i, forKey: .max)
    }
}

extension pxr.GfRotation: Codable {
    public enum CodingKeys: String, CodingKey {
        case axis // pxr.GfVec3d
        case angle // Double
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let axis = try container.decode(pxr.GfVec3d.self, forKey: .axis)
        let angle = try container.decode(Double.self, forKey: .angle)

        self.init(axis, angle)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetAxis() as pxr.GfVec3d, forKey: .axis)
        try container.encode(self.GetAngle() as Double, forKey: .angle)
    }
}

extension pxr.GfSize2: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let v0 = try container.decode(Int.self)
        let v1 = try container.decode(Int.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVecSize2 should have two elements")
        }

        self.init(v0, v1)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Int)
        try container.encode(self[1] as Int)
    }
}

extension pxr.GfSize3: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let v0 = try container.decode(Int.self)
        let v1 = try container.decode(Int.self)
        let v2 = try container.decode(Int.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVecSize3 should have three elements")
        }

        self.init(v0, v1, v2)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Int)
        try container.encode(self[1] as Int)
        try container.encode(self[2] as Int)
    }
}

extension pxr.GfTransform: Codable {
    public enum CodingKeys: String, CodingKey {
        case translation // pxr.GfVec3d
        case rotation // pxr.GfRotation
        case scale // pxr.GfVec3d
        case pivotOrientation // pxr.GfRotation
        case pivotPosition // pxr.GfVec3d
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let translation = try container.decode(pxr.GfVec3d.self, forKey: .translation)
        let rotation = try container.decode(pxr.GfRotation.self, forKey: .rotation)
        let scale = try container.decode(pxr.GfVec3d.self, forKey: .scale)
        let pivotOrientation = try container.decode(pxr.GfRotation.self, forKey: .pivotOrientation)
        let pivotPosition = try container.decode(pxr.GfVec3d.self, forKey: .pivotPosition)

        self.init(scale, pivotOrientation, rotation, pivotPosition, translation)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.GetTranslation() as pxr.GfVec3d, forKey: .translation)
        try container.encode(self.GetRotation() as pxr.GfRotation, forKey: .rotation)
        try container.encode(self.GetScale() as pxr.GfVec3d, forKey: .scale)
        try container.encode(self.GetPivotOrientation() as pxr.GfRotation, forKey: .pivotOrientation)
        try container.encode(self.GetPivotPosition() as pxr.GfVec3d, forKey: .pivotPosition)
    }
}

extension pxr.GfVec2d: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Double.self)
        let x1 = try container.decode(Double.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec2d should be two elements")
        }

        self.init(x0, x1)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Double)
        try container.encode(self[1] as Double)
    }
}

extension pxr.GfVec2f: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Float.self)
        let x1 = try container.decode(Float.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec2f should be two elements")
        }

        self.init(x0, x1)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Float)
        try container.encode(self[1] as Float)
    }
}

extension pxr.GfVec2h: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(pxr.GfHalf.self)
        let x1 = try container.decode(pxr.GfHalf.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec2h should be two elements")
        }

        self.init(x0, x1)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as pxr.GfHalf)
        try container.encode(self[1] as pxr.GfHalf)
    }
}

extension pxr.GfVec2i: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Int32.self)
        let x1 = try container.decode(Int32.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec2i should be two elements")
        }

        self.init(x0, x1)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Int32)
        try container.encode(self[1] as Int32)
    }
}

extension pxr.GfVec3d: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Double.self)
        let x1 = try container.decode(Double.self)
        let x2 = try container.decode(Double.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec3d should be three elements")
        }

        self.init(x0, x1, x2)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Double)
        try container.encode(self[1] as Double)
        try container.encode(self[2] as Double)
    }
}

extension pxr.GfVec3f: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Float.self)
        let x1 = try container.decode(Float.self)
        let x2 = try container.decode(Float.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec3f should be three elements")
        }

        self.init(x0, x1, x2)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Float)
        try container.encode(self[1] as Float)
        try container.encode(self[2] as Float)
    }
}

extension pxr.GfVec3h: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(pxr.GfHalf.self)
        let x1 = try container.decode(pxr.GfHalf.self)
        let x2 = try container.decode(pxr.GfHalf.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec3h should be three elements")
        }

        self.init(x0, x1, x2)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as pxr.GfHalf)
        try container.encode(self[1] as pxr.GfHalf)
        try container.encode(self[2] as pxr.GfHalf)
    }
}

extension pxr.GfVec3i: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Int32.self)
        let x1 = try container.decode(Int32.self)
        let x2 = try container.decode(Int32.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec3i should be three elements")
        }

        self.init(x0, x1, x2)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Int32)
        try container.encode(self[1] as Int32)
        try container.encode(self[2] as Int32)
    }
}

extension pxr.GfVec4d: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Double.self)
        let x1 = try container.decode(Double.self)
        let x2 = try container.decode(Double.self)
        let x3 = try container.decode(Double.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec4d should be four elements")
        }

        self.init(x0, x1, x2, x3)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Double)
        try container.encode(self[1] as Double)
        try container.encode(self[2] as Double)
        try container.encode(self[3] as Double)
    }
}

extension pxr.GfVec4f: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Float.self)
        let x1 = try container.decode(Float.self)
        let x2 = try container.decode(Float.self)
        let x3 = try container.decode(Float.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec4f should be four elements")
        }

        self.init(x0, x1, x2, x3)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Float)
        try container.encode(self[1] as Float)
        try container.encode(self[2] as Float)
        try container.encode(self[3] as Float)
    }
}

extension pxr.GfVec4h: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(pxr.GfHalf.self)
        let x1 = try container.decode(pxr.GfHalf.self)
        let x2 = try container.decode(pxr.GfHalf.self)
        let x3 = try container.decode(pxr.GfHalf.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec4h should be four elements")
        }

        self.init(x0, x1, x2, x3)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as pxr.GfHalf)
        try container.encode(self[1] as pxr.GfHalf)
        try container.encode(self[2] as pxr.GfHalf)
        try container.encode(self[3] as pxr.GfHalf)
    }
}

extension pxr.GfVec4i: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let x0 = try container.decode(Int32.self)
        let x1 = try container.decode(Int32.self)
        let x2 = try container.decode(Int32.self)
        let x3 = try container.decode(Int32.self)

        guard container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "GfVec4i should be four elements")
        }

        self.init(x0, x1, x2, x3)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        try container.encode(self[0] as Int32)
        try container.encode(self[1] as Int32)
        try container.encode(self[2] as Int32)
        try container.encode(self[3] as Int32)
    }
}

// MARK: Vt

extension __Overlay.VtArray_Codable where ElementType: Codable, Self: __Overlay.VtArray_ExpressibleByArrayLiteral, Self: __Overlay.VtArray_Sequence, ElementType == Element, ElementType == ArrayLiteralElement {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        self.init()
        self.reserve(container.count ?? 0)
        while !container.isAtEnd {
            self.push_back(try container.decode(ElementType.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        for x in self {
            try container.encode(x)
        }
    }
}
// CxxStdlib doesn't conform std.string to Codable, so we can't use the above implementation
extension pxr.VtStringArray: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        self.init()
        self.reserve(container.count ?? 0)
        while !container.isAtEnd {
            self.push_back(std.string(try container.decode(String.self)))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()

        for x in self {
            try container.encode(String(x))
        }
    }    
}

// MARK: Ar

extension pxr.ArResolvedPath: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode(String.self)

        self.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()

        let x = String(self)

        try container.encode(x)
    }
}

extension pxr.ArTimestamp: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode(Double.self)

        self.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()

        let x = self.GetTime()

        try container.encode(self.GetTime() as Double)
    }
}

// MARK: Sdf

extension pxr.SdfAssetPath: Codable {
    public enum CodingKeys: String, CodingKey {
        case authoredPath // std.string => String
        case evaluatedPath // std.string => String
        case resolvedPath // std.string => String
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)

        let authoredPath = try container.decode(String.self, forKey: .authoredPath)
        let evaluatedPath = try container.decode(String.self, forKey: .evaluatedPath)
        let resolvedPath = try container.decode(String.self, forKey: .resolvedPath)

        self.init(pxr.SdfAssetPathParams().Authored(std.string(authoredPath))
                                          .Evaluated(std.string(evaluatedPath))
                                          .Resolved(std.string(resolvedPath)))
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(String(self.GetAuthoredPath() as std.string), forKey: .authoredPath)
        try container.encode(String(self.GetEvaluatedPath() as std.string), forKey: .evaluatedPath)
        try container.encode(String(self.GetResolvedPath() as std.string), forKey: .resolvedPath)
    }
}

extension pxr.SdfPath: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode(String.self)

        self.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()

        let x = String(self)

        try container.encode(x)
    }
}

extension pxr.SdfTimeCode: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        let x = try container.decode(Double.self)

        self.init(x)
    }

    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()

        try container.encode(self.GetValue() as Double)
    }
}


// MARK: Usd

extension pxr.UsdTimeCode: Codable {
    // Default time code is always encoded as `"nan"`,
    // pre-time codes are always encoded as `"pre` + `GetValue()` + `"`,
    // all other time codes are encoded as `GetValue()`
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()

        if let x = try? container.decode(Double.self) {
            self.init(x)
            return
        } else if let x = try? container.decode(String.self) {
            if x == "nan" {
                self = .Default()
                return
            }

            if x.hasPrefix("pre") {
                if let value = Double(String(x.dropFirst("pre".count))) {
                    self = .PreTime(value)
                    return
                }
            }
        }

        throw DecodingError.dataCorruptedError(in: container,
                                               debugDescription: "Invalid UsdTimeCode data")
    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if self.IsDefault() {
            try container.encode("nan")
        } else if self.IsPreTime() {
            try container.encode("pre\(self.GetValue() as Double)")
        } else {
            try container.encode(self.GetValue() as Double)
        }
    }
}

