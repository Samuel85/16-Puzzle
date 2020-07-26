//
//  GameView.swift
//  16-Puzzle
//
//  Created by Samuel Salinas Almaguer on 26.07.20.
//  Copyright © 2020 Samuel Salinas Almaguer. All rights reserved.
//

import Foundation

import SwiftUI

class Puzzle: ObservableObject{
    @Published var board : [[Int]]
    @Published var score: Int = 0
    @Published var currentBoard: [[Int]]
    @Published var orientation: Int = 0
    
    let horizontal : [[Int]] = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[0,13,14,15]]
    let vertical : [[Int]] = [[1,5,9,13],[2,6,10,14],[3,7,11,15],[4,8,12,0]]
    let upAndDown : [[Int]] = [[4,5,12,13],[3,6,11,14],[2,7,10,15],[1,8,9,0]]
    let spiral : [[Int]] = [[7,8,9,10],[6,1,2,11],[5,4,3,12],[0,15,14,13]]
    let oddsFirst : [[Int]] = [[1,3,5,7],[9,11,13,15],[2,4,6,8],[10,12,14,0]]
    let evensFirst : [[Int]] = [[2,4,6,8],[10,12,14,0], [1,3,5,7],[9,11,13,15]]
    let diagonal: [[Int]] = [[7,11,14,0],[4,8,12,15],[2,5,9,13],[1,3,6,10]]
    let peripheral: [[Int]] = [[1,2,3,4],[12,13,14,5],[11,0,15,6],[10,9,8,7]]
    let impossible: [[Int]] = [[15,14,13,12],[11,10,9,8],[7,6,5,4],[3,2,1,0]]
    let name : [String] = ["Horizontal", "Vertical", "Up and Down", "Spiral", "Odd First", "Evens First", "Diagonal", "Peripheral", "Impossible"]
    var boardNumber: Int = 0
    
    init() {
        currentBoard = horizontal
        board = horizontal
        shuffle()
        updateOrientation()
    }
    
    func shuffle(){
        let n = Int.random(in: 20..<100)
        for _ in (1...n){
            let r = Int.random(in:0..<4)
            let c = Int.random(in:0..<4)
            movePieces(row: r, col: c, shouldUpdateScore: false)
        }
    }
    
    func movePieces(row: Int, col:Int, shouldUpdateScore: Bool){
        var update : Bool = false
        let j = row
        let i = col
        
        if board[j][i] == 0{
            return
        }
        
        // right
        for n in i..<4 {
            if board[j][n] == 0{
                for k in (i+1...n).reversed() {
                    board[j][k] = board[j][k-1]
                }
                board[j][i] = 0
                update = true
            }
        }
        
        // left
        if update == false{
            for n in (0...i).reversed(){
                if board[j][n] == 0{
                    for k in (n...i-1){
                        board[j][k] = board[j][k+1]
                    }
                    board[j][i] = 0
                    update = true
                }
            }
        }
        
        // up
        if update == false{
            for n in (0...row).reversed(){
                if board[n][col] == 0{
                    for k in (n...j-1){
                        board[k][col] = board[k+1][col]
                    }
                    board[row][col] = 0
                    update = true
                }
            }
        }
        
        // down
        if update == false{
            for n in (row..<4) {
                if board[n][col] == 0{
                    for k in (j+1...n).reversed(){
                        board[k][col] = board[k-1][col]
                    }
                    board[row][col] = 0
                    update = false
                }
            }
        }
        if shouldUpdateScore{
            checkBoard()
        }
    }
    
    func checkBoard(){
        if board == currentBoard{
            score += 1
            
            boardNumber = Int.random(in: 0...8)
            
            switch boardNumber {
            case 0:
                setBoard(newBoard: horizontal)
            case 1:
               setBoard(newBoard: vertical)
            case 2:
                setBoard(newBoard: upAndDown)
            case 3:
                setBoard(newBoard: spiral)
            case 4:
                setBoard(newBoard: oddsFirst)
            case 5:
                setBoard(newBoard: evensFirst)
            case 6:
                setBoard(newBoard: diagonal)
            case 7:
                setBoard(newBoard: peripheral)
            default:
                setBoard(newBoard: impossible)
            }
            self.shuffle()
        }
    }
    
    func setBoard(newBoard: [[Int]]){
        currentBoard = newBoard
        board = newBoard
    }
    
    func updateOrientation(){
        switch UIDevice.current.orientation{
        case .portrait:
           orientation = 0
        case .portraitUpsideDown:
            orientation = 0
        case .landscapeLeft:
            orientation = 1
        case .landscapeRight:
            orientation = 1
        default:
            print("default")
        }
    }
}


