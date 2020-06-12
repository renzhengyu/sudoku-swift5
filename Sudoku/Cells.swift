//
//  Cells.swift
//  Sudoku
//
//  Created by Zhengyu Ren on 12/6/20.
//  Copyright © 2020 Zhengyu Ren. All rights reserved.
//


class Cells {
    var members: [Cell]
    
    init(_ cells:[Cell]) {
        self.members = cells
    }
    
    func contains(_ v: Int8) -> Bool {
        for cell in members {
            if cell.v == v {
                return true
            }
        }
        return false
    }
    
    var hasDupes: Bool {
        get {
            var l: [Int8] = []
            
            for cell in members {
                if cell.v != 0 {
                    if l.contains(cell.v) {
                        return true
                    } else {
                        l.append(cell.v)
                    }
                }
            }
            return false
        }
    }
    
    func eliminate(_ v: Int8) {
        for cell in members {
            cell.eliminate(v)
        }
    }
}
