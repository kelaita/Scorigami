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

private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
private var isPortrait : Bool { UIDevice.current.orientation.isPortrait }

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel
    @State var gameData = GameData()
    @State var zoomView = false
    @State var scrollToCell: String = "0-0"

    var body: some View {
        VStack {
            HStack {
                if (zoomView) {
                    Button(action: {
                        zoomView = false
                    }) {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                            .imageScale(.large)
                    }
                }
                Spacer()
                NavigationLink(destination: AboutView()) {
                    Image(systemName: "info.circle").frame(width: 20)
                }
                Spacer().frame(width: 0, height: 40)
            }

            if (zoomView) {
                InteractiveView(viewModel: viewModel,
                                scrollToCell: $scrollToCell,
                                gameData: gameData).environmentObject(viewModel)
            } else {
                FullView(gameData: gameData,
                         scrollToCell: $scrollToCell,
                         zoomView: $zoomView).environmentObject(viewModel)
            }
            Spacer()
            OptionsUI(zoomView: $zoomView).environmentObject(viewModel).frame(maxWidth: .infinity, alignment: .trailing)
        }.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("🏈 Scorigami 🏈")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}

struct FullView: View {
    @State var gameData = GameData()
    @Binding var scrollToCell: String
    @Binding var zoomView: Bool
        
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    let layout = [
        GridItem(.adaptive(minimum:5), spacing: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("0").frame(maxWidth: .infinity, alignment: .leading).bold()
                Text("Winning Score").frame(maxWidth: .infinity, alignment: .center).bold()
                Text("73").frame(maxWidth: .infinity, alignment: .trailing).bold()
            }
            Spacer().frame(width:0, height: 15)
            ForEach(0...51, id: \.self) { losingScore in
                let row = viewModel.getGamesForLosingScore(
                    losingScore: losingScore)
                LazyHGrid(rows: layout, spacing: 0) {
                    ForEach(row, id: \.self) { cell in
                        cell.color
                            .frame(width: (idiom == .pad) ? 15 : 5,
                                   height:(idiom == .pad) ? 15 : 5)
                            .saturation(cell.saturation)
                            .padding(0)
                            .onTapGesture {
                                let _ = print("Clicked score: \(cell.id)")
                                scrollToCell = cell.id
                                zoomView = true
                            }
                    }
                }.padding(0).frame(maxWidth: .infinity)
            }
        }.preferredColorScheme(.dark)
    }
}

struct InteractiveView: View {
    @ObservedObject var viewModel: ScorigamiViewModel
    @Binding var scrollToCell: String
    @State var gameData = GameData()
    
    @State var showingAlert: Bool = false
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
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
                        Text("\nA game has ended with this score\n") +
                        Text(String(gameData.occurrences)) +
                        Text(" time") +
                        Text(gameData.plural) +
                        Text(".\n\nMost recently, this happened when the\n") +
                        Text(gameData.lastGame)
                    } else {
                        Text("\nSCORIGAMI!\n\n") +
                        Text("No game has ever ended\nwith this score...yet!")
                    }
                    
                })
                .id("root")
            }.padding(.all, 2.0)
                .preferredColorScheme(.dark)
                .onAppear {
                    reader.scrollTo(scrollToCell, anchor: .center)
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
            .id(cell.id)
        }
        
    }
}

struct OptionsUI: View {
    @Binding var zoomView: Bool

    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    @State var refreshView = 0
    @State var gradientType = 0
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer().frame(height: 20)
            if (zoomView) {
                Text("Tap score for info. Drag for more scores").bold()
            } else {
                Text("Tap a region to view scores").bold()
            }
            Spacer().frame(height: 80)
            HStack {
                VStack {
                    HStack {
                        Text("Gradient:").bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Picker("", selection: $refreshView) {
                            Text("Frequency").tag(0)
                            Text("Recency").tag(1)
                        }.pickerStyle(.segmented)
                            .padding(.trailing, 8)
                            .frame(width: 200, height: 30)
                            .onChange(of: refreshView) { tag in
                                gradientType = tag
                                viewModel.buildBoard(gradientType: tag)
                            }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            GradientLegend(minMaxes: viewModel.getMinMaxes(gradientType: gradientType))
                .frame(alignment: .trailing)
        }
        .background(Color(red: 0.0, green: 0.0, blue: 0.4))
    }
}

struct GradientLegend: View {
    let minMaxes: Array<String>
    
    var body: some View {
        HStack (spacing: 2) {
            Spacer().frame(maxWidth: .infinity, alignment: .leading)
            Text(minMaxes[0]).font(.system(size: 12))
                .frame(width: 125, alignment: .trailing)
                .lineLimit(1)
            Rectangle().frame(width: 200, height: 12)
                .foregroundColor(.clear)
                .background(LinearGradient(colors: [.black, .red], startPoint: .leading, endPoint: .trailing))
                .border(.white)
            Text(minMaxes[1]).font(.system(size: 12))
                .lineLimit(1)
                .frame(width: 40, alignment: .leading)
            Spacer().frame(width: 8, alignment: .leading)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let svm = ScorigamiViewModel()
//        ContentView(viewModel: svm)
//    }
//}
