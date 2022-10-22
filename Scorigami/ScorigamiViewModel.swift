//
//  ScorigamiViewModel.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/20/22.
//

import SwiftUI

class ScorigamiViewModel: ObservableObject {
    
    @Published var model: Scorigami
    
    public struct Cell: Hashable {
        public var id: String
        var color: Color
        var occurrences: Int
    }
    
    public var board: [[Cell]] = []
    
    init() {
        model = ScorigamiViewModel.createScorigami()
        model.games.sort { $0.winningScore < $1.winningScore }
        buildBoard()
    }
    
    static func createScorigami() -> Scorigami {
        Scorigami()
    }
    
    var gameCells: Array<Scorigami.Game> {
        model.games
    }
    
    func buildBoard() {
        for row in 0...getHighestWinningScore() {
            board.append([Cell]())
            for col in 0...getHighestWinningScore() {
                board[row].append(searchGames(winningScore: row, losingScore: col))
            }
        }
    }
    
    func searchGames(winningScore: Int, losingScore: Int) -> Cell {
        let index = model.games.firstIndex {
            $0.winningScore == winningScore &&
            $0.losingScore == losingScore }
        
        var cell = Cell(id: String(winningScore) + "-" + String(losingScore),
                        color: .black,
                        occurrences: 0)

        if index != nil {
            cell.color = .red
            cell.occurrences = model.games[index!].occurrences
        }
        return cell
    }
    
    public func getHighestWinningScore() -> Int {
        model.games.last!.winningScore
    }
}
