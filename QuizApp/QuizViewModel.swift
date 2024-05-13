//
//  QuizViewModel.swift
//  QuizApp
//
//  Created by Ruchira  on 13/05/24.
//

import Foundation
import Combine


class QuizViewModel {
    
    private var delegate: QuizViewModelDelegate?
    private var cancellables: Set<AnyCancellable> = []
    private(set) var questions: [Question] = []
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: Question? {
        guard currentQuestionIndex >= 0 && currentQuestionIndex < questions.count else {
            return nil
        }
        return questions[currentQuestionIndex]
    }
    
    init(delegate: QuizViewModelDelegate) {
        self.delegate = delegate
    }
    
    func fetchQuestions() {
        delegate?.didStartFetchingQuestions()
        fetchQuestionsPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching questions: \(error)")
                case .finished:
                    break
                }
                self.delegate?.didFinishFetchingQuestions()
            }, receiveValue: { questions in
                self.questions = questions
                self.delegate?.didUpdateQuestions(questions)
                if !questions.isEmpty {
                    self.delegate?.didUpdateQuestionIndex(0)
                } else {
                    self.delegate?.didFinishQuiz()
                }
            })
            .store(in: &cancellables)
    }
    
    private func fetchQuestionsPublisher() -> AnyPublisher<[Question], Error> {
        let url = URL(string: "https://opentdb.com/api.php?amount=10&category=18&difficulty=easy&type=multiple")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: QuizResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .eraseToAnyPublisher()
    }
    
    func moveToNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex < questions.count {
            delegate?.didUpdateQuestionIndex(currentQuestionIndex)
        } else {
            delegate?.didFinishQuiz()
        }
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        guard let currentQuestion = currentQuestion else {
            print("No current question available.")
            return
        }

        let correctAnswer = currentQuestion.correct_answer
        let isCorrect = selectedAnswer == correctAnswer
        print("Selected answer is \(isCorrect ? "correct" : "incorrect")")
    }
}

protocol QuizViewModelDelegate: AnyObject {
    func didStartFetchingQuestions()
    func didFinishFetchingQuestions()
    func didUpdateQuestions(_ questions: [Question])
    func didUpdateQuestionIndex(_ index: Int)
    func didFinishQuiz()
}
