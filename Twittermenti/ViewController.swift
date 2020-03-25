//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = twitterSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "yourOwnAPIkey", consumerSecret: "yourOwnsecretKey")


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let prediction = try! sentimentClassifier.prediction(text: "@Apple is a very bad company.")
//        print(prediction.label)
        
        
    }

    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
    
    }
    
    func fetchTweets(){
        
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [twitterSentimentClassifierInput]()
                
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = twitterSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePredictions(with: tweets)
                
                
            }) { (error) in
                print("There was an error printing results \(error)")
            }
        }
    }
    
    func makePredictions(with tweets: [twitterSentimentClassifierInput]){
        
        do{
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos"{
                    sentimentScore += 1
                } else if sentiment == "Neg"{
                    sentimentScore -= 1
                }
            }
            
            self.updateUI(with: sentimentScore)
            
        } catch{
            print("There was an error predicting the output, \(error)")
        }
    }
    
    func updateUI(with sentimentScore: Int){
        if sentimentScore > 20{
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10{
            self.sentimentLabel.text = "😃"
        } else if sentimentScore > 0{
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0{
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10{
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20{
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
    
}

