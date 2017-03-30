import Foundation
import MortonSwift

// TODO: port region functionality

private let PI: Double = 3.1415926535897931

public class Point {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public class Hex {
    public let q: Int64
    public let r: Int64

    public init(q: Int64, r: Int64) {
        self.q = q
        self.r = r
    }
}

public class FractionalHex {
    public let q: Double
    public let r: Double

    public init(q: Double, r: Double) {
        self.q = q
        self.r = r
    }

    public func toHex() -> Hex {
        let s = -(q + r)
        var rq: Double = round(q)
        var rr: Double = round(r)
        let rs: Double = round(s)
        let qDiff: Double = abs(rq - q)
        let rDiff: Double = abs(rr - r)
        let sDiff: Double = abs(rs - s)

        if qDiff > rDiff && qDiff > sDiff {
                rq = -(rr + rs)
        } else if rDiff > sDiff {
                rr = -(rq + rs)
        }

        return Hex(q: Int64(rq), r: Int64(rr))
    }
}

public class Orientation {
    let f: [Double]
    let b: [Double]
    let startAngle: Double
    let sinuses: [Double]
    let cosinuses: [Double]

    public init(f: [Double], b: [Double], startAngle: Double) {
        var sinuses: [Double] = []
        var cosinuses: [Double] = []
        var i: Int = 0
        while i < 6 {
            let angle = 2.0 * PI * (Double(i) + startAngle) / 6.0
            sinuses.append(sin(angle))
            cosinuses.append(cos(angle))
            i += 1
        }
        self.f = f
        self.b = b
        self.startAngle = startAngle
        self.sinuses = sinuses
        self.cosinuses = cosinuses
    }
}

public let OrientationPointy: Orientation = Orientation(
  f: [sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0],
  b: [sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0],
  startAngle: 0.5)

public let OrientationFlat: Orientation = Orientation(
  f: [3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0)],
  b: [2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0],
  startAngle: 0.0)

public class Grid {
    let orientation: Orientation
    let origin: Point
    let size: Point
    let mort: Morton64

    public init(orientation: Orientation, origin: Point, size: Point, mort: Morton64) {
        self.orientation = orientation
        self.origin = origin
        self.size = size
        self.mort = mort
    }

    public func hexToCode(hex: Hex) throws -> Int64 {
        return try mort.sPack([hex.q, hex.r])
    }

    public func hexFromCode(code: Int64) -> Hex {
        let qr: [Int64] = mort.sUnpack(code)
        return Hex(q: qr[0], r: qr[1])
    }

    public func hexAt(point: Point) -> Hex {
        let x: Double = (point.x - origin.x) / size.x
        let y: Double = (point.y - origin.y) / size.y
        let q: Double = orientation.b[0] * x + orientation.b[1] * y
        let r: Double = orientation.b[2] * x + orientation.b[3] * y
        return FractionalHex(q: q, r: r).toHex()
    }

    public func hexCenter(hex: Hex) -> Point {
        let x: Double = (orientation.f[0] * Double(hex.q) + orientation.f[1] * Double(hex.r)) * size.x + origin.x
        let y: Double = (orientation.f[2] * Double(hex.q) + orientation.f[3] * Double(hex.r)) * size.y + origin.y
        return Point(x: x, y: y)
    }

    public func hexCorners(hex: Hex) -> [Point] {
        let center: Point = hexCenter(hex)
        return (0..<6).map {
            (i: Int) in Point(x: size.x * orientation.cosinuses[i] + center.x, y: size.y * orientation.sinuses[i] + center.y)
        }
    }

    public func hexNeighbors(hex: Hex, layers: Int64) -> [Hex] {
        var neighbors: [Hex] = []
        var q: Int64 = -layers
        while q <= layers {
            var r: Int64 = max(-layers, -q - layers)
            let rmax: Int64 = min(layers, -q + layers)
            while r <= rmax {
                if q != 0 || r != 0 {
                    neighbors.append(Hex(q: q + hex.q, r: r + hex.r))
                }
                r += 1
            }
            q += 1
        }
        return neighbors
    }
}
