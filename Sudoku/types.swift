//
//  types.swift
//  Sudoku
//
//  Created by Zhengyu Ren on 12/6/20.
//  Copyright © 2020 Zhengyu Ren. All rights reserved.
//

struct Coordinates {
    var r, c: Int
    var sec: Int {
        get {
            return (r/3)*3 + (c/3)
        }
    }
}


struct Assumption {
    var r, c: Int
    var v: Int8
    var coordinates: Coordinates {
        get{
            return Coordinates(r: r, c: c)
        }
    }
}


typealias AssumptionPair = (Assumption, Assumption)


enum AssumingSolveScenario {
    case unsolved
    case solved
    case invalid
}
