//: Playground - noun: a place where people can play

import UIKit

class Calculatorpadrao: NSNumberpadrao {
    
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
    static let sharedInstance = Calculatorpadrao()

}

println(Calculatorpadrao.sharedInstance)

println(Calculatorpadrao.sharedInstance)

println(Calculatorpadrao.sharedInstance.stringFromNumber(20.00) ?? "")
println(Calculatorpadrao.sharedInstance.stringFromNumber(55550) ?? "")

class Calculatrix
{
    
    enum Result: Printable {
        case Value(Double)
        case Erro(String)
        
        var description: String {
            switch self {
            case .Value(let value):
                return  Calculatorpadrao.sharedInstance.stringFromNumber(value) ?? ""
            case .Erro(let errorMessage):
                return errorMessage
            }
        }
    }
}


let padrao = Calculatorpadrao()
println(padrao)
println(padrao)
println(padrao.stringFromNumber(20.00) ?? "")
println(padrao.stringFromNumber(55550) ?? "")
