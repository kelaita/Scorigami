//
//  ContentView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

public class GameData {
    var score: String
    var occurrences: Int
    var lastGame: String
    var saturation: Double
    var gamesUrl: String
    var plural: String
    
    init() {
        score = ""
        occurrences = 0
        lastGame = ""
        saturation = 0.2
        gamesUrl = ""
        plural = "s"
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel
    @State var gameData = GameData()

    var body: some View {
        InteractiveView(viewModel: viewModel, gameData: gameData).environmentObject(viewModel)
    }
}

struct InteractiveView: View {
    @ObservedObject var viewModel: ScorigamiViewModel
    @State var gameData = GameData()

    @State var showingAlert: Bool = false

    var body: some View {
        ScrollViewReader { reader in
            ZStack {
                ScrollView([.horizontal, .vertical]) {
                    VStack {
                        ForEach(0...51, id: \.self) { losingScore in
                            LazyHGrid(rows: [GridItem(.adaptive(minimum: 20), spacing: 2)]) {
                                ScoreCell(losingScore: losingScore,
                                          showingAlert: $showingAlert,
                                          gameData: gameData).environmentObject(viewModel)
                            }
                        }
                    }.alert("Game Score: " + gameData.score, isPresented: $showingAlert, actions: {
                        if gameData.occurrences > 0 {
                            Button("Done", role: .cancel, action: {})
                            Link("View games", destination: URL(string: gameData.gamesUrl)!)
                        }
                    }, message: {
                        if gameData.occurrences > 0 {
                            Text("It happened ") +
                            Text(String(gameData.occurrences)).bold() +
                            Text(" time") +
                            Text(gameData.plural) +
                            Text(", most recently ") +
                            Text(gameData.lastGame)
                        } else {
                            Text("SCORIGAMI!").bold()
                        }
                        
                    })
                    .id("root")
                }.padding(.all, 2.0)
                    .preferredColorScheme(.dark)
                    .onAppear {
                        reader.scrollTo("root", anchor: .topLeading)
                    }
            }
            OptionsUI(reader: reader).environmentObject(viewModel)
        }
    }

}

struct ScoreCell: View {
    let losingScore: Int
    @Binding var showingAlert: Bool
    let gameData: GameData
    
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    var body: some View {
        let row = viewModel.getGamesForLosingScore(
            losingScore: losingScore)
        ForEach(row, id: \.self) { cell in
            
            Button(action: {
                gameData.score = cell.label
                gameData.occurrences = cell.occurrences
                gameData.lastGame = cell.lastGame
                gameData.gamesUrl = cell.gamesUrl
                gameData.saturation = cell.saturation
                gameData.plural = cell.plural
                showingAlert = true
            }) {
                Text(cell.label)
                    .font(.system(size: 12)
                        .weight(.bold))
                    .underline(color: cell.color)
                
            }
            .padding(0)
            .frame(width: 40, height: 40)
            .background(cell.color)
            .saturation(Double(cell.saturation))
            .foregroundColor(Color.white)
            .border(cell.color, width: 0)
            .cornerRadius(0)
            .buttonStyle(BorderlessButtonStyle())
        }
        
    }
}

struct OptionsUI: View {
    let reader: ScrollViewProxy
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    @State var refreshView = 0
    
    var body: some View {
        HStack {
            Button(action: {
                reader.scrollTo("root", anchor: .topLeading)
            }) {
                Text("Reset")
            }.background(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("Gradient:")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Picker("", selection: $refreshView) {
                Text("Frequency").tag(0)
                Text("Recency").tag(1)
            }.pickerStyle(.menu)
                .background(.white)
                .padding(.trailing, 8)
                .frame(width: 150, height: 80)
                .onChange(of: refreshView) { tag in
                    viewModel.buildBoard(gradientVal: tag)
                }
        }.frame(maxWidth: .infinity, alignment: .trailing)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let svm = ScorigamiViewModel()
//        ContentView(viewModel: svm)
//    }
//}
