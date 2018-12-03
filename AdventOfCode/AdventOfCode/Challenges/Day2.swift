//
//  Day2.swift
//  AdventOfCode
//
//  Created by Zev Eisenberg on 12/3/18.
//  Copyright © 2018 Zev Eisenberg. All rights reserved.
//

import Foundation

func Day2() {
    let inputUrl = Bundle.main.url(forResource: "2", withExtension: "txt")!
    let inputData = try! Data(contentsOf: inputUrl)
    let inputString = String(data: inputData, encoding: .utf8)!
    let inputLines = inputString.split(separator: "\n")

    func computeChecksum<T: StringProtocol>(of lines: [T]) -> Int {
        var twos = 0
        var threes = 0

        for line in lines {
            let (two, three) = line.matches
            if two { twos += 1 }
            if three { threes += 1 }
        }
        let checksum = twos * threes
        return checksum
    }

    let idsForTestingChecksum = [
        "abcdef",
        "bababc",
        "abbcde",
        "abcccd",
        "aabcdd",
        "abcdee",
        "ababab",
        ]

    print(computeChecksum(of: idsForTestingChecksum))
    print(computeChecksum(of: inputLines))

    /******* Part 2 ********/

    /// Calculates the difference between two strings in terms of how
    /// many characters they differ by. Crashes if the strings are not
    /// the same length. Returns 0 if they are equal, 1 if they differ
    /// by 1 character, etc.
    func difference<A: StringProtocol, B: StringProtocol>(_ a: A, b: B) -> Int {
        guard a.count == b.count else { fatalError("what did I *just* say") }
        return zip(a, b).map { $0 != $1 }.reduce(0) { sum, next in next ? sum + 1 : sum }
    }

    assert(difference("", b: "") == 0)
    assert(difference("a", b: "a") == 0)
    assert(difference("a", b: "b") == 1)
    assert(difference("aa", b: "ab") == 1)
    assert(difference("aa", b: "bb") == 2)

    let idsForTestingDifference = [
        "abcde",
        "fghij",
        "klmno",
        "pqrst",
        "fguij",
        "axcye",
        "wvxyz",
        ]

    let testPairs = idsForTestingDifference.everyPairPassingTest { difference($0, b: $1) == 1 }
    assert(testPairs[0] == ("fghij", "fguij"))
    assert(testPairs.count == 1)

    let foRealPairs = inputLines.everyPairPassingTest { difference($0, b: $1) == 1 }
    print(foRealPairs)
    // and then figure out which is the odd letter out by hand, because it's just one time.
    // If we need to figure it out more generally for a later puzzle, we can write
    // a nicer algorithm then.
    // The answer in this case was: lnfqdscwjyteorambzuchrgpx

}

extension StringProtocol {

    var matches: (two: Bool, three: Bool) {
        let countOfEachLetter = NSCountedSet(array: Array(self))
        var theCountsByThemselves: Set<Int> = []
        theCountsByThemselves = Set(countOfEachLetter.map(countOfEachLetter.count(for:)))
        return (two: theCountsByThemselves.contains(2), theCountsByThemselves.contains(3))
    }

}

extension Collection {

    // Compares every element to every other element, returning the pairs which
    // pass the test. Does each comparison only once, so the parameters of the
    // test function must be order-independent, i.e. test(a, b) == test(b, a).
    // Time complexity: O(n²/2)
    func everyPairPassingTest(_ test: (Element, Element) throws -> Bool) rethrows -> [(Element, Element)] {
        guard !isEmpty else { return [] }
        var passing: [(Element, Element)] = []
        for (offset, rowElement) in enumerated() {
            for colElement in self.dropFirst(offset) where try test(rowElement, colElement) {
                passing.append((rowElement, colElement))
            }
        }
        return passing
    }

}
