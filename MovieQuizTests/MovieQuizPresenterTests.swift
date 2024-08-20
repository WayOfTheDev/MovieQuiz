//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by D. K. on 13.08.24.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func showQuizResults(_ results: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

final class MockStatisticService: StatisticServiceProtocol {
    var gamesCount: Int = 0
    var totalAccuracy: Double = 0.0
    var bestGame: GameResult = GameResult(correct: 0, total: 0, date: Date())
    
    func store(correct: Int, total: Int) {}
}

struct MockMoviesLoader: MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        // логика мока для теста
    }
}

final class MockNetworkClient: NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        // Реализация мока
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let mockStatisticService = MockStatisticService()
        let mockNetworkClient = MockNetworkClient()
        let mockMoviesLoader = MoviesLoader(networkClient: mockNetworkClient)
        let sut = MovieQuizPresenter(statisticService: mockStatisticService, moviesLoader: mockMoviesLoader)
        sut.viewController = viewControllerMock
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // When
        let viewModel = sut.convert(model: question)
        
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
