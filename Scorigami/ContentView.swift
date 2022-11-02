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

enum ColorMap {
    case redSpecturm, fullSpectrum
}

private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
private var isPortrait : Bool { UIDevice.current.orientation.isPortrait }

struct ContentView: View {
    @ObservedObject var viewModel: ScorigamiViewModel
    @State var gameData = GameData()
    @State var scrollToCell: String = "0-0"

    var body: some View {
        VStack {
            HStack {
                if (viewModel.zoomView) {
                    Button(action: {
                        viewModel.toggleZoomView()
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

            if (viewModel.zoomView) {
                InteractiveView(viewModel: viewModel,
                                scrollToCell: $scrollToCell,
                                gameData: gameData).environmentObject(viewModel)
            } else {
                FullView(gameData: gameData,
                         scrollToCell: $scrollToCell).environmentObject(viewModel)
            }
            Spacer()
            OptionsUI().environmentObject(viewModel).frame(maxWidth: .infinity, alignment: .trailing)
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
        
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    let layout = [
        GridItem(.fixed((idiom == .pad) ? 15 : 5), spacing: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("0").frame(maxWidth: .infinity, alignment: .leading).bold()
                Text("Winning Score").frame(maxWidth: .infinity, alignment: .center).bold()
                Text(String(viewModel.getHighestWinningScore()))
                    .frame(maxWidth: .infinity, alignment: .trailing).bold()
            }
            Spacer().frame(width:0, height: 15)
            ForEach(0...viewModel.getHighestLosingScore(), id: \.self) { losingScore in
                let row = viewModel.getGamesForLosingScore(
                    losingScore: losingScore)
                LazyHGrid(rows: layout, spacing: 0) {
                    ForEach(row, id: \.self) { cell in
                        let colorAndSat = viewModel.getColorAndSat(val: cell.saturation)
                        Rectangle()
                            .foregroundColor(colorAndSat.0)
                            .frame(width: (idiom == .pad) ? 15 : 5,
                                   height:(idiom == .pad) ? 15 : 5)
                            .saturation(colorAndSat.1)
                            .padding(0)
                            .onTapGesture {
                                let _ = print("Clicked score: \(cell.label)")
                                if cell.label != "" {
                                    scrollToCell = cell.id
                                    viewModel.toggleZoomView()
                                }
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
                    ForEach(0...viewModel.getHighestLosingScore(), id: \.self) { losingScore in
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
            }
                .border(Color(red: 0.0, green: 0.0, blue: 0.4), width: 4)
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
            let colorAndSat = viewModel.getColorAndSat(val: cell.saturation)

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
                    .underline(color: colorAndSat.0)
            }
            .padding(0)
            .frame(width: 40, height: 40)
            .background(colorAndSat.0)
            .saturation(colorAndSat.1)
            .foregroundColor(viewModel.getTextColor(val: cell.saturation))
            .border(cell.color, width: 0)
            .cornerRadius(0)
            .buttonStyle(BorderlessButtonStyle())
            .id(cell.id)
        }
        
    }
}

struct OptionsUI: View {
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    @State var refreshView = 0
    @State var gradientType = 0
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer().frame(height: 20)
            if (viewModel.zoomView) {
                Text("Tap score for info. Drag for more scores").bold()
            } else {
                Text("Tap a region to view scores").bold()
            }
            Spacer().frame(height: 80)
            HStack {
                VStack {
                    HStack {
                        Text("Gradient:").bold()
                                         .frame(width: 75, alignment: .leading)
                                         .padding(.leading)
                        Picker("", selection: $refreshView) {
                            Text("Frequency").tag(0)
                            Text("Recency").tag(1)
                        }.pickerStyle(.segmented)
                            .frame(width: 200, height: 30)
                            .onChange(of: refreshView) { tag in
                                gradientType = tag
                                viewModel.buildBoard(gradientType: tag)
                            }
                        Spacer().frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            Spacer().frame(height: 7)
            GradientLegend(gradientType: $gradientType)
            .environmentObject(viewModel)
        }
        .background(Color(red: 0.0, green: 0.0, blue: 0.4))
    }
}

struct GradientLegend: View {
    @Binding var gradientType: Int
    @EnvironmentObject var viewModel: ScorigamiViewModel
    
    var body: some View {
        let minMaxes = viewModel.getMinMaxes(gradientType: gradientType)
        HStack (spacing: 2) {
            Spacer().frame(width: 20, alignment: .leading)
            Text(minMaxes[0])
                .font(.system(size: 12))
                .frame(alignment: .leading)
                .padding(.trailing, 4)
                .padding(.leading, 20)
            if viewModel.colorMapType == .redSpecturm {
                HStack(spacing: 0) {
                    ForEach(1...40, id: \.self) { box in
                        Color.red
                            .frame(width: 4, height: 20)
                            .padding(0)
                            .saturation(Double(box) * 2.5 / 100.0)
                    }
                }.border(.white)
            } else { // else it is .fullSpectrum
                HStack {
                    let grad = Gradient(colors: [.blue, .cyan, .green, .yellow, .red])
                    LinearGradient(gradient: grad, startPoint: .leading, endPoint: .trailing)
                        .frame(width: 160, height: 20)
                }
            }
            Text(minMaxes[1]).font(.system(size: 12)).frame(width: 40)
            Button(action: viewModel.changeColorMapType ) {
                HStack{
                    Text("Full Color")
                    Image(systemName: viewModel.colorMapType == .fullSpectrum ?
                                        "checkmark.square": "square")
                }.font(.system(size: 12)).foregroundColor(.white)
            }.frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 5)
            Spacer()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let svm = ScorigamiViewModel()
//        ContentView(viewModel: svm)
//    }
//}
