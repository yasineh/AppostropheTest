// Created by Yasin Ehsani

import SwiftUI

struct NavBar: View {

    var body: some View {
        HStack {
            Spacer()
            Image("logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 28)
                .foregroundColor(.white)
            
            Spacer()
            
            
        }
    }
}
