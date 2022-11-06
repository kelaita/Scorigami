//
//  ScorigamiApp.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/19/22.
//

import SwiftUI

@main
struct ScorigamiApp: App {
  let networkReachability = NetworkReachability()
  let scorigami = ScorigamiViewModel()
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView(viewModel: scorigami,
                    networkAvailable: networkReachability.reachable)
        .environmentObject(scorigami)
      }.navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

