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
        case Erro(String)
        
        var description: String {
            switch self {
            case .Value(let value):
                return  formatter.stringFromNumber(value) ?? ""
            case .Erro(let errorMessage):
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
    private var variaveis = [String: Double]()
    
    
    func getVariavel(symbol: String) -> Double? {
        return variaveis[symbol]
    }
    
    func setVariavel(symbol: String, value: Double) {
        variaveis[symbol] = value
    }
    
    func clearVariavel() {
        variaveis.removeAll()
    }
    
    func ZeraPilha() {
        opStack.removeAll()
    }
    
    func clearAll() {
        clearVariavel()
        ZeraPilha()
    }
    
    init() {
        func adc (op: Op) {
            operacoes[op.description] = op
        }
        adc(Op.operacao2("×", 2, true, *, nil ))
        adc(Op.operacao2("÷", 2, false, { $1 / $0 },
            { divisor, _ in return divisor == 0.0 ? "Divisao por zero" : nil }))
        adc(Op.operacao2("+", 1, true, +, nil))
        adc(Op.operacao2("−", 1, false, { $1 - $0}, nil))
        
        adc(Op.operacao1("√", sqrt,
            { $0 < 0 ? "√ Raiz negativa" : nil }))
        adc(Op.operacao1("sin", sin, nil))
        adc(Op.operacao1("cos", cos, nil))
        adc(Op.operacao1("±", { -$0 }, nil))
        
        adc(Op.operacao0("π", { M_PI }))
    }
    
    
    typealias PropertyList = AnyObject
    
    var program:PropertyList {
        get {
            return opStack.map{$0.description}
        }
        set{
            if let opSnomes = newValue as? Array<String> {
                
                var AddPilha = [Op]()
                for opSymbol in opSnomes {
                    if let op = operacoes[opSymbol]{
                        AddPilha.append(op)
                    } else if let operand = formatter.numberFromString(opSymbol)?.doubleValue {
                        AddPilha.append(.Operando(operand))
                    } else {
                        AddPilha.append(.Variavel(opSymbol))
                    }
                }
                opStack = AddPilha
            }
        }
    }
    
    var printa: String {
        get {
            let (result, remainder) = printaB(opStack)
            return result ?? ""
        }
    }
    
    private func printaB(ops: [Op]) -> (result: String, nextOperacao : [Op]) {
        let (result, reminder, _) = description(ops)
        if !reminder.isEmpty {
            let (current, reminderCurrent) = printaB(reminder)
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
    
    private func description(ops: [Op]) -> (result: String, nextOperacao : [Op], prioridade: Int) {
        if !ops.isEmpty {
            var nextOperacao  = ops
            let op = nextOperacao .removeLast()
            switch op {
                
            case .Operando(let operand):
                return (formatter.stringFromNumber(operand) ?? "", nextOperacao , op.prioridade)
                
            case .operacao0(let symbol, _):
                return (symbol, nextOperacao , op.prioridade)
                
            case .operacao1(let symbol, _, _):
                let  (operand, nextOperacao , precedenceOperand) = description(nextOperacao )
                return ("\(symbol)(\(operand))", nextOperacao , op.prioridade)
                
            case .operacao2(let symbol, _, _, _, _):
                var (operand1, nextOperacao , precedenceOperand1) = description(nextOperacao )
                if op.prioridade > precedenceOperand1
                    || (op.prioridade == precedenceOperand1 && !op.troca )
                {
                    operand1 = "(\(operand1))"
                }
                var (operand2, remainingOpsOperand2, precedenceOperand2) = description(nextOperacao )
                if op.prioridade > precedenceOperand2
                {
                    operand2 = "(\(operand2))"
                }
                return ("\(operand2) \(symbol) \(operand1)", remainingOpsOperand2, op.prioridade)
                
            case .Variavel(let symbol):
                return (symbol, nextOperacao , op.prioridade)
            }
        }
        return ("?", ops, Int.max)
    }
    
    private func calcular(ops: [Op]) -> (result: Double?, nextOperacao : [Op]) {
        if !ops.isEmpty {
            var nextOperacao  = ops
            let op = nextOperacao .removeLast()
            switch op {
            case .Operando(let operand):
                return (operand, nextOperacao )
                
            case .operacao0(_, let operation):
                return (operation(), nextOperacao )
                
            case .operacao1(_, let operation, let errorTest):
                let operandEvaluation = calcular(nextOperacao )
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.nextOperacao )
                }
            case .operacao2(_, _, _, let operation, let errorTest):
                let op1faz = calcular(nextOperacao )
                if let operand1 = op1faz.result {
                    let op2faz = calcular(op1faz.nextOperacao )
                    if let operand2 = op2faz.result {
                        return (operation(operand1, operand2), op2faz.nextOperacao )
                    }
                }
            case .Variavel(let symbol):
                return (variaveis[symbol], nextOperacao )
            }
        }
        return (nil, ops)
    }
    
       private func resultado(ops: [Op]) -> (result: Result, nextOperacao : [Op]) {
        
        if !ops.isEmpty {
            var nextOperacao  = ops
            let op = nextOperacao .removeLast()
            switch op {
            case .Operando(let operand):
                return (.Value(operand), nextOperacao )
                
            case .Variavel(let variavel):
                if let varValue = variaveis[variavel] {
                    return (.Value(varValue), nextOperacao )
                }
                return (.Erro("\(variavel) не установлена"), nextOperacao )
                
            case .operacao0(_, let operation):
                return (Result.Value(operation()), nextOperacao )
                
            case .operacao1(_, let operation, let errorTest):
                let operandEvaluation = resultado(nextOperacao )
                switch operandEvaluation.result {
                case .Value(let operand):
                    if let errMessage = errorTest?(operand) {
                        return (.Erro(errMessage), nextOperacao )
                    }
                    return (.Value(operation(operand)),
                        operandEvaluation.nextOperacao )
                case .Erro(let errMessage):
                    return (.Erro(errMessage), nextOperacao )
                }
            case .operacao2(_, _, _, let operation, let errorTest):
                let op1faz = resultado(nextOperacao )
                switch op1faz.result {
                case .Value(let operand1):
                    let op2faz = resultado(op1faz.nextOperacao )
                    switch op2faz.result {
                    case .Value(let operand2):
                        if let errMessage = errorTest?(operand1, operand2) {
                            return (.Erro(errMessage), op1faz.nextOperacao )
                        }
                        return (.Value(operation(operand1, operand2)),
                            op2faz.nextOperacao )
                    case .Erro(let errMessage):
                        return (.Erro(errMessage), op1faz.nextOperacao )
                    }
                case .Erro(let errMessage):
                    return (.Erro(errMessage), nextOperacao )
                }
            }
        }
        return (.Erro("Мало операндов"), ops)
    }
    
    func calcular() -> Double? {
        let (result, remainder) = calcular(opStack)
     
        return result
    }
    
    
     func ResultadoeErros() -> Result {
        if !opStack.isEmpty {
            return resultado(opStack).result
        }
        return .Value(0)
    }
    
    func pushOperando(operand: Double) -> Double? {
        opStack.append(Op.Operando(operand))
        return calcular()
    }
    
    func pushOperando(symbol: String) -> Double? {
        opStack.append(Op.Variavel(symbol))
        return calcular()
    }
    
    func executaOP(symbol: String) -> Double? {
        if let operation = operacoes[symbol] {
            opStack.append(operation)
        }
        return calcular()
    }
    
    func popPilha() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return calcular()
    }
    
    
    func PilhaToString() -> String {
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
        self.notANumberSymbol = "Erro"
        self.groupingSeparator = " "
        
    }
    

    static let sharedInstance = CalculatorFormatter()
    

    
}

let formatter = CalculatorFormatter()
