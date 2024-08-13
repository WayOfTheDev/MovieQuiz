//
//  GameResult.swift
//  MovieQuiz
//
//  Created by D. K. on 04.07.24.
//

import Foundation


struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
