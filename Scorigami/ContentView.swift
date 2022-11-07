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
  var frequencySaturation: Double
  var recencySaturation: Double
  var gamesUrl: String
  var plural: String
  
  init() {
    score = ""
    occurrences = 0
    lastGame = ""
    frequencySaturation = 0.2
    recencySaturation = 0.2
    gamesUrl = ""
    plural = "s"
  }
}

enum ColorMap {
  case redSpecturm, fullSpectrum
}

let UIBackground = Color(.black)

private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

struct ContentView: View {
  @ObservedObject var viewModel: ScorigamiViewModel
  let networkAvailable: Bool
  
  var body: some View {
    if !networkAvailable {
      VStack {
        Image("scorigami_title")
          .resizable()
          .frame(width: 300, height: 50)
        Spacer().frame(height: 50)
        Button("Unfortunately, there doesn't appear\nto be an internet connection.\n\nTap here to exit and try again later.") {
          exit(1)
        }.foregroundColor(.white)
      }.preferredColorScheme(.dark)
    }
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
          Image(systemName: "info.circle.fill").imageScale(.large)
        }
        Spacer().frame(width: 0, height: 40)
      }
      
      if (viewModel.zoomView) {
        InteractiveView(viewModel: viewModel).environmentObject(viewModel)
      } else {
        FullView().environmentObject(viewModel)
      }
      Spacer()
      OptionsUI().environmentObject(viewModel).frame(maxWidth: .infinity, alignment: .trailing)
    }.navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Image("scorigami_title")
            .resizable()
            .frame(width: 300)
        }
      }
  }
}

struct FullView: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  let iPhoneCellHeight: CGFloat = 8.0
  let iPhoneCellWidth: CGFloat = 4.5
  let iPhoneScreenWidth: CGFloat = 333
  
  var body: some View {
    let layout = [
      GridItem(.fixed((idiom == .pad) ? iPhoneCellHeight * 2 : iPhoneCellHeight),
               spacing: 0)
    ]
    VStack(spacing: 0) {
      Text("Winning Score").frame(maxWidth: .infinity, alignment: .center)
        .font(.system(size: 12)).bold()
      HStack {
        let maxScoreLabel = viewModel.getHighestWinningScore() / 10 * 10
        ForEach(0...maxScoreLabel, id: \.self) { val in
          if val % 5 == 0 {
            Text(String(val))
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.system(size: 10))
          }
        }
      }.frame(width: (idiom == .pad) ?
                        iPhoneScreenWidth * 2.22 :
                        iPhoneScreenWidth,alignment: .leading)
      Spacer().frame(width:0, height: 15)
      ForEach(0...viewModel.getHighestLosingScore(), id: \.self) { losingScore in
        let row = viewModel.getGamesForLosingScore(
          losingScore: losingScore)
        HStack {
          if (losingScore % 5 == 0) {
            Text(String(losingScore))
              .font(.system(size: 10))
              .frame(width: 18, height: 3)
              .padding(0)
          } else {
            Spacer().frame(width: 18)
          }
          LazyHGrid(rows: layout, spacing: 0) {
            ForEach(row, id: \.self) { cell in
              let colorAndSat = viewModel.getColorAndSat(val:
                                    viewModel.gradientType == .frequency ?
                                          cell.frequencySaturation :
                                          cell.recencySaturation)
              Rectangle()
                .foregroundColor(colorAndSat.0)
                .frame(width: (idiom == .pad) ? iPhoneCellWidth * 2.5 : iPhoneCellWidth,
                       height:(idiom == .pad) ? iPhoneCellHeight * 2 : iPhoneCellHeight)
                .saturation(colorAndSat.1)
                .padding(0)
                .onTapGesture {
                  let _ = print("Clicked score: \(cell.label)")
                  if cell.label != "" {
                    viewModel.scrollToCell = cell.id
                    viewModel.toggleZoomView()
                  }
                }
            }
          }.padding(0).frame(maxWidth: .infinity)
        }
      }
    }.preferredColorScheme(.dark)
  }
}

struct InteractiveView: View {
  @ObservedObject var viewModel: ScorigamiViewModel
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
                        gameData: $gameData).environmentObject(viewModel)
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
      .border(UIBackground, width: 4)
      .preferredColorScheme(.dark)
      .onAppear {
        reader.scrollTo(viewModel.scrollToCell, anchor: .center)
      }
    }
  }
}

struct ScoreCell: View {
  let losingScore: Int
  @Binding var showingAlert: Bool
  @Binding var gameData: GameData
  
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  var body: some View {
    let row = viewModel.getGamesForLosingScore(
      losingScore: losingScore)
    ForEach(row, id: \.self) { cell in
      let colorAndSat = viewModel.getColorAndSat(val:
                                    viewModel.gradientType == .frequency ?
                                                 cell.frequencySaturation :
                                                 cell.recencySaturation)
      Button(action: {
        gameData.score = cell.label
        gameData.occurrences = cell.occurrences
        gameData.lastGame = cell.lastGame
        gameData.gamesUrl = cell.gamesUrl
        gameData.frequencySaturation = cell.frequencySaturation
        gameData.recencySaturation = cell.recencySaturation
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
      .foregroundColor(viewModel.getTextColor(val:
                          viewModel.gradientType == .frequency ?
                                              cell.frequencySaturation :
                                              cell.recencySaturation))
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
  
  var body: some View {
    VStack(spacing: 4) {
      Spacer().frame(height: 20)
      if (viewModel.zoomView) {
        Text("Tap score for info. Drag for more scores").bold()
      } else {
        Text("Tap a region to view scores").bold()
      }
      Spacer().frame(height: 40)
      HStack {
        VStack {
          HStack {
            Spacer().frame(width: 50, alignment: .leading)
            Picker("", selection: $refreshView) {
              Text("Frequency").tag(Int(0))
              Text("Recency").tag(Int(1))
            }.pickerStyle(.segmented)
              .frame(width: 200, height: 30)
              .onChange(of: refreshView) { tag in
                viewModel.setGradientType(type: tag)
              }
            Spacer().frame(maxWidth: .infinity, alignment: .trailing)
          }
        }
      }
      Spacer().frame(height: 7)
      GradientLegend()
      Spacer().frame(height: 7)
        .environmentObject(viewModel)
    }
    .background(UIBackground)
  }
}

struct GradientLegend: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  var body: some View {
    let minMaxes = viewModel.getMinMaxes()
    let colorSlices = 42
    HStack (spacing: 2) {
      Spacer().frame(width: 1, alignment: .leading)
      Text(minMaxes[0])
        .font(.system(size: 12)).bold()
        .frame(width: 30, alignment: .trailing)
        .padding(.trailing, 4)
        .padding(.leading, 20)
      if viewModel.colorMapType == .redSpecturm {
        HStack(spacing: 0) {
          ForEach(1...colorSlices, id: \.self) { box in
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
            .frame(width: CGFloat(colorSlices) * 4.0, height: 20)
        }
      }
      Text(minMaxes[1]).font(.system(size: 12)).frame(width: 40).bold()
      Button(action: viewModel.changeColorMapType ) {
        HStack{
          Text("Full Color")
            .bold()
            .font(.system(size: 12))
            .foregroundColor(.white)
          Image(systemName: viewModel.colorMapType == .fullSpectrum ?
                "checkmark.square": "square")
            .foregroundColor(.white)
        }
      }.frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 2)
      Spacer()
    }
  }
}
