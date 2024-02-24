//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI

struct OptionsView: View {
    @Binding var router: MenuView.Router?
    var body: some View {
        Button("Press back") {
            self.router = nil
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    @State var router: MenuView.Router? = .toStart
    return OptionsView(router: $router)
}
