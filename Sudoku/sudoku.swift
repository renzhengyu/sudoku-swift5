//
//  sudoku.swift
//  Sudoku
//
//  Created by Zhengyu Ren on 12/6/20.
//  Copyright © 2020 Zhengyu Ren. All rights reserved.
//

import Foundation


class Sudoku {
    var m : [[Cell]] // m short for matrix
    var begin, end: Date?
    
    init(_ intMatrix:[[Int8]], showNewSudoku: Bool = true) {
        m = []
        var r : [Cell]
        for row in intMatrix {
            r = []
            for v in row {
                r.append(Cell(v))
            }
            m.append(r)
        }
        
        begin = Date()
        if showNewSudoku {
            print(String(repeating: "=", count: 40))
            print("New Sudoku:")
            print("Begin:", begin!)
            print(str)
        }
    }
    
    func accept(_ assumption: Assumption) -> Bool {
        m[assumption.r][assumption.c].v = assumption.v
        m[assumption.r][assumption.c].pv = []
        let _ = simpleSolve()
        return isValid
    }
    
    var ints: [[Int8]] {
        get {
            var r: [[Int8]] = []
            for row in m {
                var c: [Int8] = []
                for cell in row {
                    c.append(cell.v)
                }
                r.append(c)
            }
            return r
        }
    }
    
    var str: String {
        get {
            var s : String = ""
            for r in 0...8 {
                if r % 3 == 0 {
                    s += "+---------+---------+---------+\n"
                }
                for c in 0...8 {
                    if c % 3 == 0 {
                        s += "|"
                    }
                    s += " \(self.m[r][c].char) "
                }
                s += "|\n"
                
            }
            s += "+---------+---------+---------+ "
            s += (self.isValid ? "V" : "Inv") + "alid. "
            s += "Black count: \(self.blankCount)"
            return s
        }
    }
    
    var isValid: Bool {
        get {
            for i in Int8(0)...Int8(8) {
                if row(i).hasDupes || col(i).hasDupes || sec(i).hasDupes {
                    return false
                }
            }
            return true
        }
    }
    
    var blankCount: Int8 {
        get {
            var count : Int8 = 0
            for row in m {
                for cell in row {
                    if cell.v == 0 {
                        count += 1
                    }
                }
            }
            return count
        }
    }
    
    func inSameZone(_ coordinates: Coordinates...) -> Bool? {
        if coordinates.count == 2 {
            if coordinates[0].r == coordinates[1].r { return true }
            if coordinates[0].c == coordinates[1].c { return true }
            if coordinates[0].sec == coordinates[1].sec { return true}
            return false
        }
        if coordinates.count == 3 {
            let a: Bool = inSameZone(coordinates[0], coordinates[1])!
            let b: Bool = inSameZone(coordinates[0], coordinates[2])!
            let c: Bool = inSameZone(coordinates[2], coordinates[1])!
            return a || b || c
        }
        return nil
    }
    
    func row(_ r : Int8) -> Cells {
        return Cells(m[Int(r)])
    }
    
    func col(_ c : Int8) -> Cells {
        var l : [Cell] = []
        for row in m {
            l.append(row[Int(c)])
        }
        return Cells(l)
    }
    
    func sec(_ s : Int8) -> Cells {
        var t : [Cell] = []
        let x : Int8 = s / 3 * 3
        for r in x..<(x+3) {
            for c in ((s-x)*3)..<((s-x)*3+3) {
                t.append(m[Int(r)][Int(c)])
            }
        }
        return Cells(t)
    }
    
    func refresh() {
        for r in Int8(0)...Int8(8) {
            for c in Int8(0)...Int8(8) {
                if m[Int(r)][Int(c)].v != 0 {
                    row(r).eliminate(m[Int(r)][Int(c)].v)
                    col(c).eliminate(m[Int(r)][Int(c)].v)
                }
            }
        }
        for s in Int8(0)...Int8(8) {
            for cell in sec(s).members {
                if cell.v != 0 {
                    sec(s).eliminate(cell.v)
                }
            }
        }
    }
    
    func simpleSolve() -> Bool {
        if !isValid {
            return false
        }
        var before, after : Int8
        repeat {
            before = blankCount
            refresh()
            after = blankCount
        } while after != 0 && before != after
        return after == 0
    }
    
