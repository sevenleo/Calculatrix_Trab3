//
//  Calculatrix.swift
//  Calculatrix
//
//  Created by Computação Gráfica 2 on 08/05/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//
import Foundation

class Calculatrix
{
   
    enum Result: Printable {
        case Value(Double)
        case Error(String)
        
        var description: String {
            switch self {
            case .Value(let value):
                return  formatter.stringFromNumber(value) ?? ""
            case .Error(let errorMessage):
                return errorMessage
            }
        }
    }
    private enum Op: Printable
    {
        case Operando(Double)
        case operacao0(String, () -> Double)
        case operacao1(String, Double -> Double, (Double -> String?)?)
        case operacao2(String,  Int, Bool, (Double, Double) -> Double, ((Double, Double) -> String?)?)
        case Variavel(String)
        
        var description: String {
            get {
                switch self {
                case .Operando(let operand):
                    return "\(operand)"
                case .operacao1(let symbol, _, _):
                    return symbol
                case .operacao2(let symbol, _, _, _, _):
                    return symbol
                case .operacao0(let symbol, _):
                    return symbol
                case .Variavel(let symbol):
                    return symbol
                    
                }
            }
        }
        var prioridade: Int {
            get {
                switch self {
                case .operacao2(_, let prioridade, _, _, _):
                    return prioridade
                default:
                    return  Int.max
                }
            }
        }
        var troca: Bool {
            get {
                switch self {
                case .operacao2(_, _ , let troca, _, _):
                    return troca
                default:
                    return  true
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var operacoes = [String:Op]()
    private var variableValues = [String: Double]()
    
    
    func getVariable(symbol: String) -> Double? {
        return variableValues[symbol]
    }
    
    func setVariable(symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    func clearStack() {
        opStack.removeAll()
    }
    
    func clearAll() {
        clearVariables()
        clearStack()
    }
    
    init() {
        func learnOp (op: Op) {
            operacoes[op.description] = op
        }
        learnOp(Op.operacao2("×", 2, true, *, nil ))
        learnOp(Op.operacao2("÷", 2, false, { $1 / $0 },
            { divisor, _ in return divisor == 0.0 ? "Деление на ноль" : nil }))
        learnOp(Op.operacao2("+", 1, true, +, nil))
        learnOp(Op.operacao2("−", 1, false, { $1 - $0}, nil))
        
        learnOp(Op.operacao1("√", sqrt,
            { $0 < 0 ? "√ отриц. числа" : nil }))
        learnOp(Op.operacao1("sin", sin, nil))
        learnOp(Op.operacao1("cos", cos, nil))
        learnOp(Op.operacao1("±", { -$0 }, nil))
        
        learnOp(Op.operacao0("π", { M_PI }))
    }
    
    
    typealias PropertyList = AnyObject
    
    var program:PropertyList {
        get {
            return opStack.map{$0.description}
        }
        set{
            if let opSymbols = newValue as? Array<String> {
                
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = operacoes[opSymbol]{
                        newOpStack.append(op)
                    } else if let operand = formatter.numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operando(operand))
                    } else {
                        newOpStack.append(.Variavel(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description1: String {
        get {
            let (result, remainder) = descParts(opStack)
            return result ?? ""
        }
    }
    
    private func descParts(ops: [Op]) -> (result: String, remainingOps: [Op]) {
        let (result, reminder, _) = description(ops)
        if !reminder.isEmpty {
            let (current, reminderCurrent) = descParts(reminder)
            return ("\(current), \(result)",reminderCurrent)
        }
        return (result,reminder)
    }
    
    var description: String {
        get {
            var (result, remainder) = ("", opStack)
            var current: String
            do {
                (current, remainder, _) = description(remainder)
                result = result == "" ? current : "\(current), \(result)"
            } while remainder.count > 0
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String, remainingOps: [Op], prioridade: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
                
            case .Operando(let operand):
                return (formatter.stringFromNumber(operand) ?? "", remainingOps, op.prioridade)
                
            case .operacao0(let symbol, _):
                return (symbol, remainingOps, op.prioridade)
                
            case .operacao1(let symbol, _, _):
                let  (operand, remainingOps, precedenceOperand) = description(remainingOps)
                return ("\(symbol)(\(operand))", remainingOps, op.prioridade)
                
            case .operacao2(let symbol, _, _, _, _):
                var (operand1, remainingOps, precedenceOperand1) = description(remainingOps)
                if op.prioridade > precedenceOperand1
                    || (op.prioridade == precedenceOperand1 && !op.troca )
                {
                    operand1 = "(\(operand1))"
                }
                var (operand2, remainingOpsOperand2, precedenceOperand2) = description(remainingOps)
                if op.prioridade > precedenceOperand2
                {
                    operand2 = "(\(operand2))"
                }
                return ("\(operand2) \(symbol) \(operand1)", remainingOpsOperand2, op.prioridade)
                
            case .Variavel(let symbol):
                return (symbol, remainingOps, op.prioridade)
            }
        }
        return ("?", ops, Int.max)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operando(let operand):
                return (operand, remainingOps)
                
            case .operacao0(_, let operation):
                return (operation(), remainingOps)
                
            case .operacao1(_, let operation, let errorTest):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .operacao2(_, _, _, let operation, let errorTest):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variavel(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
    }
    
       private func evaluateResult(ops: [Op]) -> (result: Result, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operando(let operand):
                return (.Value(operand), remainingOps)
                
            case .Variavel(let variavel):
                if let varValue = variableValues[variavel] {
                    return (.Value(varValue), remainingOps)
                }
                return (.Error("\(variavel) не установлена"), remainingOps)
                
            case .operacao0(_, let operation):
                return (Result.Value(operation()), remainingOps)
                
            case .operacao1(_, let operation, let errorTest):
                let operandEvaluation = evaluateResult(remainingOps)
                switch operandEvaluation.result {
                case .Value(let operand):
                    if let errMessage = errorTest?(operand) {
                        return (.Error(errMessage), remainingOps)
                    }
                    return (.Value(operation(operand)),
                        operandEvaluation.remainingOps)
                case .Error(let errMessage):
                    return (.Error(errMessage), remainingOps)
                }
            case .operacao2(_, _, _, let operation, let errorTest):
                let op1Evaluation = evaluateResult(remainingOps)
                switch op1Evaluation.result {
                case .Value(let operand1):
                    let op2Evaluation = evaluateResult(op1Evaluation.remainingOps)
                    switch op2Evaluation.result {
                    case .Value(let operand2):
                        if let errMessage = errorTest?(operand1, operand2) {
                            return (.Error(errMessage), op1Evaluation.remainingOps)
                        }
                        return (.Value(operation(operand1, operand2)),
                            op2Evaluation.remainingOps)
                    case .Error(let errMessage):
                        return (.Error(errMessage), op1Evaluation.remainingOps)
                    }
                case .Error(let errMessage):
                    return (.Error(errMessage), remainingOps)
                }
            }
        }
        return (.Error("Мало операндов"), ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
     
        return result
    }
    
    
     func evaluateAndReportErrors() -> Result {
        if !opStack.isEmpty {
            return evaluateResult(opStack).result
        }
        return .Value(0)
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operando(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variavel(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = operacoes[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func popStack() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    
    func displayStack() -> String {
        return opStack.isEmpty ? "" : " ".join(opStack.map{ $0.description })
    }
}

class CalculatorFormatter: NSNumberFormatter {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        self.locale = NSLocale.currentLocale()
        self.numberStyle = .DecimalStyle
        self.maximumFractionDigits = 10
        self.notANumberSymbol = "Error"
        self.groupingSeparator = " "
        
    }
    

    static let sharedInstance = CalculatorFormatter()
    

    
}

let formatter = CalculatorFormatter()
