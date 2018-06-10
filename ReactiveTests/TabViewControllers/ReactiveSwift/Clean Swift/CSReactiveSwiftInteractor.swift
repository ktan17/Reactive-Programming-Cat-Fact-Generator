//
//  CSReactiveSwiftInteractor.swift
//  ReactiveTests
//
//  Created by Kevin Tan on 6/9/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import Foundation

protocol RASwiftInteractorOutputHandler {
    func presentCatFact(response: CSReactiveSwiftDataModels.CatFact.ResponseData)
}

class CSReactiveSwiftInteractor: RASwiftViewControllerOutputHandler {
    
    var presenter: RASwiftInteractorOutputHandler?
    var worker = CSReactiveSwiftWorker()
    
    /// Retrieve a cat fact from the API. The network call has been delegated to a Worker.
    func getCatFact() {
        worker.getCatFactSignalProducer().startWithResult { (result) in
            // This closure is invoked when the Signal sends us a result.
            
            let response = CSReactiveSwiftDataModels.CatFact.ResponseData(
                text: result.value,
                errorDescription: result.error?.localizedDescription
            )
            self.presenter?.presentCatFact(response: response)
        }
    }
    
}
