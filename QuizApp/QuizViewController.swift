//
//  ViewController.swift
//  QuizApp
//
//  Created by Ruchira  on 13/05/24.
//

import UIKit
import Combine

class QuizViewController: UIViewController, QuizViewModelDelegate {
    
    private var tableView: UITableView!
    private var questionLabel: UILabel!
    private var progressLabel: UILabel!
    private var nextButton: UIButton!
    private var viewModel: QuizViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        viewModel = QuizViewModel(delegate: self)
        viewModel.fetchQuestions()
    }
    
    private func setupUI() {
            tableView = UITableView(frame: view.bounds)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
            view.addSubview(tableView)
            
            questionLabel = UILabel()
            questionLabel.translatesAutoresizingMaskIntoConstraints = false
            questionLabel.numberOfLines = 0
            questionLabel.textAlignment = .center
            questionLabel.accessibilityLabel = "Question"
            view.addSubview(questionLabel)
            
            progressLabel = UILabel()
            progressLabel.translatesAutoresizingMaskIntoConstraints = false
            progressLabel.textAlignment = .center
            progressLabel.accessibilityLabel = "Progress"
            view.addSubview(progressLabel)
            
            nextButton = UIButton(type: .system)
            nextButton.translatesAutoresizingMaskIntoConstraints = false
            nextButton.setTitle("Next", for: .normal)
            nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
            nextButton.isHidden = true
            view.addSubview(nextButton)
            
            NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    
                    questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                    questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    
                    nextButton.bottomAnchor.constraint(equalTo: progressLabel.topAnchor, constant: -16), // Adjusted constraint
                    
                    progressLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16), // Adjusted constraint
                    progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
        }
    
    @objc private func nextButtonTapped() {
        viewModel.moveToNextQuestion()
    }
    
    func didStartFetchingQuestions() {
        // Handle start fetching questions
    }
    
    func didFinishFetchingQuestions() {
        // Handle finish fetching questions
        tableView.reloadData()
    }
    
    func didUpdateQuestions(_ questions: [Question]) {
        // Handle update questions
    }
    
    func didUpdateQuestionIndex(_ index: Int) {
        DispatchQueue.main.async {
               if let question = self.viewModel.currentQuestion {
                   self.questionLabel.text = question.question
                   self.progressLabel.text = "Question \(index + 1) of \(self.viewModel.questions.count)"
                   self.tableView.reloadData()
                   self.nextButton.isHidden = true
               } else {
                   // No current question available, possibly due to index out of range
                   self.questionLabel.text = "No question available"
                   self.progressLabel.text = ""
                   self.tableView.reloadData()
                   self.nextButton.isHidden = true
               }
           }
    }
    
    func didFinishQuiz() {
        DispatchQueue.main.async {
            self.questionLabel.text = "Quiz Finished!"
            self.progressLabel.text = ""
            self.nextButton.isHidden = true
        }
    }
}

extension QuizViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let currentQuestion = viewModel.currentQuestion else {
                return 0 // No question available, so no options
            }
            return currentQuestion.options.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            guard let currentQuestion = viewModel.currentQuestion else {
                // No question available, so no options to display
                cell.textLabel?.text = ""
                cell.accessibilityLabel = ""
                return cell
            }
            
            let option = currentQuestion.options[indexPath.row]
            cell.textLabel?.text = option
            cell.accessibilityLabel = option
            
            return cell
        }
}

extension QuizViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            guard let currentQuestion = viewModel.currentQuestion else {
                // No question available, so no answer to check
                return
            }
            
            let selectedOption = currentQuestion.options[indexPath.row]
            viewModel.checkAnswer(selectedOption)
            nextButton.isHidden = false
        }
}
