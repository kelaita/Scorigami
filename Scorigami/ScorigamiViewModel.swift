//
//  ScorigamiViewModel.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/20/22.
//

import SwiftUI

class ScorigamiViewModel: ObservableObject {
    
    @Published var model: Scorigami
    
    let gradientType = 0
    var uniqueId = 0
        
    public struct Cell: Hashable, Identifiable {
        public var id: String
        var color: Color
        var occurrences: Int
        var lastGame: String
        var gamesUrl: String
        var label: String
        var saturation: Double
        var plural: String
    }
    
    @Published public var board: [[Cell]] = []
        
    init() {
        model = ScorigamiViewModel.createScorigami()
        model.games.sort { $0.winningScore < $1.winningScore }
        buildBoard(gradientType: gradientType)
    }
    
    static func createScorigami() -> Scorigami {
        Scorigami()
    }
    
    var gameCells: Array<Scorigami.Game> {
        model.games
    }
    
    func buildBoard(gradientType: Int) {
        board = []
        for row in 0...getHighestWinningScore() {
            board.append([Cell]())
            for col in 0...getHighestWinningScore() {
                board[row].append(searchGames(winningScore: col, losingScore: row, gradientVal: gradientType))
            }
        }
        uniqueId += 1
    }
    
    func searchGames(winningScore: Int, losingScore: Int, gradientVal: Int) -> Cell {
        let index = model.games.firstIndex {
            $0.winningScore == winningScore &&
            $0.losingScore == losingScore }
        
        var cell = Cell(id: String(uniqueId) + ":" + String(winningScore) + "-" + String(losingScore),
                        color: .black,
                        occurrences: 0,
                        lastGame: "",
                        gamesUrl: "",
                        label: String(winningScore) + "-" + String(losingScore),
                        saturation: 0.0,
                        plural: "s")

        if index != nil {
            cell.occurrences = model.games[index!].occurrences
            cell.color = Color.red
            //cell.color = getColor(occurrences: cell.occurrences)
            cell.lastGame = model.games[index!].lastGame
            cell.gamesUrl = model.getParticularScoreURL(winningScore: winningScore, losingScore: losingScore)
            if gradientVal == 0 {
                cell.saturation = getSaturation(
                    min: 1,
                    max: model.getMaxOccorrences(),
                    val: cell.occurrences,
                    skewLower: 0.1,
                    skewUpper: 0.6)
            } else {
                cell.saturation = getSaturation(
                    min: 1920,
                    max: 2022,
                    val: getMostRecentYear(gameDesc: cell.lastGame),
                    skewLower: 0,
                    skewUpper: 1.0)
            }
            if cell.occurrences == 1 {
                cell.plural = ""
            }
        }
        
        if winningScore < losingScore {
            cell.label = ""
        }
        
        return cell
    }
    
    public func getHighestWinningScore() -> Int {
        model.games.last!.winningScore
    }
    
    public func getGamesForLosingScore(losingScore: Int) -> Array<Cell> {
        return board[losingScore]
    }
    
    public func getMostRecentYear(gameDesc: String) -> Int {
        let year = gameDesc.suffix(4)
        return Int(year) ?? 1920
    }
    
    public func getSaturation(min: Int,
                              max: Int,
                              val: Int,
                              skewLower: Double,
                              skewUpper: Double) -> Double {
        let floorSaturationPercent = skewLower
        // the following improves the appearance by making highest intensity before the very top
        let newMax = Double(max - min) * skewUpper + Double(min)
        let ratio = (Double(val) - Double(min)) /
                    (newMax - Double(min))
        let saturation = (1.0 - floorSaturationPercent) *
            ratio + floorSaturationPercent
        if saturation > 1.0 {
            return 1.0
        }
        return saturation
    }
    
    public func getColor(occurrences: Int) -> Color {
        let maxOccurrences = model.getMaxOccorrences()
        let whereOnGradient = Double(occurrences) / Double(maxOccurrences)
        print("WhereOnGradient: \(whereOnGradient)")
        let red = whereOnGradient
        let blue = 1.0 - whereOnGradient
        return Color(red: red, green: 0, blue: blue)
    }
    
    public func fixScrollCell(cell: String) -> String {
        let id_scores = cell.components(separatedBy: ":")
        let id = id_scores[0]
        let scores = id_scores[1].components(separatedBy: "-")
        if Int(scores[0])! < Int(scores[1])! {
            return id + ":" + scores[1] + "-" + scores[1]
        }
        else {
            return id_scores[1]
        }
    }
    
    public func getMinMaxes(gradientType: Int) -> Array<String> {
        if (gradientType == 0) {
            return ["Occurrences: 1", "277"]
        }
        else {
            return ["Most Recent: 1920", String(Calendar.current.component(.year, from: Date()))]
        }
    }

}
