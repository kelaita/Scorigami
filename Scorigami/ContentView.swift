//
//  ContentView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel = ScorigamiViewModel()
    
    var body: some View {
        
        VStack {
            Grid() {
                ForEach(0 ..< 23) { game in
                    GridRow {
                        Text(String(viewModel.gameCells.count))
                        Button(action: {
                            }) {
                                Text(String(viewModel.gameCells[game].lastGame))
                            }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let svm = ScorigamiViewModel()
        ContentView(viewModel: svm)
    }
}
