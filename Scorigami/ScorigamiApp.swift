//
//  ScorigamiApp.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

@main
struct ScorigamiApp: App {
  let scorigami = ScorigamiViewModel()
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView(viewModel: scorigami).environmentObject(scorigami)
      }.navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

