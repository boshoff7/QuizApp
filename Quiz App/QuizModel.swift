//
//  QuizModel.swift
//  Quiz App
//
//  Created by Chris Boshoff on 2022/02/22.
//

import Foundation

protocol QuizProtocol {
    
    func questionsRetrieved(_ question:[Questions])
}

class QuizModel {
    
    var delegate: QuizProtocol?
    
    func getQuestions() {
        
        // Fetch the questions
        getRemoteJsonFile()
        
    }
    
    func getLocalJsonFile() {
        
        // Get bundle path to json file
        
        let path = Bundle.main.path(forResource: "QuestionData", ofType: "json")
        
        // Double check that the path isn't nil
        guard path != nil else {
            print("Couldn't find the json data file")
            return
        }
        
        // Create URL from the path
        let url = URL(fileURLWithPath: path!)
        
        
        do {
            // Get the data from the url
            let data = try Data(contentsOf: url)
            
            // Try to decode the data into objects
            let decoder = JSONDecoder()
            let array = try decoder.decode([Questions].self, from: data)
            
            // Notify the delegate of the parsed objects
            delegate?.questionsRetrieved(array)
            
        } catch {
            // Error: Couldn't download the data at that URL
        }
        
    }
    
    func getRemoteJsonFile() {
        
        // Get a URL object
        let urlString = "https://codewithchris.com/code/QuestionData.json"
        
        let url = URL(string: urlString)
        
        guard url != nil else {
            print("Could not create the URL object")
            return
        }
        
        // Get a URL session object
        let session = URLSession.shared
        
        // Get a data task object
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            
            // Check that there was not a error
            if error == nil && data != nil {
                
                do {
                    // Create a JSON decoder
                    let decoder = JSONDecoder()
                    
                    // Pasre JSON
                    let array = try decoder.decode([Questions].self, from: data!)
                    
                    
                    // Use the main thread to notify the view controller for UI wrok
                    DispatchQueue.main.async {
                        // Notify the delegate
                        self.delegate?.questionsRetrieved(array)
                    }
                    
                } catch {
                    print("Could not parse JSON")
                }
                
            }
            
            
            
        }
        
        // Call resume on the data
        dataTask.resume()
    }
}
