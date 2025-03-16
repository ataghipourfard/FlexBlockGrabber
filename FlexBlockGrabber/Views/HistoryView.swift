//
//  HistoryView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Block History")
                    .font(.title)
                    .padding()
                
                Text("Your grabbed blocks will appear here")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Block History")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
