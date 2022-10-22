//
//  ScorigamiViewModel.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/20/22.
//

import SwiftUI

class ScorigamiViewModel: ObservableObject {
    
    @Published var model: Scorigami
    
    init() {
        model = ScorigamiViewModel.createScorigami()
        model.games.sort { $0.winningScore < $1.winningScore }
    }
    
    static func createScorigami() -> Scorigami {
        Scorigami()
    }
    
    var gameCells: Array<Scorigami.Game> {
        model.games
    }
    
}
