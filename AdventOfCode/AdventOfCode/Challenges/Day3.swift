//
//  Day3.swift
//  AdventOfCode
//
//  Created by Zev Eisenberg on 12/3/18.
//  Copyright © 2018 Zev Eisenberg. All rights reserved.
//

import Foundation

func Day3() {
    let inputUrl = Bundle.main.url(forResource: "3", withExtension: "txt")!
    let inputData = try! Data(contentsOf: inputUrl)
    let inputString = String(data: inputData, encoding: .utf8)!
    let inputLines = inputString.split(separator: "\n").map(String.init)
//    let inputLines = [
//    "#1 @ 1,3: 4x4",
//    "#2 @ 3,1: 4x4",
//    "#3 @ 5,5: 2x2",
//    ]

    let gridSize = 1000

    struct Point: Hashable {
        let x: Int
        let y: Int
    }

    struct Size: Hashable {
        let width: Int
        let height: Int
    }

    struct Rect: Hashable {
        let id: String
        let origin: Point
        let size: Size

        var minX: Int {
            return origin.x
        }
        var maxX: Int {
            return origin.x + size.width
        }
        var minY: Int {
            return origin.y
        }
        var maxY: Int {
            return origin.y + size.height
        }

        func intersects(_ other: Rect) -> Bool {
            return !(minX > other.maxX || maxX < other.minX || minY > other.maxY || maxY < other.minY)
        }

        init(id: String, origin: Point, size: Size) {
            self.id = id
            self.origin = origin
            self.size = size
        }

        init(id: String, _ x: Int, _ y: Int, _ width: Int, _ height: Int) {
            self.init(id: id, origin: Point(x: x, y: y), size: Size(width: width, height: height))
        }
    }

    assert(Rect(id: "foo", 2, 2, 2, 2)
        .intersects(Rect(id: "bar", 1, 1, 2, 2)))

    assert(!Rect(id: "foo", 2, 2, 2, 2)
        .intersects(Rect(id: "bar", 10, 10, 12, 12)))

    let rects = inputLines.map { (input: String) -> Rect in
        let regex = try! NSRegularExpression(pattern: "#(\\d+) @ (\\d+),(\\d+): (\\d+)x(\\d+)", options: [])
        let fullMatch = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))[0]
        func match(at index: Int) -> String {
            return String(input[Range(fullMatch.range(at: index), in: input)!])
        }
        let id = match(at: 1)
        let x = Int(match(at: 2))!
        let y = Int(match(at: 3))!
        let width = Int(match(at: 4))!
        let height = Int(match(at: 5))!
        return Rect(id: id, origin: Point(x: x, y: y), size: Size(width: width, height: height))
    }


    var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)

    for rect in rects {
        let rowIndices = (rect.origin.x..<rect.origin.x + rect.size.width)
        let colIndices = (rect.origin.y..<rect.origin.y + rect.size.height)
        for x in rowIndices {
            for y in colIndices {
                grid[x][y] += 1
            }
        }
    }

    let numberOfSquareInchesWithOverlappingRects = grid.flatMap { $0 }.count { $0 > 1 }
    print("numberOfSquareInchesWithOverlappingRects:", numberOfSquareInchesWithOverlappingRects)

    var nonIntersecting: Rect?
    for i in 0..<rects.count {
        var theRects = rects
        let theRect = theRects.remove(at: i)
        if !theRects.contains(where: theRect.intersects) {
            nonIntersecting = theRect
            break
        }
    }
    print("non-intersecting rect ID:", nonIntersecting!.id)
}

extension Sequence {

    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self where try predicate(element) {
            count += 1
        }
        return count
    }

}
