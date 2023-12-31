//
//  HomeView.swift
//  CSDS395
//
//  Created by Sylvie Dyer on 9/1/23.
//

import SwiftUI
import CoreData


struct HomeView: View {
    // stores module names
    @ObservedObject var controller: AppController
    let colorManager: ColorManager = ColorManager()
    let hardCodedLastCompletedModule: String = "CS Foundations"
    let dbManager : DBManager = DBManager()
    @Environment (\.dismiss) var dismiss
    @State private var modulesValidMap: [String : Bool] = [:]
    @State private var userID: String = UserDefaults.standard.string(forKey: "id") ?? "ID"
    @State private var lastCompleted : [String] = []
    @State private var lastCompletedDifficulty : String = ""
    @State private var qodQuestions: QuestionList = QuestionList(qlist: [])
    @State private var isQodNavigationActive = false

    var body: some View {
            // wraps app in navigation to switch to user-screen
            NavigationView{
                if isQodNavigationActive {
                    NavigationLink(
                        destination: QuestionView(moduleName: "qod", blockName: "qod", questionDifficulty: QuestionDifficulty.easy, controller: controller, questionList: qodQuestions).navigationBarBackButtonHidden(true),
                        isActive: $isQodNavigationActive
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
                } else {
                    VStack {
                        // section to replace when navigating btwn modules
                        NavigationStack{
                            // header
                            HStack(alignment: .lastTextBaseline, spacing:0){
                                Text("QUICODE").font(.largeTitle).bold().padding(.leading, 15)
                                    .fontWidth(.expanded)
                                    .font(.callout)
                                Spacer()
                                Button(
                                    action: {
                                        controller.viewController.setAsUser()},
                                    label: {
                                        Image(systemName: "person").foregroundColor(.gray).padding(.horizontal, 15)
                                    })
                            }.padding(.bottom, -5).padding(.top, 20)
                            List{
                                // welcome section
                                Section{
                                    // will be dynamic with user name -- Text("Welcome Back, \(user.name)
                                    HStack {
                                        Text("Hi \(UserDefaults.standard.string(forKey: "firstname") ?? "User")!").bold().font(.title2)
                                        Spacer()
                                        Image(systemName: "star.fill").foregroundColor(.black)
                                        if(lastCompleted.count == 3) {
                                            Text(String(ProgressUtils.getPoints(blockName: lastCompleted[1], difficulty: lastCompleted[2])))
                                        }
                                    }
                                }
                                .listRowBackground(
                                    Capsule()
                                        .fill(colorManager.getDarkGreen())
                                )
                                
                                // "quick code" section
                                Section{
                                    HStack{
                                        Button("Question of the Day", action: {
                                            Task.detached {
                                                do {
                                                    let questions = await controller.getQuestions(name: "qod", difficulty: "")
                                                    await MainActor.run {
                                                        self.qodQuestions = questions
                                                        self.isQodNavigationActive = true
                                                    }
                                                }
                                            }
                                        })
                                        .foregroundColor(Color.black).font(.title3).fontWeight(.heavy)
                                        .padding(20)
                                        Spacer()
                                    }
                                }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 40)
                                        .fill(Color.white)
                                )
                                // iterate through list of modules
                                ForEach(controller.getModuleNames(), id: \.self) { moduleName in
                                    if (moduleName == "CS Foundations" || modulesValidMap[moduleName] ?? true) {
                                        Section{
                                            // individual module
                                            NavigationLink(){
                                                ModuleView(name: moduleName, controller: controller)
                                            } label: {
                                                VStack{
                                                    Text(moduleName).padding(.top, 10)
                                                    Spacer()
                                                    // progress Bar
                                                    HStack{
                                                        Spacer()
                                                        ForEach(controller.getBlocks(name: moduleName), id: \.self) { blockName in
                                                            if(lastCompleted.count > 0) {
                                                                if(ProgressUtils.getValue(inputValue: [blockName]) < ProgressUtils.getValue(inputValue: [lastCompleted[1]])
                                                                   || (ProgressUtils.getValue(inputValue: [blockName]) == ProgressUtils.getValue(inputValue: [lastCompleted[1]]) && ProgressUtils.getValue(inputValue: [lastCompletedDifficulty]) == 3)) {
                                                                    Image(systemName: "star.fill").foregroundColor(.black)
                                                                }
                                                                else {
                                                                    Image(systemName: "star").foregroundColor(.black)
                                                                }
                                                            }
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                            }
                                            .foregroundColor(.black).font(.title3).fontWeight(.heavy)
                                            .padding([.bottom], 30)
                                        }.padding([.bottom], 30)
                                    } else {
                                        Section{
                                            // individual module
                                            Text(moduleName).padding(.top, 10)
                                                .frame(alignment: .center)
                                                .foregroundColor(.gray).font(.title3).fontWeight(.heavy)
                                                .padding([.bottom], 30)
                                        }.padding([.bottom], 30)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 40)
                                        .fill(colorManager.getMidGreen())
                                ) // color each list section
                                
                            }.listStyle(InsetGroupedListStyle()) // (remove drop down option for list sectoins)
                            .onAppear() {
                                Task{
                                    do {
                                        lastCompleted =  await queryAll();
                                        lastCompletedDifficulty = lastCompleted[2];
                                        modulesValidMap = getModulesValidMap(lastCompleted: lastCompleted);
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func queryAll() async -> [String] {
        let response = await dbManager.queryDB(userID: userID)
        return [response["moduleName"] ?? "", response["blockName"] ?? "", response["questionDifficulty"] ?? ""]
    }
    
    func queryDifficulty() async -> String{
        let response = await dbManager.queryDB(userID: userID)
        return response["questionDifficulty"] ?? ""
    }
    
    func getModulesValidMap(lastCompleted: [String?]) -> [String : Bool] {
        var moduleMap: [String : Bool] = [:]
        let progressModuleVal = ProgressUtils.getValue(inputValue: [lastCompleted[0] ?? ""])
        let progressBlockVal = ProgressUtils.getValue(inputValue: [lastCompleted[1] ?? ""])
        
        for moduleName in controller.getModuleNames(){
            let thisModuleVal = ProgressUtils.getValue(inputValue: [moduleName])
            
            if(thisModuleVal <= progressModuleVal || (thisModuleVal == progressModuleVal + 100 && ProgressUtils.isLastBlock(blockVal: progressBlockVal))) {
                moduleMap[moduleName] = true
            } else {
                moduleMap[moduleName] = false
            }
        }
        return moduleMap
    }
}
