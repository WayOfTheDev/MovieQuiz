//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by D. K. on 30.06.24.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
