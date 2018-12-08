//
//  Day6.swift
//  AdventOfCode
//
//  Created by Zev Eisenberg on 12/7/18.
//  Copyright © 2018 Zev Eisenberg. All rights reserved.
//

import Foundation

private struct Point: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    func manhattanDistance(to other: Point) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// Init with a string of the format "x, y" where x and why are integers
    init?(_ string: String) {
        let scanner = Scanner(string: string)
        var x = 0
        var y = 0
        guard
            scanner.scanInt(&x),
            scanner.scanString(", ", into: nil),
            scanner.scanInt(&y)
            else { return nil }
        self.x = x
        self.y = y
    }

    var description: String {
        return "(\(x), \(y))"
    }
}

private enum Affinity {
    case rogue // equidistant from multiple points
    case nearest(Point)
    case at(Point)

    var pointFriend: Point? {
        switch self {
        case .nearest(let point), .at(let point): return point
        case .rogue: return nil
        }
    }
}



func Day6() {

    let inputUrl = Bundle.main.url(forResource: "6", withExtension: "txt")!
    let inputData = try! Data(contentsOf: inputUrl)
    let inputString = String(data: inputData, encoding: .utf8)!
    let inputLines = inputString.split(separator: "\n").map(String.init)
//let inputLines = """
//1, 1
//1, 6
//8, 3
//3, 4
//5, 5
//8, 9
//""".split(separator: "\n").map(String.init)

    let safetyThreshold = 10_000
//    let safetyThreshold = 32

    let inputPoints = inputLines.compactMap(Point.init)

    // assumption: all points are positive
    let gridWidth = inputPoints.map { $0.x }.max()!
    let gridHeight = inputPoints.map { $0.y }.max()!

    // column-major (x, y) grid of affinities for each point
    var grid = Array(repeating: Array(repeating: Affinity.rogue, count: gridHeight + 1), count: gridWidth + 1) // + 1 because 0-indexing

    xLoop: for x in 0...gridWidth {
        yLoop: for y in 0...gridHeight {
            let gridPoint = Point(x: x, y: y)
            guard !inputPoints.contains(gridPoint) else {
                grid[x][y] = .at(gridPoint)
                continue yLoop // just being explicit
            }
            let sortedPointDistances = inputPoints
                .map { (point: $0, distance: $0.manhattanDistance(to: gridPoint)) }
                .sorted { $0.distance < $1.distance }
            if sortedPointDistances[0].distance == sortedPointDistances[1].distance {
                grid[x][y] = .rogue
            }
            else {
                grid[x][y] = .nearest(sortedPointDistances[0].point)
            }
        }
    }

    var pointsNotTouchingEdges = Set(inputPoints)

    for col in 0...gridWidth {
        let topPoint = grid[col][0]
        let bottomPoint = grid[col][gridHeight]

        if let topAffinity = topPoint.pointFriend {
            pointsNotTouchingEdges.remove(topAffinity)
        }
        if let bottomAffinity = bottomPoint.pointFriend {
            pointsNotTouchingEdges.remove(bottomAffinity)
        }
    }

    for row in 1...gridHeight - 1 { // skip 1 and height because we've already done those rows
        let leftPoint = grid[0][row]
        let rightPoint = grid[gridWidth][row]
        if let leftAffinity = leftPoint.pointFriend {
            pointsNotTouchingEdges.remove(leftAffinity)
        }
        if let rightAffinity = rightPoint.pointFriend {
            pointsNotTouchingEdges.remove(rightAffinity)
        }
    }

    print("points not touching edges:", pointsNotTouchingEdges)

    var areas = Dictionary(pointsNotTouchingEdges.map { (key: $0, value: 0) }, uniquingKeysWith: { value, _ in value })

    for x in 0...gridWidth {
        for y in 0...gridHeight {
            if let pointFriend = grid[x][y].pointFriend, pointsNotTouchingEdges.contains(pointFriend) {
                areas[pointFriend]? += 1
            }
        }
    }

    print("areas: \(areas)")
    print("max area: \(areas.max { $0.value < $1.value }!)")

    var pointsWithDistanceLessThanThreshold: [(point: Point, distance: Int)] = []
    xLoop: for x in 0...gridWidth {
        yLoop: for y in 0...gridHeight {
            let gridPoint = Point(x: x, y: y)
            let distanceToAllPoints = inputPoints.reduce(0) { (distance, inputPoint) in distance + inputPoint.manhattanDistance(to: gridPoint) }
            if distanceToAllPoints < safetyThreshold {
                pointsWithDistanceLessThanThreshold.append((point: gridPoint, distance: distanceToAllPoints))
            }
        }
    }

//    print("points with distance less than threshold:", pointsWithDistanceLessThanThreshold) // slow with full data
    print("safety area: \(pointsWithDistanceLessThanThreshold.count)")
}
