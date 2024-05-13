//
//  QuizResponse.swift
//  QuizApp
//
//  Created by Ruchira  on 13/05/24.
//

import Foundation

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    var answer: String {
        return correct_answer
    }

    var options: [String] {
        var options = incorrect_answers
        options.insert(correct_answer, at: Int.random(in: 0..<options.count + 1))
        return options
    }
}
