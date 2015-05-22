//
//  ViewController.swift
//  Calculatrix
//
//  Created by Leo Neves on 4/10/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var tochka: UIButton!{
        didSet {
            tochka.setTitle(decimalSeparator, forState: UIControlState.Normal)
        }
    }
    
    let decimalSeparator = formatter.decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = Calculatrix()
    
    // Свойство, запоминающее результаты оценки стэка,
    // сделанные в Моделе Calculatrix
    // Его тип Result определен как перечисление enum
    // в Моделе Calculatrix
    
    var displayResult: Calculatrix.Result = .Value(0.0) {
        // Наблюдатель Свойства модифицирует две IBOutlet метки
        didSet {
            // используется свойство description перечисления
            // enum Result
            display.text = displayResult.description
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.printa + "="
        }
    }
    
    // вычисляемое read-only свойство, отображающее UILabel display.text
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return formatter.numberFromString(displayText)?.doubleValue
            }
            return nil
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        //        println("digit = \(digit)");
        
        if userIsInTheMiddleOfTypingANumber {
            
            //----- Не пускаем избыточную точку ---------------
            if (digit == decimalSeparator) && (display.text?.rangeOfString(decimalSeparator) != nil) { return }
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit != decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            //--------------------------------------------------
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            history.text = brain.description != "?" ? brain.description : " "
        }
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            brain.executaOP(operation)
            displayResult = brain.ResultadoeErros()
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
            brain.pushOperando(value)
        }
        displayResult = brain.ResultadoeErros()
    }
    
    @IBAction func setVariavel(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        let symbol = dropFirst(sender.currentTitle!)
        if let value = displayValue {
            brain.setVariavel(symbol, value: value)
            displayResult = brain.ResultadoeErros()
            
        }
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        brain.pushOperando(sender.currentTitle!)
        displayResult = brain.ResultadoeErros()
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        brain.clearAll()
        displayResult = brain.ResultadoeErros()
    }
    
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            if count(display.text!) > 1 {
                display.text = dropLast(display.text!)
            } else {
                userIsInTheMiddleOfTypingANumber = false
                displayResult = brain.ResultadoeErros()
            }
        } else {
            brain.popPilha()
            displayResult = brain.ResultadoeErros()
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text!.rangeOfString("-") != nil) {
                display.text = dropFirst(display.text!)
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        var destination = segue.destinationViewController as? UIViewController
        if let nc = destination as? UINavigationController {
            destination = nc.visibleViewController
        }
        if let gvc = destination as? GraphicControl {
            if let identifier = segue.identifier {
                switch identifier {
                case "Show Graph":
                    gvc.program = brain.program
                default:
                    break
                }
            }
        }
    }
    
}
