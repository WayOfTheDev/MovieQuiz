//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by D. K. on 13.08.24.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let questionFactory: QuestionFactoryProtocol
    private let statisticService: StatisticServiceProtocol

    init(statisticService: StatisticServiceProtocol, moviesLoader: MoviesLoader) {
        self.statisticService = statisticService
        self.questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: nil)
        self.questionFactory.delegate = self
    }
    
    func viewDidLoad() {
        questionFactory.loadData()
        viewController?.showLoadingIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let message = makeResultsMessage()
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.showQuizResults(viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect)
    }

    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = !currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        let bestGameDate = bestGame.date.dateTimeString
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))
        Средняя точность: \(accuracy)%
        """
        
        return message
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
