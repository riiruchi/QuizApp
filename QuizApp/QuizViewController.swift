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
        questionLabel.accessibilityLabel = "Question"
        view.addSubview(questionLabel)

        progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textAlignment = .center
        progressLabel.accessibilityLabel = "Progress"
        view.addSubview(progressLabel)

        NSLayoutConstraint.activate([
                questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

                progressLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
                progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
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
                self.questionLabel.text = self.viewModel.questions[index].question
                self.progressLabel.text = "Question \(index + 1) of \(self.viewModel.questions.count)"
            }
     }
}

extension QuizViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let question = viewModel.questions[indexPath.row]
        cell.textLabel?.text = question.question
        cell.accessibilityLabel = question.question
        return cell
    }
}

extension QuizViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle question selection
    }
}
