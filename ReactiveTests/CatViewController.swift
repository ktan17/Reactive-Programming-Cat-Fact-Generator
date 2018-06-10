//
//  ViewController.swift
//  ReactiveTests
//
//  Created by Kevin Tan on 6/7/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

/// Custom error enum for Cat API requests
enum CatAPIError: Error {
    case requestFailure(underlyingError: Error)
    case JSONParseFailure
}

/// Base class for each Tab View Controller
class CatViewController: UIViewController {

    @IBOutlet var factLabel: UILabel!
    
    @IBAction func generateTapped(_ sender: UIButton!) {
        fatalError("generatedTapped not implemented by subclass")
    }

}

