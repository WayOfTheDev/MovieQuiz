//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by D. K. on 02.07.24.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
