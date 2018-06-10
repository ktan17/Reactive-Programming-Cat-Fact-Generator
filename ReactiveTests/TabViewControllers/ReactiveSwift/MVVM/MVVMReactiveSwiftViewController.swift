//
//  ReactiveSwiftViewController.swift
//  ReactiveTests
//
//  Created by Kevin Tan on 6/7/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit
import ReactiveSwift

class MVVMReactiveSwiftViewController: CatViewController {
    
    lazy var viewModel = MVVMReactiveSwiftViewModel()
    
    override func generateTapped(_ sender: UIButton!) {
        // This is the function called when the "Generate" button is tapped.
        
        self.viewModel.getCatFactSignalProducer().startWithResult { (result) in
            // This closure is invoked when the Signal sends us a result.
            
            if let error = result.error {
                self.factLabel.text = error.localizedDescription
                return
            }
            
            self.factLabel.text = result.value!
        }
    }
    
}
