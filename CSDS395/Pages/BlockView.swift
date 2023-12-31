//
//  BlockView.swift
//  CSDS395
//
//  Created by Sylvie Dyer on 11/16/23.
//

import SwiftUI

struct BlockView: View {
    
    var moduleName: String
    var blockName: String
    var controller: AppController
    let colorManager: ColorManager = ColorManager()
    let dbManager : DBManager = DBManager()
    @State private var showOverview = false
    @State private var difficultiesValidMap: [String : Bool] = [:]
    @State private var questionList: QuestionList = QuestionList(qlist: [])
    @State private var isNavigationActive = false
    @State private var currDifficulty = QuestionDifficulty.easy
    @State private var userID: String = UserDefaults.standard.string(forKey: "id") ?? "ID"

    @State private var trueVal = true
    @State private var lastCompleted : [String] = []
    
    var body: some View {
        if isNavigationActive {
            QuestionView(moduleName: moduleName, blockName: blockName, questionDifficulty: currDifficulty, controller: controller, questionList: questionList).navigationBarBackButtonHidden(true)
        } else {
            VStack{
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
                }.padding(.bottom, -5)
                List {
                    // block title
                    Section{
                        VStack{
                            Spacer()
                            HStack {
                                VStack(alignment:.leading){
                                    // Module Title
                                    Text(moduleName).foregroundColor(Color.black).font(.title2).fontWeight(.bold)
                                    
                                    Text(blockName).foregroundColor(Color.black).font(.title).fontWeight(.heavy)
                                }
                                Spacer()
                                // Help Button
                                Button(action: {showOverview.toggle()}) {
                                    // help icon
                                    Label("", systemImage: "questionmark").foregroundColor(.black)
                                }
                                // pop-up
                                .sheet(isPresented: $showOverview) {
                                    DescView(controller: controller, blockName: blockName)    // view with content for current block
                                }
                            }.padding(20)
                            HStack{
                                let difficulties = ["easy", "medium","hard"]
                                ForEach(difficulties, id: \.self) { difficulty in
                                    if(ProgressUtils.getValue(inputValue: [blockName, difficulty]) <= ProgressUtils.getValue(inputValue: lastCompleted)) {
                                        Image(systemName: "star.fill")
                                    }
                                    else {
                                        Image(systemName: "star")
                                    }
                                }
                                
                            }.padding(10)
                        }
                        
                    }.listRowBackground(RoundedRectangle(cornerRadius: 40).fill(colorManager.getLightGreyLavendar()))
                        .padding([.bottom],10)
                        .onAppear() {
                            Task{
                                do {
                                    lastCompleted = await queryBlockAndDifficulty()
                                    difficultiesValidMap = getDifficultiesValidMap(lastCompleted: lastCompleted)
                                }
                            }
                        }
                    
                    // EASY
                    Section {
                        // individual module
                        HStack{
                            Button("Easy", action: {
                                Task.detached {
                                    do {
                                        let questions = await controller.getQuestions(name: getMappedBlockName(blockName: blockName), difficulty: "easy")
                                        let mainQueue = DispatchQueue.main
                                        mainQueue.async {
                                            self.questionList = questions
                                            self.currDifficulty = QuestionDifficulty.easy
                                            self.isNavigationActive = true
                                        }
                                    }
                                }
                            })
                            .foregroundColor(Color.black).font(.title3).fontWeight(.heavy)
                            .padding(20)
                            Spacer()
                            if(ProgressUtils.getValue(inputValue: [blockName, "easy"]) <= ProgressUtils.getValue(inputValue: lastCompleted)) {
                                Image(systemName: "star.fill")
                            }
                            else {
                                Image(systemName: "star")
                            }
                        }
                        
                        
                    }.listRowBackground(RoundedRectangle(cornerRadius: 40).fill(colorManager.getLightGreen()))// color each list section
                    
                    // MEDIUM
                    Section {
                        // individual module
                        HStack{
                            if(difficultiesValidMap["medium"] ?? true) {
                                Button("Medium", action: {
                                    Task.detached {
                                        do {
                                            let questions = await controller.getQuestions(name: getMappedBlockName(blockName: blockName), difficulty: "medium")
                                            let mainQueue = DispatchQueue.main
                                            mainQueue.async {
                                                self.questionList = questions
                                                self.currDifficulty = QuestionDifficulty.medium
                                                self.isNavigationActive = true
                                            }
                                        }
                                    }
                                })
                                .foregroundColor(Color.black).font(.title3).fontWeight(.heavy)
                                .padding(20)
                                Spacer()
                                if(ProgressUtils.getValue(inputValue: [blockName, "medium"]) <= ProgressUtils.getValue(inputValue: lastCompleted)) {
                                    Image(systemName: "star.fill")
                                }
                                else {
                                    Image(systemName: "star")
                                }
                            } else {
                                Text("Medium")
                                    .foregroundColor(Color.gray).font(.title3).fontWeight(.heavy)
                                    .padding(20)
                                Spacer()
                                Image(systemName: "star")
                                    .renderingMode(.template)
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }.listRowBackground(RoundedRectangle(cornerRadius: 40).fill(colorManager.getMidGreen()))// color each list section
                    
                    // HARD
                    Section {
                        // individual module
                        HStack{
                            if(difficultiesValidMap["hard"] ?? true) {
                                Button("Hard", action: {
                                    Task.detached {
                                        do {
                                            let questions = await controller.getQuestions(name: getMappedBlockName(blockName: blockName), difficulty: "hard")
                                            let mainQueue = DispatchQueue.main
                                            mainQueue.async {
                                                self.questionList = questions
                                                self.currDifficulty = QuestionDifficulty.hard
                                                self.isNavigationActive = true
                                            }
                                        }
                                    }
                                })
                                .foregroundColor(Color.black).font(.title3).fontWeight(.heavy)
                                .padding(20)
                                Spacer()
                                if(ProgressUtils.getValue(inputValue: [blockName, "hard"]) <= ProgressUtils.getValue(inputValue: lastCompleted)) {
                                    Image(systemName: "star.fill")
                                }
                                else {
                                    Image(systemName: "star")
                                }
                            } else {
                                Text("Hard")
                                    .foregroundColor(Color.gray).font(.title3).fontWeight(.heavy)
                                    .padding(20)
                                Spacer()
                                Image(systemName: "star")
                                    .renderingMode(.template)
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }.listRowBackground(RoundedRectangle(cornerRadius: 40).fill(colorManager.getDarkGreen()))// color each list section
                    
                }.listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    
    func getMappedBlockName(blockName:String) -> String{
        return blockName.replacingOccurrences(of: " ", with: "")
    }
    
    func queryBlockAndDifficulty() async -> [String] {
        let response = await dbManager.queryDB(userID: userID)
        return [response["blockName"] ?? "", response["questionDifficulty"] ?? ""]
    }
    
    func getDifficultiesValidMap(lastCompleted: [String]) -> [String : Bool] {
        var blockMap: [String : Bool] = [:]
        let progressBlockVal = ProgressUtils.getValue(inputValue: [lastCompleted[0]])
        let progressDifficultyVal = ProgressUtils.getValue(inputValue: [lastCompleted[1]])
        let thisBlockVal = ProgressUtils.getValue(inputValue: [blockName])
        
        blockMap["easy"] = true
        blockMap["medium"] = progressDifficultyVal >= 1 && progressBlockVal == thisBlockVal || progressBlockVal > thisBlockVal
        blockMap["hard"] = progressDifficultyVal >= 2 && progressBlockVal == thisBlockVal || progressBlockVal > thisBlockVal

        return blockMap
    }
}
