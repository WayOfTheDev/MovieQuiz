import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let _ = currentQuestion else {
                return
            }
            handleAnswer(isCorrect: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let _ = currentQuestion else {
                return
            }
            handleAnswer(isCorrect: false)
    }
    
    
    private var alertPresenter: AlertPresenter!
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(viewController: self)
        
        if let customFontTextLabel = UIFont(
            name: "YS Display Bold",
            size: 20.0) {
            textLabel.font = customFontTextLabel
        } else {
            print("Не удалось загрузить шрифт YS Display Bold.")
        }
        
        if let customFontCounterLabel = UIFont(
            name: "YS Display Bold",
            size: 20.0) {
            counterLabel.font = customFontCounterLabel
        } else {
            print("Не удалось загрузить шрифт YS Display Bold.")
        }
        
        if let customFontQuestionLabel = UIFont(
            name: "YS Display Bold",
            size: 23.0) {
            questionLabel.font = customFontQuestionLabel
        } else {
            print("Не удалось загрузить шрифт YS Display Bold.")
        }
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    private let questionsAmount: Int = 10
    //private var questionFactory: QuestionFactory = QuestionFactory()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showNextQuestionOrResults() {
            if currentQuestionIndex == questionsAmount - 1 {
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
                
                let alertModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: message,
                    buttonText: "Сыграть ещё раз"
                ) { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
                
                alertPresenter.showAlert(with: alertModel)
            } else {
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func handleAnswer(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: isCorrect == currentQuestion.correctAnswer)
    }
    
//    private func show(quiz result: QuizResultsViewModel) {
//        let alert = UIAlertController(
//            title: result.title,
//            message: result.text,
//            preferredStyle: .alert)
//        
//        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
//            guard let self = self else { return }
//
//            self.currentQuestionIndex = 0
//            self.correctAnswers = 0
//            self.questionFactory?.requestNextQuestion()
//        }
//        
//        alert.addAction(action)
//        
//        self.present(alert, animated: true, completion: nil)
//    }
}