    var assumptionsSortedByPVC: [Assumption] {
        var t: [[Assumption]]
        t = Array(repeating: [], count: 10)
        for r in 0...8 {
            for c in 0...8 {
                let cell: Cell = m[r][c]
                for v in cell.pv {
                    t[cell.pv.count].append(Assumption(r: r, c: c, v: v))
                }
            }
        }
        return t[2]+t[3]+t[4]+t[5]+t[6]+t[7]+t[8]+t[9]
    }
    
    var allAssumptionPairs: [AssumptionPair] {
        var result: [AssumptionPair] = []
        for a in assumptionsSortedByPVC.dropLast() {
            for b in assumptionsSortedByPVC.dropFirst() {
                if a.r != b.r || a.c != b.c {
                    result.append((a, b))
                }
            }
        }
        return result
    }
    
    func assume(_ assumptions: Assumption...) -> AssumingSolveScenario {
        let hype: Sudoku = Sudoku(ints, showNewSudoku: false)
        for assumption in assumptions {
            if verbose { print (assumption, terminator: " ") }
            if !hype.accept(assumption) {
                return AssumingSolveScenario.invalid
            }
        }
        if !hype.isValid {
            return AssumingSolveScenario.invalid
        }
        var before, after: Int8
        repeat {
            before = hype.blankCount
            refresh()
            after = hype.blankCount
        } while after != 0 && before != after
        if after == 0 {
            return AssumingSolveScenario.solved
        } else {
            return AssumingSolveScenario.unsolved
        }
    }
    
    func assumingSolve() -> Bool {
        // depth: 1
        var before, after: Int8
        repeat {
            before = blankCount
            for assumption in assumptionsSortedByPVC {
                switch assume(assumption) {
                case AssumingSolveScenario.invalid:
                    m[assumption.r][assumption.c].eliminate(assumption.v)
                    if verbose { print("  => Eliminated") }
                    let _ = simpleSolve()
                    break
                case AssumingSolveScenario.solved:
                    if verbose { print("  => Accepted") }
                    return accept(assumption)
                case AssumingSolveScenario.unsolved:
                    if verbose { print("  => Indefinitive") }
                    continue
                }
            }
            after = blankCount
        } while after != 0 && before != after
        if after == 0 { return true }
        
        // depth: 2
        for assumptionPair in allAssumptionPairs {
            let a: Assumption = assumptionPair.0
            let b: Assumption = assumptionPair.1
            switch assume(a, b) {
            case AssumingSolveScenario.solved:
                let _ = accept(a)
                let _ = accept(b)
                if verbose { print("  => Accepted") }
                return simpleSolve()
            case AssumingSolveScenario.unsolved:
                if verbose { print("  => Indefinitive") }
                continue
            case AssumingSolveScenario.invalid:
                if verbose { print("  => Invalid so Indefinitive") }
                continue
            }
        }
        if after == 0 { return true }
        
        // depth: 3
        for a in assumptionsSortedByPVC.dropLast(2) {
            for b in assumptionsSortedByPVC.dropFirst(1).dropLast(1) {
                for c in assumptionsSortedByPVC.dropFirst(2) {
                    if (!inSameZone(a.coordinates, b.coordinates, c.coordinates)!) ||
                        (inSameZone(a.coordinates, b.coordinates)! && a.v != b.v) ||
                        (inSameZone(c.coordinates, b.coordinates)! && c.v != b.v) ||
                        (inSameZone(a.coordinates, c.coordinates)! && a.v != c.v) {
                        switch assume(a, b, c) {
                        case AssumingSolveScenario.solved:
                            let _ = accept(a)
                            let _ = accept(b)
                            let _ = accept(c)
                            if verbose { print("  => Accepted") }
                            return simpleSolve()
                        case AssumingSolveScenario.unsolved:
                            if verbose { print("  => Indefinitive") }
                            continue
                        case AssumingSolveScenario.invalid:
                            if verbose { print("  => Invalid so Indefinitive") }
                            continue
                        }
                        
                    }
                }
            }
        }
        // even depth:3 can't find a solution
        return false
    }
    
    func solve() {
        if simpleSolve() {
            print("Solution found with simpleSolve:")
        } else {
            if assumingSolve() {
                print("Solution found with assumingSolve:")
            } else {
                print("Solution not found.")
            }
        }
        print(str)
        end = Date()
        print("End:", end!)
        print("Elapsed:", end!.timeIntervalSinceReferenceDate - begin!.timeIntervalSinceReferenceDate)
    }
}
