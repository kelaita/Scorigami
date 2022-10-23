//
//  ContentView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel = ScorigamiViewModel()
    @State var gameInfo: String = "Game Info"
    
    var body: some View {
        
        ScrollView([.horizontal, .vertical]) {
            Text(gameInfo)
            VStack {
                ForEach(0...51, id: \.self) { losingScore in
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 20), spacing: 2)]) {
                        let row = viewModel.getGamesForLosingScore(losingScore: losingScore)
                        ForEach(row, id: \.self) { cell in
                            let _ = print("grabbing losing score \(cell.id), \(cell.color)")
                            //Text(cell.id)
                            Rectangle()
                                .fill(cell.color)
                                .frame(width: 10, height: 10)
                                .padding(1)
                                .gesture(TapGesture().onEnded {
                                    let _ = print(cell.id, cell.occurrences)
                                    gameInfo = cell.id + ", " + String(cell.occurrences) + " times"
                                })
                        }
                    }
                }
            }

        }.padding(.all, 2.0)

        
        
        
//        VStack {
//            Grid() {
//                ForEach(0 ..< 23) { game in
//    ForEach(viewModel.board, id: \.self) { row in

//                    GridRow {
//                        Text(String(viewModel.gameCells.count))
            //                        let _ = print("square for " + cell.id + " " +
            //                                      cell.color + " " + cell.occurrences)

//                        Button(action: {
//                            }) {
//                                Text(String(viewModel.gameCells[game].lastGame))
//                            }
//                    }
//                }
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let svm = ScorigamiViewModel()
        ContentView(viewModel: svm)
    }
}
