//
//  Day5.swift
//  AdventOfCode
//
//  Created by Zev Eisenberg on 12/7/18.
//  Copyright © 2018 Zev Eisenberg. All rights reserved.
//

import Foundation

private extension UInt8 {
    func cancelsOut(_ other: UInt8) -> Bool {
        let targetDifference = UInt8("a".utf8.first!) - UInt8("A".utf8.first!)
        if self > other {
            return (self - other) == targetDifference
        }
        else {
            return (other - self) == targetDifference
        }
    }
}

private extension String {

    func cancelsOut(_ other: String) -> Bool {
        precondition(self.count == 1)
        precondition(other.count == 1)
        return UInt8(self.utf8.first!).cancelsOut(UInt8(other.utf8.first!))
    }

}

private extension Character {

    func cancelsOut(_ other: Character) -> Bool {
        precondition(self.unicodeScalars.count == 1)
        precondition(other.unicodeScalars.count == 1)
        return UInt8(self.unicodeScalars.first!.value).cancelsOut(UInt8(other.unicodeScalars.first!.value))
    }

}

private extension Collection {

    // code by Soroush Khanlou
    func chunk(size: Int) -> AnySequence<SubSequence> {
        precondition(size > 0, "It doesn't make sense to chunk by \(size)")
        return AnySequence({ () -> AnyIterator<SubSequence> in

            var currentIndex = self.startIndex

            return AnyIterator({ () -> SubSequence? in
                guard currentIndex != self.endIndex else { return nil }
                let next = self.index(currentIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
                defer { currentIndex = next }
                return self[currentIndex..<next]
            })
        })
    }
}

func Day5() {
    assert("a".cancelsOut("A"))
    assert("b".cancelsOut("B"))
    assert("l".cancelsOut("L"))
    assert("z".cancelsOut("Z"))

    assert("A".cancelsOut("a"))
    assert("B".cancelsOut("b"))
    assert("L".cancelsOut("l"))
    assert("Z".cancelsOut("z"))

    assert(!"A".cancelsOut("A"))
    assert(!"A".cancelsOut("B"))
    assert(!"A".cancelsOut("b"))
    assert(!"b".cancelsOut("A"))

    // Part 1

    let inputUrl = Bundle.main.url(forResource: "5", withExtension: "txt")!
    let inputData = try! Data(contentsOf: inputUrl)
    let inputString = String(String(data: inputData, encoding: .utf8)!.dropLast()) // delete trailing newline
//    let inputString = "dabAcCaCBAcCcaDA" // test data

    func react(polymer: String, ignoring: Character? = nil) -> String {
        var result = "" // treat this string like a stack
        let ignoringUppercase = ignoring.flatMap { String($0).uppercased() }.flatMap(Character.init)
        let ignoringLowercase = ignoring.flatMap { String($0).lowercased() }.flatMap(Character.init)

        for letter in inputString {
            guard letter != ignoringUppercase && letter != ignoringLowercase else { continue }
            if let last = result.last, letter.cancelsOut(last) {
                result.removeLast()
            }
            else {
                result.append(letter)
            }
        }
        return result
    }

    let result = react(polymer: inputString)

    print("result count is", result.count)

    let counts = "abcdefjhijklmnopqrstuvwxyz".map { (letter: $0, count: react(polymer: inputString, ignoring: $0).count) }
    let minimum = counts.min { $0.count < $1.count }!
    print("shortest:", minimum)
}
