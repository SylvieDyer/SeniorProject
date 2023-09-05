//
//  ModuleView.swift
//  CSDS395
//
//  Created by Sylvie Dyer on 9/2/23.
//

import SwiftUI

// template for module pages 
struct ModuleView: View {
  
    let name: String
    let blocks: [String]
    
    @State private var showOverview = false
    var body: some View {
        
        HStack {
            // Module Title
            Text(name).foregroundColor(.indigo).font(.title2).fontWeight(.heavy)
            Spacer()
            // Help Button
            Button(action: {showOverview.toggle()}) {
                // help icon
                Label("", systemImage: "questionmark").foregroundColor(.gray)
            }
            // pop-up
            .sheet(isPresented: $showOverview) {
                DescView(name: name)    // view with content
            }
        }.padding(.horizontal, 50)
        
        // the blocks associated witht he module
        List{
            // iterate through list of blocks
            ForEach(blocks, id: \.self) { blockName in
                // individual module
                NavigationLink(blockName){
                    Text(blockName).font(.title2)
                    // some content (redirect to questions / some other view
                }
                .foregroundColor(.indigo.opacity(0.7)).font(.title3).fontWeight(.heavy)
                .padding([.bottom], 50)
            }
        }
    }
}


struct View_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(controller: AppController())
    }
}
