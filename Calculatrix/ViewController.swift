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
    @IBOutlet weak var displayhistorico: UILabel!

    
    let limitee: Int = 38
    var userIsInTheMiddleOfTypingANumber = false
    var calculadora = Calculatrix()
    
    
    var displayresultado: Calculatrix.Resposta = .Value(0.0) {
        didSet {
            display.text = displayresultado.description
            userIsInTheMiddleOfTypingANumber = false
            displayhistorico.text = calculadora.printa + "="
        }
    }
    
    var Mostra: Double? {
        get {
            if let displayText = display.text {
                return padrao.numberFromString(displayText)?.doubleValue
            }
            return nil
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            
            if (digit == ".") && (display.text?.rangeOfString(".") != nil) { return }
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit != ".") && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            displayhistorico.text = calculadora.description != "?" ? calculadora.description : " "
        }
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operacao = sender.currentTitle {
            calculadora.executaOP(operacao)
            displayresultado = calculadora.Resultados()
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let value = Mostra {
            calculadora.pushOperando(value)
        }
        displayresultado = calculadora.Resultados()
    }
    
    @IBAction func setVariavel(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        let qual = dropFirst(sender.currentTitle!)
        if let value = Mostra {
            calculadora.setVariavel(qual, value: value)
            displayresultado = calculadora.Resultados()
            
        }
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        calculadora.pushOperando(sender.currentTitle!)
        displayresultado = calculadora.Resultados()
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        calculadora.clearAll()
        displayresultado = calculadora.Resultados()
    }
    
    @IBAction func ClearPilha(sender: AnyObject) {
        calculadora.ZeraPilha()
        displayresultado = calculadora.Resultados()
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
                    gvc.program = calculadora.program
                default:
                    break
                }
            }
        }
    }
    
}
