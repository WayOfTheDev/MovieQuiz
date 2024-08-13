import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(statisticService: StatisticServiceImplementation())
        presenter.viewController = self
        
        alertPresenter = AlertPresenter(viewController: self)
        
        setupUI()
        
        presenter.setupQuestionFactory(moviesLoader: MoviesLoader())
    }

    private func setupUI() {
        imageView.layer.cornerRadius = 20
        
        counterLabel.accessibilityIdentifier = "CounterLabel"
        questionLabel.accessibilityIdentifier = "QuestionLabel"
        
        activityIndicator.hidesWhenStopped = true
        
        let ysMediumFont = UIFont(name: "YS Display Medium", size: 20.0) ?? .systemFont(ofSize: 20.0)
        textLabel.font = ysMediumFont
        counterLabel.font = ysMediumFont
        yesButton.titleLabel?.font = ysMediumFont
        noButton.titleLabel?.font = ysMediumFont

        let ysBoldFont = UIFont(name: "YS Display Bold", size: 23.0) ?? .boldSystemFont(ofSize: 23.0)
        questionLabel.font = ysBoldFont
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func showQuizResults(_ results: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alertModel = AlertModel(
            title: results.title,
            message: message,
            buttonText: results.buttonText
        ) { [weak self] in
            self?.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(with: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            self?.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(with: model)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableAnswerButtons()
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableAnswerButtons()
        presenter.noButtonClicked()
    }
    
    private func disableAnswerButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}
