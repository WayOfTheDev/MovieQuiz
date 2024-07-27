//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by D. K. on 27.06.24.
//

import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] (result: Result<MostPopularMovies, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    private var movies: [MostPopularMovie] = []
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(image: "The Godfather",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Dark Knight",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Kill Bill",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Avengers",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Deadpool",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Green Knight",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Old",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "Tesla",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "Vivarium",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false)
//    ]
    
    private func truncateTitle(_ title: String, maxLength: Int) -> String {
        if title.count <= maxLength {
            return title
        } else {
            let index = title.index(title.startIndex, offsetBy: maxLength - 3)
            return String(title[..<index]) + "..."
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let actualRating = Int(round(Float(movie.rating) ?? 0))
            var questionRating: Int
            var correctAnswer: Bool

            if actualRating == 10 {
                questionRating = Int.random(in: 5...8)
                correctAnswer = false
            } else if actualRating == 1 {
                questionRating = Int.random(in: 1...7)
                correctAnswer = true
            } else if actualRating >= 8 && actualRating <= 9 {
                questionRating = Int.random(in: 4...8)
                correctAnswer = actualRating > questionRating
            } else {
                let difference = Int.random(in: 1...5)
                let isHigher = Bool.random()
                
                if isHigher {
                    questionRating = min(actualRating + difference, 9)
                    correctAnswer = false
                } else {
                    questionRating = max(actualRating - difference, 2)
                    correctAnswer = true
                }
            }
            
            let movieTitle = truncateTitle(movie.title, maxLength: 30)

            let text = "Рейтинг фильма: \(movieTitle) больше чем \(questionRating)?"
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
}
