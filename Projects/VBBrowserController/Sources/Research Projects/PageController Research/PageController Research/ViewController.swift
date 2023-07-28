//
//  ViewController.swift
//  PageController Research
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa
import CoreText

class ViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
    
    }
    
}

extension ViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        
        guard let theTextField = obj.object as? NSTextField else { return }
        guard let lastCharacter = theTextField.stringValue.last else { return }
        guard lastCharacter.isNumber == false else { return }
        
        print(lastCharacter)
        theTextField.stringValue.removeLast()
        
    }
    
}
