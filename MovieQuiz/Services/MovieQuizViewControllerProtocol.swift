//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by D. K. on 13.08.24.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showQuizResults(_ results: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}
