//
//  OverallView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 11/15/22.
//

import SwiftUI

private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

struct OverallView: View {
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
              withAnimation {
                viewModel.toggleZoomView()
              }
            }
          }
          .transition(.scale)
      }
    }.padding(0).frame(maxWidth: .infinity)
  }
}

