//
//  CatFactSignalProducer.swift
//  ReactiveTests
//
//  Created by Kevin Tan on 6/9/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import ReactiveSwift
import Alamofire

/// All classes that conform to CatFactSignalProducer will receive a default implementation of
/// getCatFactSignalProducer()
protocol CatFactSignalProducer { }

extension CatFactSignalProducer {
    
    func getCatFactSignalProducer() -> SignalProducer<String, CatAPIError> {
        // Returns an observable Signal that fires when a response from the CatAPI is received.
        
        return SignalProducer<String, CatAPIError> { (observer, disposable) in
            Alamofire.request("https://cat-fact.herokuapp.com/facts/random", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response) in
                
                // Check if the request succeeded
                guard response.result.isSuccess else {
                    observer.send(error: CatAPIError.requestFailure(underlyingError: response.error!))
                    return
                }
                
                // Parse JSON
                guard let responseDict = response.result.value as? [String : Any],
                    let text = responseDict["text"] as? String else {
                        // This should never be called
                        observer.send(error: CatAPIError.JSONParseFailure)
                        return
                }
                
                // Send the fact String to the observer
                observer.send(value: text)
            })
        }
    }
    
}
