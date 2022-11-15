//
//  ScorigamiViewModel.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/20/22.
//

import SwiftUI

class ScorigamiViewModel: ObservableObject {
  
  var model: Scorigami
  
  var uniqueId = 0
  var colorMap: [(r: Double, g: Double, b: Double)] = []
  
  enum ColorMapType {
    case redSpecturm, fullSpectrum
  }
  @Published var colorMapType: ColorMapType = .fullSpectrum
  
  enum GradientType {
    case frequency, recency
  }
  @Published var gradientType: GradientType = .frequency
  
  @Published var zoomView: Bool = false
  var scrollToCell: String = ""
  
  public struct Cell: Hashable, Identifiable {
    public var id: String
    var color: Color
    var occurrences: Int
    var lastGame: String
    var gamesUrl: String
    var label: String
    var frequencySaturation: Double
    var recencySaturation: Double
    var plural: String
  }
  
  private var board: [[Cell]] = []
  
  init() {
    model = ScorigamiViewModel.createScorigami()
    if isNetworkAvailable() {
      model.games.sort { $0.winningScore < $1.winningScore }
      buildBoard()
      buildColorMap()
    }
  }
  
  static func createScorigami() -> Scorigami {
    Scorigami()
  }
  
  func isNetworkAvailable() -> Bool {
    let networkReachability = NetworkReachability()
    return networkReachability.reachable
  }
  
  func buildBoard() {
    // clear out the board and rebuild it; this is only done once at
    // initialization, but it can be called repeatedly, that's just slow
    //
    board = []
    for row in 0...getHighestWinningScore() {
      board.append([Cell]())
      for col in 0...getHighestWinningScore() {
        board[row].append(searchGames(winningScore: col, losingScore: row))
      }
    }
    uniqueId += 1
  }
  
  func searchGames(winningScore: Int, losingScore: Int) -> Cell {
    let index = model.games.firstIndex {
      $0.winningScore == winningScore &&
      $0.losingScore == losingScore }
    
    // for a particular score, build a cell for it; include a unique-id
    // which is simply the score preceded by an ever-incrementing int
    // that will ensure uniqueness across redraws
    //
    var cell = Cell(id: String(uniqueId) + ":" +
                        String(winningScore) + "-" +
                        String(losingScore),
                    color: .black,
                    occurrences: 0,
                    lastGame: "",
                    gamesUrl: "",
                    label: String(winningScore) + "-" + String(losingScore),
                    frequencySaturation: 0.0,
                    recencySaturation: 0.0,
                    plural: "s")
    
    if index != nil {
      cell.occurrences = model.games[index!].occurrences
      cell.color = Color.red
      cell.lastGame = model.games[index!].lastGame
      cell.gamesUrl = model.getParticularScoreURL(winningScore: winningScore,
                                                  losingScore: losingScore)
      cell.frequencySaturation = getSaturation(
        min: 1,
        max: model.getMaxOccorrences(),
        val: cell.occurrences,
        skewLower: 0.01,
        skewUpper: 0.55)
      cell.recencySaturation = getSaturation(
        min: model.earliestGameYear,
        max: Calendar.current.component(.year, from: Date()),
        val: getMostRecentYear(gameDesc: cell.lastGame),
        skewLower: 0.0,
        skewUpper: 1.0)
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
  
  public func getHighestLosingScore() -> Int {
    model.highestLosingScore
  }
  
  public func getGamesForLosingScore(losingScore: Int) -> Array<Cell> {
    return board[losingScore]
  }
  
  public func getMostRecentYear(gameDesc: String) -> Int {
    let year = gameDesc.suffix(4)
    return Int(year) ?? model.earliestGameYear
  }
  
  public func getSaturation(min: Int,
                            max: Int,
                            val: Int,
                            skewLower: Double,
                            skewUpper: Double) -> Double {
    let floorSaturationPercent = skewLower
    
    // the following improves the appearance by making
    // highest intensity before the very top
    //
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
  
  public func fixScrollCell(cell: String) -> String {
    // this basically takes a score in W-L format and returns u:W-L
    // where 'u' is an increasing int that gives it uniqueness;
    // also check for invalid score where L > W
    //
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
  
  public func getMinMaxes() -> Array<String> {
    // used for the color map legend
    //
    if (gradientType == .frequency) {
      return ["1", String(model.highestCounter)]
    }
    else {
      return [String(model.earliestGameYear),
              String(Calendar.current.component(.year, from: Date()))]
    }
  }
  
  public func buildColorMap() -> Void {
    var r: Double
    var g: Double
    var b: Double
    
    // blue to cyan
    for val in (1...25) {
      r = 0.0
      g = Double(val) * 4.0 / 100.0
      b = 1.0
      colorMap.append((r: r, g: g, b: b))
    }
    // cyan to green
    for val in (1...25) {
      r = 0.0
      g = 1.0
      b = 1.0 - (Double(val) * 4.0 / 100.0)
      colorMap.append((r: r, g: g, b: b))
    }
    // green to yellow
    for val in (1...25) {
      r = Double(val) * 4.0 / 100.0
      g = 1.0
      b = 0.0
      colorMap.append((r: r, g: g, b: b))
    }
    // yellow to red
    for val in (1...25) {
      r = 1.0
      g = 1.0 - (Double(val) * 4.0 / 100.0)
      b = 0.0
      colorMap.append((r: r, g: g, b: b))
    }
  }
  
  public func getColorAndSat(cell: Cell) -> (Color, Double) {
    // return the proper color and saturation based on gradient type,
    // full color status, and whether scorigami or not (black)
    //
    var val: Double
    
    if gradientType == .frequency {
      val = cell.frequencySaturation
    } else {
      val = cell.recencySaturation
    }
    if val == 0.0 {
      return (Color.black, 1.0)
    }
    if colorMapType == .redSpecturm {
      return (Color.red, val)
    }

    var index: Int = Int(val * 100.0)
    
    if index > 99 {
      index = 99
    }
    var r: Double
    var g: Double
    var b: Double
    (r, g, b) = colorMap[index]
    return (Color(red: r, green: g, blue: b), 1.0)
  }
  
  public func getTextColor(cell: Cell) -> Color {
    var val: Double
    if gradientType == .frequency {
      val = cell.frequencySaturation
    } else {
      val = cell.recencySaturation
    }
    
    if val < 0.2 || val > 0.8 ||
        colorMapType == .redSpecturm {
      return Color.white
    }
    return Color.black
  }
  
  public func changeColorMapType() {
    if colorMapType == .redSpecturm {
      colorMapType = .fullSpectrum
    } else {
      colorMapType = .redSpecturm
    }
  }
  
  public func toggleZoomView() {
    zoomView.toggle()
  }
  
  public func setGradientType(type: Int) {
    if type == 0 {
      gradientType = .frequency
    } else {
      gradientType = .recency
    }
  }
  
}
