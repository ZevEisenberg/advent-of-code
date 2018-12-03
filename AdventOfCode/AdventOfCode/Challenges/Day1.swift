//
//  Day1.swift
//  AdventOfCode
//
//  Created by Zev Eisenberg on 12/3/18.
//  Copyright © 2018 Zev Eisenberg. All rights reserved.
//

import Foundation
func Day1() {
    let inputUrl = Bundle.main.url(forResource: "1", withExtension: "txt")!
    let inputData = try! Data(contentsOf: inputUrl)
    let inputString = String(data: inputData, encoding: .utf8)!
    let inputLines = inputString.split(separator: "\n")
    let ints = inputLines.compactMap({ Int($0) })

    // Part 1
    let sum = ints.reduce(0, +)
    print("sum:", sum)

    // Part 2
    var foundFrequencies: Set<Int> = []
    var rollingSum = 0
    var firstDoubledUpFrequency: Int? = nil

    whileLoop: while firstDoubledUpFrequency == nil {
        for change in ints {
            rollingSum += change
            let result = foundFrequencies.insert(rollingSum)
            if !result.inserted {
                firstDoubledUpFrequency = rollingSum
                break whileLoop
            }
        }
    }

    print("first doubled:", firstDoubledUpFrequency!)

}
