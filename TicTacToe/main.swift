//
//  main.swift
//  TicTacToe
//
//  Created by 1 on 8/26/19.
//  Copyright © 2019 1. All rights reserved.
//

enum Symbol: String {
    case X = "X"
    case O = "O"
    case invalid = " "
}

enum BoardSize: Int {
    case small = 3
    case middle = 5
    case large = 7
}

struct Matrix {
    let size: Int
    var grid: [Symbol]
    
    init(size: Int) {
        self.size = size
        grid = Array(repeating: Symbol.invalid, count: size * size)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < size && column >= 0 && column < size
    }
    
    subscript(_ row: Int, _ column: Int) -> Symbol {
        get {
            return grid[(row * size) + column]
        }
        set {
            grid[(row * size) + column] = newValue
        }
    }
}

struct TicTacToe {
    var matrix: Matrix
    
    init(_ boardSize: BoardSize) {
        matrix = Matrix(size: boardSize.rawValue)
    }
    
    mutating func step(_ row: Int, _ column: Int, _ symbol: Symbol) -> Bool {
        guard matrix[row, column] == .invalid else {
            print("Invalid Input")
            return false
        }
        
        matrix[row, column] = symbol.self
        print(matrixOutline(size: matrix.size))
        return true
    }
    
    func checkWinner(_ row: Int, _ column: Int) -> Bool {
        var isWinnerHorizon = false
        var isWinnerVertical = false
        var isWinnerDiagram = false
        
        if row == column {
            isWinnerDiagram = checkDiagram()
        }
        isWinnerHorizon = checkHorizon(row, column)
        isWinnerVertical = checkVertical(row, column)
        
        if isWinnerVertical || isWinnerHorizon || isWinnerDiagram {
            return true
        }
        return false
    }
    
    // MARK: - Private Func
    
    private func checkHorizon(_ row: Int, _ column: Int) -> Bool {
        for ind in 0..<matrix.size - 1 {
            if matrix[row, ind] != matrix[row, ind + 1] {
                return false
            }
        }
        return true
    }
    
    private func checkVertical(_ row: Int, _ column: Int) -> Bool {
        for ind in 0..<matrix.size - 1 {
            if matrix[ind, column] != matrix[ind + 1, column] {
                return false
            }
        }
        return true
    }
    
    private func checkDiagram() -> Bool {
        for ind in 0..<matrix.size - 1 {
            if matrix[ind, ind] != matrix[ind + 1, ind + 1] {
                return false
            }
        }
        return true
    }
    
    // MARK: - Matrix Drawing
    
    func matrixOutline(size: Int) -> String {
        let firstLine = "┏━━━" + String(repeating: "┳━━━", count: size - 1) + "┓"
        let verticalSeparatingLine = "┣━━━" + String(repeating: "╋━━━", count: size - 1) + "┫"
        let lastLine = "┗━━━" + String(repeating: "┻━━━", count: size - 1) + "┛"
        
        var lines = [firstLine]
        for i in 0..<size {
            var verticalSpacingLine = ""
            for j in 0..<size {
                verticalSpacingLine += "┃ " + matrix[i, j].rawValue + " "
            }
            verticalSpacingLine += "┃"
            lines += [verticalSpacingLine]
            if i != size - 1 {
                lines += [verticalSeparatingLine]
            }
        }
        lines += [lastLine]
        return lines.joined(separator: "\n")
    }
    
    func readUsername(_ player: String) -> String? {
        var input: String?
        repeat {
            print("Input your name \(player) 👉 : ", terminator: "")
            input = readLine(strippingNewline: true)
        } while input != nil && input!.isEmpty
        
        return input
    }
    
    func readCoordinate() -> (row: Int, column: Int)? {
        var input: String?
        repeat {
            print("Input coordinate (row, column) 👉 : ", terminator: "")
            input = readLine(strippingNewline: true)
            if let input = input, let size = parseCoordinate(from: input) {
                return size
            }
        } while input != nil
        
        return nil
    }
    
    func parseCoordinate(from str: String) -> (Int, Int)? {
        let components = str.filter { !$0.isWhitespace }.split(separator: ",")
        guard components.count >= 2, let width = Int(components[0]), let height = Int(components[1]) else {
            return nil
        }
        
        return (width, height)
    }
}

// MARK: - Matrix Console

var game = TicTacToe(.small)

var userNameX = ""
var userNameY = ""
var welcomed = false
var greetedX = false
var greetedY = false
var isStart = false
var startValue = 0

gameLoop: while true {
    if !welcomed {
        print("Welcome to TicTacToe for macOS console.")
        welcomed = true
    }
    
    //read usernames
    if !greetedX {
        guard let username = game.readUsername("player X") else {
            print("\nGoodbye stranger...")
            break gameLoop
        }
        
        userNameX = username
        greetedX = true
    }
    
    if !greetedY {
        guard let username = game.readUsername("player O") else {
            print("\nGoodbye stranger...")
            break gameLoop
        }
        
        userNameY = username
        greetedY = true
        print("\nStart Game \n")
    }
    
    //read coordinate
    if !isStart {
        guard let matrixCoordinate = game.readCoordinate(), game.matrix.indexIsValid(row: matrixCoordinate.row, column: matrixCoordinate.column) else {//, game.matrix.indexIsValid(row: matrixCoordinate.rows, column: matrixCoordinate.columns)
            print("\n")
            continue gameLoop
        }
        
        if game.step(matrixCoordinate.row, matrixCoordinate.column, .X) {
            let checkValue = 2 * (startValue - 1)
            if checkValue >= 4 && game.checkWinner(matrixCoordinate.row, matrixCoordinate.column) {
                print("\n\(userNameX)'s Winns \n")
                break
            }
            isStart = true
            startValue += 1
            print("\n\(userNameY)'s turn\n")
        }
    } else {
        guard let matrixCoordinate = game.readCoordinate(), game.matrix.indexIsValid(row: matrixCoordinate.row, column: matrixCoordinate.column) else {
            print("\n")
            continue gameLoop
        }
        
        if game.step(matrixCoordinate.row, matrixCoordinate.column, .O) {
            let checkValue = 2 * (startValue - 1)
            if checkValue >= 4 && game.checkWinner(matrixCoordinate.row, matrixCoordinate.column) {
                print("\n\(userNameY)'s Winns \n")
                break
            }
            isStart = false
            startValue += 1
            print("\n\(userNameX)'s turn \n")
        }
    }
}

