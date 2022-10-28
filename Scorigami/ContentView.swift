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
    @State var zoomView = true
    @State var scrollToTopNotice: UUID?
    @State var scrollToCell: String = "0-0"

    var body: some View {
        if (zoomView) {
            InteractiveView(viewModel: viewModel,
                            scrollToTopNotice: $scrollToTopNotice,
                            scrollToCell: $scrollToCell,
                            gameData: gameData).environmentObject(viewModel)
        } else {
            FullView(gameData: gameData,
                     scrollToTopNotice: $scrollToTopNotice,
                     scrollToCell: $scrollToCell,
                     zoomView: $zoomView).environmentObject(viewModel)
        }
        OptionsUI(zoomView: $zoomView,
                  scrollToTopNotice: $scrollToTopNotice).environmentObject(viewModel)
    }
}

struct FullView: View {
    @State var gameData = GameData()
    @Binding var scrollToTopNotice: UUID?
    @Binding var scrollToCell: String
    @Binding var zoomView: Bool
        
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    let layout = [
        GridItem(.adaptive(minimum:5), spacing: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("0").frame(maxWidth: .infinity, alignment: .leading)
                Text("Winning Score").frame(maxWidth: .infinity, alignment: .center)
                Text("73").frame(maxWidth: .infinity, alignment: .trailing)
            }
            ForEach(0...51, id: \.self) { losingScore in
                let row = viewModel.getGamesForLosingScore(
                    losingScore: losingScore)
                LazyVGrid(columns: layout, spacing: 0) {
                    ForEach(row, id: \.self) { cell in
                        cell.color.frame(width: 6, height: 6)
                            .saturation(cell.saturation)
                            .padding(0)
                            .onTapGesture {
                                print("PUP: 11111 \(cell.id)")
                                scrollToCell = cell.id
                                zoomView = true
                            }
                    }
                }.padding(0)
            }
        }.preferredColorScheme(.dark)
    }
}

struct InteractiveView: View {
    @ObservedObject var viewModel: ScorigamiViewModel
    @Binding var scrollToTopNotice: UUID?
    @Binding var scrollToCell: String
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
                    .onChange(of: scrollToTopNotice) { id in
                        guard id != nil else { return }
                        withAnimation {
                            reader.scrollTo(scrollToCell, anchor: .topLeading)
                        }
                    }
                    .onAppear {
                        reader.scrollTo(scrollToCell, anchor: .topLeading)
                    }
            }
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
            .id(cell.label)
        }
        
    }
}

struct OptionsUI: View {
    //let reader: ScrollViewProxy
    @Binding var zoomView: Bool
    @Binding var scrollToTopNotice: UUID?

    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    @State var refreshView = 0
    
    var body: some View {
        HStack {
            if (zoomView) {
                Button(action: {
                    scrollToTopNotice = UUID()
                }) {
                    Text("Reset")
                }.background(.white)
                //.frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            VStack {
                HStack {
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
                }.frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("View:")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Picker("", selection: $zoomView) {
                        Text("Fit on Screen").tag(false)
                        Text("Scrollable").tag(true)
                    }.pickerStyle(.menu)
                        .background(.white)
                        .padding(.trailing, 8)
                        .frame(width: 150, height: 80)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .trailing)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let svm = ScorigamiViewModel()
//        ContentView(viewModel: svm)
//    }
//}
