//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by D. K. on 30.06.24.
//

import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }
    func loadData()
    func requestNextQuestion()
}
