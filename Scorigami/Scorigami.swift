//
//  Scorigami.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import Foundation
import SwiftSoup

struct Scorigami {
    
    public struct Game  {
        var winningScore: Int = 0
        var losingScore: Int = 0
        var occurrences: Int = 0
        var lastGame: String = ""
    }
    
    public var games: Array<Game>
        
    init() {
        games = Array<Game>()
        loadAllScores()
        print("PUP: games: ", games.count)
    }
    
    let particularScoreURL = "https://www.pro-football-reference.com/boxscores/game_scores_find.cgi?pts_win=20&pts_lose=18"
    let allGamesURL = "https://www.pro-football-reference.com/boxscores/game-scores.htm"
    
    public mutating func loadAllScores() {
            // particularScore()
            print("In model about to load all scores")
            self.allScores()
            print("In model DONE load all scores")
    }
    
    public mutating func particularScore() {
        let url = URL(string: particularScoreURL)!
        let (data, _, _) = URLSession.shared.synchronousDataTask(with: url)
        guard let data = data else { return }
        parseParticularScore(html: String(data: data, encoding: .utf8)!)
    }
    
    public mutating func allScores() {
        let url = URL(string: allGamesURL)!
        let (data, _, _) = URLSession.shared.synchronousDataTask(with: url)
        guard let data = data else { return }
        parseAllScores(html: String(data: data, encoding: .utf8)!)
    }
    
    func parseParticularScore(html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)

            let rows: Array = try doc.select("tbody tr").array()
            for row in rows {
                let lines = "\(row)".split(whereSeparator: \.isNewline)
                for line in lines {
                    switch line {
                    case let str where str.contains("game_date"):
                        let regex = />(\d\d\d\d-\d\d-\d\d)</
                        if let result = str.firstMatch(of: regex) {
                            print("PUP match: ", result.1)
                        }
                    case let str where str.contains("winner"):
                        let regex = /htm\">(.*?)<\/a/
                        if let result = str.firstMatch(of: regex) {
                            print("PUP match: ", result.1)
                        }
                    case let str where str.contains("loser"):
                        let regex = /htm\">(.*?)<\/a/
                        if let result = str.firstMatch(of: regex) {
                            print("PUP match: ", result.1)
                        }
                    case let str where str.contains("boxscore_word"):
                        let regex = /href=\"(.*)\"/
                        if let result = str.firstMatch(of: regex) {
                            print("PUP match: ", result.1)
                        }
                    case let str where str.contains("pts_win"):
                        let regex = /(\d+)<\//
                        if let result = str.firstMatch(of: regex) {
                            print("PUP match: ", result.1)
                        }
                    case let str where str.contains("pts_lose"):
                        let regex = /(\d+)<\//
                        if let result = str.firstMatch(of: regex) {
                            print("PUP match: ", result.1)
                        }
                    default:
                        break
                    }
                }
            }
        } catch Exception.Error(_, let message) {
            print("Message: \(message)")
        } catch {
            print("error")
        }
    }

    mutating func parseAllScores(html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rows: Array = try doc.select("tbody tr").array()
            for row in rows {
                var  game = Game()
                let lines = "\(row)".split(whereSeparator: \.isNewline)
                for line in lines {
                    switch line {
                    case let str where str.contains("pts_win"):
                        let regex = />(\d+)<\//
                        if let result = str.firstMatch(of: regex) {
                            game.winningScore = Int(result.1) ?? 0
                        }
                    case let str where str.contains("pts_lose"):
                        let regex = />(\d+)<\//
                        if let result = str.firstMatch(of: regex) {
                            game.losingScore = Int(result.1) ?? 0
                        }
                    case let str where str.contains("counter"):
                        let regex = />(\d+)<\//
                        if let result = str.firstMatch(of: regex) {
                            game.occurrences = Int(result.1) ?? 0
                        }
                    case let str where str.contains("last_game"):
                        let regex = /htm\">(.*?)<\//
                        if let result = str.firstMatch(of: regex) {
                            game.lastGame = String(result.1)
                        }
                    default:
                        break
                    }
                }
                games.append(game)
            }
        } catch Exception.Error(_, let message) {
            print("Message: \(message)")
        } catch {
            print("error")
        }
    }
    
}
