//
//  CSReactiveSwiftPresenter.swift
//  ReactiveTests
//
//  Created by Kevin Tan on 6/9/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import Foundation

protocol RASwiftPresenterOutputHandler: class {
    func displayCatFact(viewData: CSReactiveSwiftDataModels.CatFact.ViewData)
}

class CSReactiveSwiftPresenter: RASwiftInteractorOutputHandler {

    weak var viewController: RASwiftPresenterOutputHandler?
    private let emojiString = "🐱😺😸😹😻😼😽🙀😿😾"
    
    /// If the Cat API request failed, send the error description to the view controller. Else, add
    /// a random cat emoji to the cat fact and send that instead.
    func presentCatFact(response: CSReactiveSwiftDataModels.CatFact.ResponseData) {
        guard response.errorDescription == nil else {
            // If the request failed and errorDescription is not nil, just send that.
            let viewData = CSReactiveSwiftDataModels.CatFact.ViewData(
                displayText: response.errorDescription!
            )
            viewController?.displayCatFact(viewData: viewData)
            
            return
        }
        
        // Generate a random cat emoji
        let offset = Int(arc4random_uniform(10))
        let emoji = emojiString[emojiString.index(emojiString.startIndex, offsetBy: offset)]
        
        let viewData = CSReactiveSwiftDataModels.CatFact.ViewData(
            displayText: response.text! + String(emoji)
        )
        viewController?.displayCatFact(viewData: viewData)
    }
    
}