struct GameView : View {
    @ObservedObject var puzzle = Puzzle()
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification).makeConnectable().autoconnect()
    
    var body: some View{
        GeometryReader {proxy in
                if proxy.size.width < proxy.size.height {
                    ZStack(alignment: .center){
                        VStack(alignment: .center, spacing:1){
                            // Game board
                            ForEach(0..<4, id: \.self){row in
                                HStack(alignment:.center, spacing: 1){
                                    ForEach(0..<4, id: \.self){col in
                                        Button(action: {
                                            self.puzzle.movePieces(row: row, col: col, shouldUpdateScore: true)
                                        }){
                                            Text(self.getText(number: self.puzzle.board[row][col]))
                                            .font(.system(size: 32))
                                                .frame(width: self.getWidth(), height: self.getWidth(), alignment: Alignment.center)
                                            .foregroundColor(.white)
                                            .background(self.getColor(number: self.puzzle.board[row][col]))
                                        }
                                    }
                                }
                            }
                            // Mini board
                            VStack(){
                                Spacer()
                                Text(self.puzzle.name[self.puzzle.boardNumber])
                                .font(.system(size:32))
                                
                                ForEach(0..<4, id: \.self){row in
                                    HStack(alignment:.center,spacing: 1){
                                        ForEach(0..<4, id: \.self){col in
                                            Text(self.getText(number: self.puzzle.currentBoard[row][col]))
                                            .font(.system(size: 10))
                                                .frame(width: self.getWidthPrewview(), height: self.getWidthPrewview(), alignment: Alignment.center)
                                            .foregroundColor(.white)
                                                .background(self.getColor(number: self.puzzle.currentBoard[row][col]))
                                        }
                                    }
                                }
                                Spacer()
                                Text("Score:"+String(self.puzzle.score))
                                    .font(.system(size:32))
                            }
                        }
                    }.onReceive(self.orientationChanged){_ in
                        self.puzzle.updateOrientation()
                    }.padding()
                }
                else{
                    // Game board
                    HStack(alignment: .center){
                        Spacer()
                        VStack(alignment: .center,spacing:1){
                            //
                            ForEach(0..<4, id: \.self){row in
                                HStack(spacing: 1){
                                    ForEach(0..<4, id: \.self){col in
                                        Button(action: {
                                            self.puzzle.movePieces(row: row, col: col, shouldUpdateScore: true)
                                        }){
                                            Text(self.getText(number: self.puzzle.board[row][col]))
                                            .font(.system(size: 32))
                                                .frame(width: self.getWidth(), height: self.getWidth(), alignment: Alignment.center)
                                            .foregroundColor(.white)
                                            .background(self.getColor(number: self.puzzle.board[row][col]))
                                        }
                                    }
                                }
                            }

                        }.padding()
                        //
                        Spacer()
                        VStack(alignment: .center){
                            Text(self.puzzle.name[self.puzzle.boardNumber])
                            .font(.system(size:32))
                            
                            ForEach(0..<4, id: \.self){row in
                                HStack(alignment: .top,spacing: 1){
                                    ForEach(0..<4, id: \.self){col in
                                        Text(self.getText(number: self.puzzle.currentBoard[row][col]))
                                        .font(.system(size: 10))
                                            .frame(width: self.getWidthPrewview(), height: self.getWidthPrewview(), alignment: Alignment.center)
                                        .foregroundColor(.white)
                                            .background(self.getColor(number: self.puzzle.currentBoard[row][col]))
                                    }
                                }
                            }
                            Spacer()
                            Text("Score:"+String(self.puzzle.score))
                                .font(.system(size:32))
                        }
                    }
                }
            }.onReceive(self.orientationChanged){_ in
                self.puzzle.updateOrientation()
            }
        }
        
        func getWidth() -> CGFloat{
            var width: CGFloat
            if UIDevice.current.orientation == .portrait{
                width = (UIScreen.main.bounds.width - 40)/4
                return width
            }
            else{
                width = (UIScreen.main.bounds.width - 40)/8
                return width
            }
        }
        
        func getWidthPrewview() -> CGFloat{
            return ((UIScreen.main.bounds.width - 50)/4)/6
            
        }
        
        func getText(number: Int) -> String{
            if number == 0{
                return ""
            }
            return String(number)
        }
        
        func getColor(number: Int) -> Color{
            if number == 0{
                return Color.white
            }
            else if number % 2 == 0{
                return Color.red
            }
            else{
                return Color.black
            }
        }
}

