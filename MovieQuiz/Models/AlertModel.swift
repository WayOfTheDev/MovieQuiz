//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by D. K. on 02.07.24.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
