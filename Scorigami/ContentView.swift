//
//  ContentView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel = ScorigamiViewModel()
    
    @State var refreshView = 0
    @State var updater: Bool = false
    
    @State var showingAlert: Bool = false
    @State var score: String = ""
    @State var occurrences: Int = 0
    @State var lastGame: String = ""
    @State var saturation: Double = 0.2
    @State var gamesUrl: String = ""
    @State var plural: String = "s"
    
    var body: some View {
        ScrollViewReader { reader in
            ZStack {
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
                                        self.saturation = cell.saturation
                                        self.plural = cell.plural
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
                                    .saturation(cell.saturation)
                                    .foregroundColor(.white)
                                    .border(cell.color, width: 0)
                                    .cornerRadius(0)
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }.alert("Game Score: " + score, isPresented: $showingAlert, actions: {
                        if occurrences > 0 {
                            Button("Done", role: .cancel, action: {})
                            Link("View games", destination: URL(string: gamesUrl)!)
                        }
                    }, message: {
                        if occurrences > 0 {
                            Text("It happened ") +
                            Text(String(occurrences)).bold() +
                            Text(" time") +
                            Text(plural) +
                            Text(", most recently ") +
                            Text(lastGame)
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
            Grid {
                GridRow {
                    Button(action: {
                        reader.scrollTo("root", anchor: .topLeading)
                    }) {
                        Text("Reset")
                    }.background(.white)
                        .frame(width: 85, height: 60)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    HStack {
                        Text("Gradient")
                        Picker("", selection: $refreshView) {
                            Text("Frequency").tag(0)
                            Text("Recent Games").tag(1)
                        }.pickerStyle(.menu)
                            .background(.white)
                            .frame(width: 150, height: 40)
                            .cornerRadius(8)
                            .onChange(of: refreshView) { tag in
                                viewModel.buildBoard(gradientVal: tag)
                            }
                    }.frame(maxWidth: .infinity, alignment: .trailing)
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
