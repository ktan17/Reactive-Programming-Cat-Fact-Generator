//
//  CSReactiveSwiftViewController.swift
//  ReactiveTests
//
//  Created by Kevin Tan on 6/9/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

protocol RASwiftViewControllerOutputHandler {
    func getCatFact()
}

class CSReactiveSwiftViewController: CatViewController, RASwiftPresenterOutputHandler {
    
    var interactor: RASwiftViewControllerOutputHandler?
    
    // MARK: - Setup
    
    private func configure() {
        // Form the VIP Cycle
        let viewController = self
        let interactor = CSReactiveSwiftInteractor()
        let presenter = CSReactiveSwiftPresenter()
        
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // MARK: - Implementation
    
    override func generateTapped(_ sender: UIButton!) {
        // When the "Generate" button is tapped, begin a VIP cycle for a cat fact.
        interactor?.getCatFact()
    }
    
    /// Change the text of the factLabel to display the result of the Cat API request.
    func displayCatFact(viewData: CSReactiveSwiftDataModels.CatFact.ViewData) {
        factLabel.text = viewData.displayText
    }
    
}
