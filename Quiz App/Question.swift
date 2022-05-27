//
//  Question.swift
//  Quiz App
//
//  Created by Chris Boshoff on 2022/02/22.
//

import Foundation

struct Questions: Codable {
    
    var question: String?
    var answers:[String]?
    var correctAnswerIndex: Int?
    var feedback: String?
    
    
}
