//
//  Cell.swift
//  Sudoku
//
//  Created by Zhengyu Ren on 12/6/20.
//  Copyright © 2020 Zhengyu Ren. All rights reserved.
//


class Cell {
    var v: Int8
    var pv: [Int8]
    
    init(_ v: Int8) {
        self.v = v
        if v == 0 {
            pv = Array(1...9)
        } else {
            pv = []
        }
    }
    
    var char: String {
        get {
            return (v == 0 ? " " : String(v))
        }
    }
    
    func eliminate(_ v: Int8) {
        if let i = self.pv.firstIndex(of: v) {
            self.pv.remove(at: i)
        }
        if self.pv.count == 1 {
            self.v = self.pv.removeFirst()
        }
    }
}
