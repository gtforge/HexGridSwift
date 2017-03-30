import Foundation

import Quick
import Nimble

import MortonSwift
import HexGridSwift

final class HexGridSpec: QuickSpec {
    override func spec() {
        func doTestHexAtPoint(grid: Grid, expected: Hex, point: Point) {
            it("should create proper hex at \(point)") {
                let created: Hex = grid.hexAt(point)
                expect(created.q).to(equal(expected.q))
                expect(created.r).to(equal(expected.r))
            }
        }

        func doComparePoints(expected: Point, got: Point, precision: Double) {
            it("should create close enough points") {
                expect(abs(expected.x - got.x)).to(beLessThan(precision))
                expect(abs(expected.y - got.y)).to(beLessThan(precision))
            }
        }

        describe("flat") {
            let grid: Grid = Grid(orientation: OrientationFlat, origin: Point(x: 10.0, y: 20.0), size: Point(x: 20.0, y: 10.0), mort: try! Morton64(dimensions: 2, bits: 32))
            doTestHexAtPoint(grid, expected: Hex(q: 0, r: 37), point: Point(x: 13.0, y: 666.0))
            doTestHexAtPoint(grid, expected: Hex(q: 22, r: -11), point: Point(x: 666.0, y: 13.0))
            doTestHexAtPoint(grid, expected: Hex(q: -1, r: -39), point: Point(x: -13.0, y: -666.0))
            doTestHexAtPoint(grid, expected: Hex(q: -22, r: 9), point: Point(x: -666.0, y: -13.0))
        }

        describe("pointy") {
            let grid: Grid = Grid(orientation: OrientationPointy, origin: Point(x: 10.0, y: 20.0), size: Point(x: 20.0, y: 10.0), mort: try! Morton64(dimensions: 2, bits: 32))
            doTestHexAtPoint(grid, expected: Hex(q: -21, r: 43), point: Point(x: 13.0, y: 666.0))
            doTestHexAtPoint(grid, expected: Hex(q: 19, r: 0), point: Point(x: 666.0, y: 13.0))
            doTestHexAtPoint(grid, expected: Hex(q: 22, r: -46), point: Point(x: -13.0, y: -666.0))
            doTestHexAtPoint(grid, expected: Hex(q: -19, r: -2), point: Point(x: -666.0, y: -13.0))
        }

        describe("flat coordinates") {
            let grid: Grid = Grid(orientation: OrientationFlat, origin: Point(x: 10.0, y: 20.0), size: Point(x: 20.0, y: 10.0), mort: try! Morton64(dimensions: 2, bits: 32))
            let hex: Hex = grid.hexAt(Point(x: 666.0, y: 666.0))
            doComparePoints(Point(x: 670.00000, y: 660.85880), got: grid.hexCenter(hex), precision: 0.00001)
            let expectedCorners: [Point] = [
              Point(x: 690.00000, y: 660.85880),
              Point(x: 680.00000, y: 669.51905),
              Point(x: 660.00000, y: 669.51905),
              Point(x: 650.00000, y: 660.85880),
              Point(x: 660.00000, y: 652.19854),
              Point(x: 680.00000, y: 652.19854)]
            let gotCorners: [Point] = grid.hexCorners(hex)
            var i: Int = 0
            while i < 6 {
                doComparePoints(expectedCorners[i], got: gotCorners[i], precision: 0.00001)
                i += 1
            }
        }

        describe("pointy coordinates") {
            let grid: Grid = Grid(orientation: OrientationPointy, origin: Point(x: 10.0, y: 20.0), size: Point(x: 20.0, y: 10.0), mort: try! Morton64(dimensions: 2, bits: 32))
            let hex: Hex = grid.hexAt(Point(x: 666.0, y: 666.0))
            doComparePoints(Point(x: 650.85880, y: 665.00000), got: grid.hexCenter(hex), precision: 0.00001)
            let expectedCorners: [Point] = [
              Point(x: 668.17930, y: 670.00000),
              Point(x: 650.85880, y: 675.00000),
              Point(x: 633.53829, y: 670.00000),
              Point(x: 633.53829, y: 660.00000),
              Point(x: 650.85880, y: 655.00000),
              Point(x: 668.17930, y: 660.00000)
            ]
            let gotCorners: [Point] = grid.hexCorners(hex)
            var i: Int = 0
            while i < 6 {
                doComparePoints(expectedCorners[i], got: gotCorners[i], precision: 0.00001)
                i += 1
            }
        }

        describe("neighbors") {
            let grid: Grid = Grid(orientation: OrientationFlat, origin: Point(x: 10.0, y: 20.0), size: Point(x: 20.0, y: 10.0), mort: try! Morton64(dimensions: 2, bits: 32))
            let hex: Hex = grid.hexAt(Point(x: 666, y: 666))
            let expectedNeighbors: [Int64] = [920, 922, 944, 915, 921, 923, 945, 916, 918, 926, 948, 917, 919, 925, 927, 960, 962, 968]
            let gotNeighborsHexes = grid.hexNeighbors(hex, layers: 2)
            let gotNeighbors = gotNeighborsHexes.map {
                hex in try! grid.hexToCode(hex)
            }
            it("should provide proper neighbors") {
                expect(gotNeighbors).to(equal(expectedNeighbors))
            }
        }
    }
}
