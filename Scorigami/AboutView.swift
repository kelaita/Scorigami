//
//  AboutView.swift
//  Scorigami
//
//  Created by Paul Kelaita on 10/30/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Text("🏈 Welcome to Scorigami 🏈")
            Text("This is all about Scorigami")
            Text("Who came up with the term")
            Text("Data thanks to Pro-Football-Reference.com")
            Text("Go see my GitHub")
        }.navigationBarTitle("About Scorigami")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
