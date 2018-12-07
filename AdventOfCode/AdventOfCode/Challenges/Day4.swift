//
//  Day4.swift
//  AdventOfCode
//
//  Created by Zev Eisenberg on 12/3/18.
//  Copyright © 2018 Zev Eisenberg. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

private let minuteFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

func Day4() {
    enum ShiftEvent {
        case begin(guardId: Int)
        case goToSleep
        case wakeUp

        init(_ string: String) {
            switch string {
            case "falls asleep": self = .goToSleep
            case "wakes up": self = .wakeUp
            default:
                let scanner = Scanner(string: string)
                scanner.scanString("Guard #", into: nil)
                var guardId = -1
                scanner.scanInt(&guardId)
                self = .begin(guardId: guardId)
            }
        }

        var isBegin: Bool {
            if case .begin = self { return true }
            return false
        }

        var isGoToSleep: Bool {
            if case .goToSleep = self { return true }
            return false
        }

        var isWakeUp: Bool {
            if case .wakeUp = self { return true }
            return false
        }
    }

    struct GuardShift: CustomStringConvertible {
        let guardId: Int
        var events: [RawLogEntry]

        var description: String {
            return "Guard #\(guardId):\n" + events.map {
                "\(dateFormatter.string(from: $0.date)) \($0.event)"
                }.joined(separator: "\n")
        }

        var minutesAsleep: Int {
            let withoutShiftStart = events.dropFirst()
            var totalMinutesAsleep = 0
            for (first, second) in zip(withoutShiftStart, withoutShiftStart.dropFirst()) {
                switch (first.event, second.event) {
                case (.goToSleep, .wakeUp):
                    let wentToSleep = first.date
                    let wokeUp = second.date
                    let secondsAsleep = wokeUp.timeIntervalSince(wentToSleep)
                    let minutesAsleep = Int(floor(secondsAsleep / 60))
                    totalMinutesAsleep += minutesAsleep
                default: break // ignore (wakeUp, sleep) and any other combinations
                }
            }
            return totalMinutesAsleep
        }

    }

    struct RawLogEntry: CustomStringConvertible {
        let date: Date
        let event: ShiftEvent

        init(_ string: String) {
            let scanner = Scanner(string: string)
            scanner.scanString("[", into: nil)
            var dateString: NSString?
            scanner.scanUpTo("]", into: &dateString)
            scanner.scanString("] ", into: nil)
            var remainingString: NSString?
            scanner.scanUpTo("foobarbaz", into: &remainingString) // scans remainder
            self.date = dateFormatter.date(from: dateString! as String)!
            self.event = ShiftEvent(remainingString! as String)
        }

        var description: String {
            let prefix = "[" + dateFormatter.string(from: date) + "] "
            let eventString: String = {
                switch event {
                case .wakeUp: return "wakes up"
                case .goToSleep: return "falls asleep"
                case .begin(let guardId): return "Guard #\(guardId) begins shift"
                }
            }()
            return prefix + eventString
        }
    }

    let inputUrl = Bundle.main.url(forResource: "4", withExtension: "txt")!
    let inputData = try! Data(contentsOf: inputUrl)
    let inputString = String(data: inputData, encoding: .utf8)!
    let inputLines = inputString.split(separator: "\n").map(String.init)
//    let inputLines = """
//        [1518-11-01 00:00] Guard #10 begins shift
//        [1518-11-01 00:05] falls asleep
//        [1518-11-01 00:25] wakes up
//        [1518-11-01 00:30] falls asleep
//        [1518-11-01 00:55] wakes up
//        [1518-11-01 23:58] Guard #99 begins shift
//        [1518-11-02 00:40] falls asleep
//        [1518-11-02 00:50] wakes up
//        [1518-11-03 00:05] Guard #10 begins shift
//        [1518-11-03 00:24] falls asleep
//        [1518-11-03 00:29] wakes up
//        [1518-11-04 00:02] Guard #99 begins shift
//        [1518-11-04 00:36] falls asleep
//        [1518-11-04 00:46] wakes up
//        [1518-11-05 00:03] Guard #99 begins shift
//        [1518-11-05 00:45] falls asleep
//        [1518-11-05 00:55] wakes up
//        """.split(separator: "\n").map(String.init)

    let events = inputLines.map(RawLogEntry.init)
    let sortedEvents = events.sorted { $0.date < $1.date }

    var guardIdsToShifts: [Int: [GuardShift]] = [:]
    var currentGuardId = -1
    for event in sortedEvents {
        switch event.event {
        case .begin(let guardId):
            currentGuardId = guardId
            let newShift = GuardShift(guardId: guardId, events: [event])
            guardIdsToShifts[guardId, default: []].append(newShift)
        case .goToSleep, .wakeUp:
            var shifts = guardIdsToShifts[currentGuardId, default: []]
            guard var last = shifts.last else { fatalError("Tried to add an event to a shift that hasn't started yet") }
            last.events.append(event)
            shifts[shifts.endIndex - 1] = last
            guardIdsToShifts[currentGuardId] = shifts
        }
    }

    let minutesAsleep = guardIdsToShifts.mapValues { shifts in
        shifts.map { $0.minutesAsleep }.reduce(0, +)
    }

    let mostMinutesAsleep = minutesAsleep.max { (lhs: (key: Int, value: Int), rhs: (key: Int, value: Int)) -> Bool in
        lhs.value < rhs.value
    }
    print("Guard #\(mostMinutesAsleep!.key) spent \(mostMinutesAsleep!.value) minutes asleep")

    let mostAsleepShifts = guardIdsToShifts[mostMinutesAsleep!.key]!
    print(mostAsleepShifts)

    let sleepWakeEvents = mostAsleepShifts
        .flatMap { $0.events }
        .filter { !$0.event.isBegin }
    let sleepWakePairs = zip(sleepWakeEvents, sleepWakeEvents.dropFirst())
        .filter { $0.event.isGoToSleep && $1.event.isWakeUp }

    let sleepWakeRanges = sleepWakePairs.map { (pair: (RawLogEntry, RawLogEntry)) -> Range<Int> in
        let (sleep, wake) = pair
        let sleepDate = sleep.date
        let wakeDate = wake.date
        print(sleepDate, wakeDate)
        let sleepMinute = Int(minuteFormatter.string(from: sleepDate))!
        let wakeMinute = Int(minuteFormatter.string(from: wakeDate))!
        return sleepMinute..<wakeMinute
    }
    print("sleepWakeRanges:", sleepWakeRanges)

    let pairs = (0...59).map { ($0, 0) }
    var counts = Dictionary(pairs, uniquingKeysWith: { (_, first) in first })

    for minute in 0...59 {
        let total = sleepWakeRanges.reduce(0) { $1.contains(minute) ? $0 + 1 : $0 }
        counts[minute] = total
    }

    let minuteWhereMostAsleep = counts.max { lhs, rhs in
        let result = lhs.value < rhs.value
        return result
    }

    print("guard \(mostMinutesAsleep!.key) was asleep the most in minute \(minuteWhereMostAsleep!.key)")
    print("their product is \(mostMinutesAsleep!.key * minuteWhereMostAsleep!.key)")

    // part 2
    print("Part 2 here:")

    let guardsAndTheirMostSleptMinutesAndCounts = guardIdsToShifts.map { (guardId: Int, shifts: [GuardShift]) -> (guardId: Int, minute: Int, count: Int) in
        let sleepWakeEvents = shifts
            .flatMap { $0.events }
            .filter { !$0.event.isBegin }
        let sleepWakePairs = zip(sleepWakeEvents, sleepWakeEvents.dropFirst())
            .filter { $0.event.isGoToSleep && $1.event.isWakeUp }
        let sleepWakeRanges = sleepWakePairs.map { (pair: (RawLogEntry, RawLogEntry)) -> Range<Int> in
            let (sleep, wake) = pair
            let sleepDate = sleep.date
            let wakeDate = wake.date
            let sleepMinute = Int(minuteFormatter.string(from: sleepDate))!
            let wakeMinute = Int(minuteFormatter.string(from: wakeDate))!
            return sleepMinute..<wakeMinute
        }

        // find this guard's most-slept-during minute
        // [Int] where the index is the minute
        let minuteRange = 0...59
        let timesThisGuardSleptDuringEachMinute = minuteRange.map { (minute: Int) -> Int in
            let timesThisGuardWasAsleepDuringThisMinute = sleepWakeRanges.reduce(0) { $1.contains(minute) ? $0 + 1 : $0 }
            return timesThisGuardWasAsleepDuringThisMinute
        }
        let mostSleptMinuteWithCount = timesThisGuardSleptDuringEachMinute.enumerated().max { lhs, rhs in
            lhs.element < rhs.element
        }!
        let (mostSleptMinute, mostSleptCount) = mostSleptMinuteWithCount
        return (guardId: guardId, minute: mostSleptMinute, count: mostSleptCount)
    }

    let theOneWithTheHighestCountYikesThisIsALongName = guardsAndTheirMostSleptMinutesAndCounts.max { lhs, rhs in lhs.count < rhs.count }!
    print("theOneWithTheHighestCount:", theOneWithTheHighestCountYikesThisIsALongName)
    print("product of ID and minute is", theOneWithTheHighestCountYikesThisIsALongName.guardId * theOneWithTheHighestCountYikesThisIsALongName.minute)
}
