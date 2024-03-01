//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import MFPuzzle

struct StartView: View {
    @Binding var router: MenuView.Router?
    private let startFactory = StartFactory()
    
    var body: some View {
        VStack {
			self.startFactory.configure {_ in 
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
