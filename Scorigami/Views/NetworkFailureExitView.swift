//
//  NetworkFailureExitView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 11/15/22.
//

import SwiftUI

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
