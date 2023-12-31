//
//  NextButton.swift
//  CSDS395
//
//  Created by Sylvie Dyer on 11/4/23.
//

import Swift

class NextButton {
  
    static func validate(selected: [String], correct: [String], questionType: QuestionType) -> Bool {
//        print("VALIDATING QUESTION RESPONSE: ")
//        print(selected)
//        print(correct)
//        
        switch (questionType){
            // for drag and drop
        case .dragAndDrop:
            // TODO: must be in order
            if selected.isEmpty {
                return false
            }
            for index in 0...correct.count - 1{
                if (selected[index] != correct[index]){
                    return false
                }
            }
            break
            
        case .multipleChoice:
            if selected.isEmpty {
                return false
            }
//            print("returning \(correct[0] == selected[0]) for multiple choice")
            return correct[0] == selected[0]
            
        case .multiSelect:
            if selected.count != correct.count {
                return false
            }
            for answer in selected {
                // if correct doesn't contain option
                if (!correct.contains(answer)){
//                    print("returning false for Multi Select")
                    return false
                }
            }
            break
            
        default:
            return false
        }
        
        return true
    }
}
