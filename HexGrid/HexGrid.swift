import Foundation

import Morton

// TODO: port region functionality

public struct Point {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct Hex {
    public let q: Int64
    public let r: Int64

    public init(q: Int64, r: Int64) {
        self.q = q
        self.r = r
    }
}

public struct FractionalHex {
    public let q: Double
    public let r: Double

    public init(q: Double, r: Double) {
        self.q = q
        self.r = r
    }

    public func toHex() -> Hex {
        let s = -(q + r)
        var rq = round(q)
        var rr = round(r)
        let rs = round(s)
        let qDiff = abs(rq - q)
        let rDiff = abs(rr - r)
        let sDiff = abs(rs - s)

        if qDiff > rDiff && qDiff > sDiff {
            rq = -(rr + rs)
        } else if rDiff > sDiff {
            rr = -(rq + rs)
        }

        return Hex(q: Int64(rq), r: Int64(rr))
    }
}

public struct Orientation {
    let f: [Double]
    let b: [Double]
    let startAngle: Double
    let sines: [Double]
    let cosines: [Double]

    public init(f: [Double], b: [Double], startAngle: Double) {
        var sines: [Double] = []
        var cosines: [Double] = []
        var i: Int = 0
        while i < 6 {
            let angle = 2.0 * M_PI * (Double(i) + startAngle) / 6.0
            sines.append(sin(angle))
            cosines.append(cos(angle))
            i += 1
        }
        self.f = f
        self.b = b
        self.startAngle = startAngle
        self.sines = sines
        self.cosines = cosines
    }
}

public let OrientationPointy = Orientation(
    f: [sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0],
    b: [sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0],
    startAngle: 0.5
)

public let OrientationFlat = Orientation(
    f: [3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0)],
    b: [2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0],
    startAngle: 0.0
)

open class Grid {
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

    open func hexToCode(_ hex: Hex) throws -> Int64 {
        return try mort.sPack([hex.q, hex.r])
    }

    open func hexFromCode(_ code: Int64) -> Hex {
        let qr: [Int64] = mort.sUnpack(code)
        return Hex(q: qr[0], r: qr[1])
    }

    open func hexAt(_ point: Point) -> Hex {
        let x: Double = (point.x - origin.x) / size.x
        let y: Double = (point.y - origin.y) / size.y
        let q: Double = orientation.b[0] * x + orientation.b[1] * y
        let r: Double = orientation.b[2] * x + orientation.b[3] * y
        return FractionalHex(q: q, r: r).toHex()
    }

    open func hexCenter(_ hex: Hex) -> Point {
        let x: Double = (orientation.f[0] * Double(hex.q) + orientation.f[1] * Double(hex.r)) * size.x + origin.x
        let y: Double = (orientation.f[2] * Double(hex.q) + orientation.f[3] * Double(hex.r)) * size.y + origin.y
        return Point(x: x, y: y)
    }

    open func hexCorners(_ hex: Hex) -> [Point] {
        let center: Point = hexCenter(hex)
        return (0..<6).map {
            Point(x: size.x * orientation.cosines[$0] + center.x, y: size.y * orientation.sines[$0] + center.y)
        }
    }

    open func hexNeighbors(_ hex: Hex, layers: Int64) -> [Hex] {
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
