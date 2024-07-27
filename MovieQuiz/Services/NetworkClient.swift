//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by D. K. on 22.07.24.
//

import Foundation


/// Отвечает за загрузку данных по URL
struct NetworkClient {

    private enum NetworkError: Error {
        case codeError
        case noData
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Проверяем наличие данных
            guard let data = data else {
                handler(.failure(NetworkError.noData))
                return
            }
            
            // Возвращаем данные
            handler(.success(data))
        }
        
        task.resume()
    }
}
