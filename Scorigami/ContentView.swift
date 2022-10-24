//
//  ContentView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel = ScorigamiViewModel()
    @State var showingAlert: Bool = false
    @State var score: String = ""
    @State var occurrences: Int = 0
    @State var lastGame: String = ""
    @State var gamesUrl: String = "https://www.pro-football-reference.com/"
    
    var body: some View {
        
        ScrollView([.horizontal, .vertical]) {
            VStack {
                ForEach(0...51, id: \.self) { losingScore in
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 20), spacing: 2)]) {
                        let row = viewModel.getGamesForLosingScore(losingScore: losingScore)
                        ForEach(row, id: \.self) { cell in
                            Button(action: {
                                self.score = cell.label
                                self.occurrences = cell.occurrences
                                self.lastGame = cell.lastGame
                                self.gamesUrl = cell.gamesUrl
                                self.showingAlert = true
                            }) {
                                Text(cell.label)
                                    .font(.system(size: 12)
                                        .weight(.bold))
                                    .underline(color: cell.color)
                                
                            }
                            .padding(0)
                            .frame(width: 40, height: 40)
                            .background(cell.color)
                            .foregroundColor(.white)
                            .border(cell.color, width: 0)
                            .cornerRadius(0)
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }.alert("Game Score: " + score, isPresented: $showingAlert, actions: {
                    Button("Done", role: .cancel, action: {})
                    Link("View games", destination: URL(string: gamesUrl)!)
                }, message: {
                    Text("It happened " + String(occurrences) + " times, most recently " + lastGame)
                })
        }.padding(.all, 2.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let svm = ScorigamiViewModel()
        ContentView(viewModel: svm)
    }
}
