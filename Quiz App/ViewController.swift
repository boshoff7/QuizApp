//
//  ViewController.swift
//  Quiz App
//
//  Created by Chris Boshoff on 2022/02/22.
//

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, ResultViewControllerProtocol {
    
   
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rootStackView: UIStackView!
    
    
    
    var model = QuizModel()
    var questions = [Questions]()
    var currentQuestionIndex = 0
    var numCorrect = 0
    
    var resultDialog: ResultViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Initialise the result dialog
        resultDialog = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController
        resultDialog?.modalPresentationStyle = .overCurrentContext
        resultDialog?.delegate = self
        
        // Set self as the delegate and datasource for the tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        // Dynamic row heights
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // Set up the model
        model.delegate = self
        model.getQuestions()
        
        // Reload the tableView
        tableView.reloadData()
    }
    
    func slideInQuestion() {
        // Set the initial state
        stackViewTrailingConstraint.constant = -1000
        stackViewLeadingConstraint.constant = 1000
        rootStackView.alpha = 0
        view.layoutIfNeeded()
        
        // Animate to the end state
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.stackViewLeadingConstraint.constant = 0
            self.stackViewTrailingConstraint.constant = 0
            self.rootStackView.alpha = 1
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideOutQuestion() {
        // Set the initial state
        stackViewTrailingConstraint.constant = 0
        stackViewLeadingConstraint.constant = 0
        rootStackView.alpha = 1
        view.layoutIfNeeded()
        
        // Animate to the end state
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.stackViewLeadingConstraint.constant = -1000
            self.stackViewTrailingConstraint.constant = 1000
            self.rootStackView.alpha = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)

        
    }
    
    func displayQuestion() {
        
        // Check if there are questions and check that the currentQuestionIndex is not out of bounds
        
        guard questions.count > 0 && currentQuestionIndex < questions.count else {
            return
        }
        
        // Display the question text
        questionLabel.text = questions[currentQuestionIndex].question
        
       
        // Reload the answers table
        tableView.reloadData()
        
        
       slideInQuestion()
    }

    
    // MARK: - Quiz Protocol Method
    
    func questionsRetrieved(_ questions: [Questions]) {
        
        // Get a reference to the questions
        self.questions = questions
  
        // Check if we should restore the state, before showing question #1
        let savedIndex = StateManager.retrieveValue(key: StateManager.questionIndexKey) as? Int
        
        if savedIndex != nil && savedIndex! < self.questions.count {
            
            // Set the current question to the saved index
            currentQuestionIndex = savedIndex!
            
            // Retrieve the number correct from storage
            let savedNumCorrect = StateManager.retrieveValue(key: StateManager.numCorrectKey) as? Int
            
            if savedNumCorrect != nil {
                numCorrect = savedNumCorrect!
            }
        }
        
        // Display first question
        displayQuestion()
    }
    
    // MARK: - UITableview Delegate Methods
    
    // How many rows do I want to display - Datasource Protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Make sure that the question array actually contains a question
        guard questions.count > 0 else {
            return 0
        }
        
        // Return the number of answers for this question
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.answers != nil {
            return currentQuestion.answers!.count
        } else {
            return 0
        }
    }
    
    // asking the viewcontroller what cell should i be displaying
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        // Customise it
        let label = cell.viewWithTag(1) as? UILabel
        
        if label != nil {
            let question = questions[currentQuestionIndex]

            if question.answers != nil && indexPath.row < question.answers!.count {
                // Set the answer text for the label
                label!.text = question.answers![indexPath.row]
            }
       
        }
        
        // Return Cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var titleText = ""
        
        // Usdr has tapped on a row, check if its the correct answer
        let question = questions[currentQuestionIndex]
        
        if  question.correctAnswerIndex! == indexPath.row {
            // User got it right
            
            titleText = "Correct!"
            numCorrect += 1
            
        } else {
            // User got it wrong
            
            titleText = "Wrong!"
            
        }
        
        DispatchQueue.main.async {
            self.slideOutQuestion()
        }
        
        // Show the popup
        if resultDialog != nil {
            
            // Customise the dialog text
            resultDialog!.titleText = titleText
            resultDialog!.feedbackText = question.feedback!
            resultDialog!.buttonText = "Next"
            
            
            DispatchQueue.main.async {
                self.present(self.resultDialog!, animated: true, completion: nil)
            }
            
        }
        
   
    }
    
    // MARK: - ResultViewControllerProtocol Method
    
    func dialogDismissed() {
        
        // Increment the currentQuestionIndex
        currentQuestionIndex += 1
        
        if currentQuestionIndex == questions.count {
            
            // The user has just answered the last question
            // Show a summary dialog
            if resultDialog != nil {
                
                // Customise the dialog text
                resultDialog!.titleText = "Summary"
                resultDialog!.feedbackText = "You got \(numCorrect) correct out of \(questions.count) questions"
                resultDialog!.buttonText = "Restart"
                
                present(resultDialog!, animated: true, completion: nil)
                
                StateManager.clearState()
            }
            
        } else if currentQuestionIndex > questions.count {
            // Restart
            numCorrect = 0
            currentQuestionIndex = 0
            displayQuestion()
        }
        else if currentQuestionIndex < questions.count {
            
            // Then we have more questions to show
            // Display the next question
            displayQuestion()

            // Save the state
            StateManager.saveState(numCorrect: numCorrect, questionIndex: currentQuestionIndex)

        }
        
        
    }
    
}
