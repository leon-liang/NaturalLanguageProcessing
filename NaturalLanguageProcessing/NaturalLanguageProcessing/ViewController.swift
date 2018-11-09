//
//  ViewController.swift
//  NaturalLanguageProcessing
//
//  Created by Leon Liang on 02/11/2018.
//  Copyright © 2018 Leon Liang. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var textLbl: UITextField!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var goBtn: UIButton!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "iKQcbXAZkjw3Nry2Am3XQVz2E", consumerSecret: "hM5CEG5nAhuRjVMWWt4Hjyqxlp17kctABMPgQSNtWXKfVbGWpF")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textLbl.layer.borderWidth = 1.0
        textLbl.layer.borderColor = UIColor.white.cgColor
        goBtn.layer.borderWidth = 1.0
        goBtn.layer.borderColor = UIColor.white.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        textLbl.endEditing(true)
    }

    @IBAction func goBtnPressed(_ sender: Any) {
        if let searchText = textLbl.text {
            statusLbl.text = "Making request to the Twitter API..."
            swifter.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.statusLbl.text = "success"
                
                do {
                    self.statusLbl.text = "Analysing the Tweets..."
                    let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                    
                    var sentimentScore = 0
                    
                    for prediction in predictions {
                        let sentiment = prediction.label
                        
                        if sentiment == "Pos" {
                            sentimentScore += 1
                        } else if sentiment == "Neg" {
                            sentimentScore -= 1
                        }
                    }
                    
                    if sentimentScore > 20 {
                        self.resultLbl.text = "Result: Excellent"
                    } else if sentimentScore > 10 {
                        self.resultLbl.text = "Result: Great"
                    } else if sentimentScore > 0 {
                        self.resultLbl.text = "Result: Good"
                    } else if sentimentScore == 0 {
                        self.resultLbl.text = "Result: Average"
                    } else if sentimentScore > -10 {
                        self.resultLbl.text = "Result: Bad"
                    } else if sentimentScore > -20 {
                        self.resultLbl.text = "Result: Terrible"
                    } else {
                        self.resultLbl.text = "Result: Dreadful"
                    }
                    
                }
                catch {
                    print(error)
                    self.statusLbl.text = "Analysing the tweets failed, \(error)"
                }
                
            }) { (error) in
                print("There was an error with the Twitter API Request, \(error)")
                self.statusLbl.text = "Error with the API Request, \(error)"
            }
        }
    }
    
}

