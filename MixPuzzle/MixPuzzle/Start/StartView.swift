//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI

struct StartView: View {
    @Binding var router: MenuView.Router?
    
    var body: some View {
        VStack {
            StartScene() {_ in
                self.router = nil
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    @State var router: MenuView.Router? = nil
    return StartView(router: $router)
}
