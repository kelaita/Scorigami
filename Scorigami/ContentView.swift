//
//  ContentView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

private let UIBackground = Color(.black)

private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

let iPhoneCellHeight: CGFloat = 8.0
let iPhoneCellWidth: CGFloat = 4.5
let iPhoneScreenWidth: CGFloat = 333

struct ContentView: View {
  @ObservedObject var viewModel: ScorigamiViewModel
  let networkAvailable: Bool
  
  var body: some View {
    if !networkAvailable {
      // if no network, put up a screen with exit as the only option;
      // no else needed since we're exiting here
      //
      NetworkFailureExitView()
    }
    VStack {
      TopOptions()
      if (viewModel.zoomView) {
        InteractiveView()
      } else {
        FullView()
      }
      Spacer()
      OptionsUI()
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

struct NetworkFailureExitView: View {
  var body: some View {
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
}

struct TopOptions: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  var body: some View {
    HStack {
      if (viewModel.zoomView) {
        // if we're in zoom view, add a back button to Full View
        //
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
  }
}

struct FullView: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  var body: some View {
    VStack(spacing: 0) {
      // add the winning score labels across the top (x axis) by 5's.
      //
      WinningScoreLabels()
      Spacer().frame(width:0, height: 15)
      
      // the "losing scores" are the rows; just put a small rectangle for
      // each score cell - can't interact with it, only shows color val
      //
      ForEach(0...viewModel.getHighestLosingScore(), id: \.self) { losingScore in
        HStack {
          // put up the Losing score label down the y-axis if in that multipe
          //
          if (losingScore % 5 == 0) {
            Text(String(losingScore))
              .font(.system(size: 10))
              .frame(width: 18, height: 3)
              .padding(0)
          } else {
            Spacer().frame(width: 18)
          }
          let row = viewModel.getGamesForLosingScore(losingScore: losingScore)
          // now render that row
          //
          LosingScoreRow(row: row)
        }
      }
    }.preferredColorScheme(.dark)
  }
}

struct WinningScoreLabels: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel

  var body: some View {
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
  }
}

struct LosingScoreRow: View {
  let row: Array<ScorigamiViewModel.Cell>
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  let layout = [
    GridItem(.fixed((idiom == .pad) ? iPhoneCellHeight * 2 : iPhoneCellHeight),
             spacing: 0)
  ]
  var body: some View {
    LazyHGrid(rows: layout, spacing: 0) {
      ForEach(row, id: \.self) { cell in
        let colorAndSat = viewModel.getColorAndSat(cell: cell)
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

struct InteractiveView: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  var body: some View {
    ScrollViewReader { reader in
      ScrollView([.horizontal, .vertical], showsIndicators: false) {
        VStack {
          ForEach(0...viewModel.getHighestLosingScore(), id: \.self) { losingScore in
            LazyHGrid(rows: [GridItem(.adaptive(minimum: 20), spacing: 2)]) {
              ScoreCells(losingScore: losingScore)
            }
          }
        }
      }
      .border(UIBackground, width: 4)
      .preferredColorScheme(.dark)
      .onAppear {
        reader.scrollTo(viewModel.scrollToCell, anchor: .center)
      }
    }
  }
}

struct ScoreCells: View {
  let losingScore: Int
  @State var showingAlert: Bool = false
  @State var score: String = ""
  @State var occurrences: Int = 0
  @State var gamesUrl: String = ""
  @State var lastGame: String = ""
  @State var plural: String = ""
  
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  var body: some View {
    // again, each row is for a losing score; unlike in full view, these
    // cells will be interactive with score labels and clickable for
    // drilldown info
    //
    let row = viewModel.getGamesForLosingScore(losingScore: losingScore)
    ForEach(row, id: \.self) { cell in
      let colorAndSat = viewModel.getColorAndSat(cell: cell)
      // we need an "id" for each cell because that is how we will
      // locate a cell and center it in the scrollview
      //
      Button(action: {
        score = cell.label
        occurrences = cell.occurrences
        gamesUrl = cell.gamesUrl
        lastGame = cell.lastGame
        plural = cell.plural
        showingAlert = true
      }) {
        Text(cell.label)
          .font(.system(size: 12)
            .weight(.bold))
          .underline(color: colorAndSat.0)
      }
      .frame(width: 40, height: 40)
      .background(colorAndSat.0)
      .saturation(colorAndSat.1)
      .foregroundColor(viewModel.getTextColor(cell: cell))
      .border(cell.color, width: 0)
      .cornerRadius(4)
      .buttonStyle(BorderlessButtonStyle())
      .id(cell.id)
      .alert("Game Score: " + score, isPresented: $showingAlert, actions: {
        if occurrences > 0 {
          Button("Done", role: .cancel, action: {})
          Link("View games", destination: URL(string: gamesUrl)!)
        }
      }, message: {
        if occurrences > 0 {
          Text("\nA game has ended with this score\n") +
          Text(String(occurrences)) +
          Text(" time") +
          Text(plural) +
          Text(".\n\nMost recently, this happened when the\n") +
          Text(lastGame)
        } else {
          Text("\nSCORIGAMI!\n\n") +
          Text("No game has ever ended\nwith this score...yet!")
        }
      })
    }
    
  }
}

struct OptionsUI: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  @State var refreshView = 0
  
  // place all the UI options at the bottom
  //
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
    .frame(maxWidth: .infinity, alignment: .trailing)
  }
}

struct GradientLegend: View {
  @EnvironmentObject var viewModel: ScorigamiViewModel
  
  // the legend reflects frequency or recency and includes min/max values;
  // it also has two different color ramp options
  //
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
      // add the max for the legend, then the color map type button
      //
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
