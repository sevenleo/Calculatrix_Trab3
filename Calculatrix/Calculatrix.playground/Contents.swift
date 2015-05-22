//: Playground - noun: a place where people can play

import UIKit

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

println(CalculatorFormatter.sharedInstance)

println(CalculatorFormatter.sharedInstance)

println(CalculatorFormatter.sharedInstance.stringFromNumber(20.00) ?? "")
println(CalculatorFormatter.sharedInstance.stringFromNumber(55550) ?? "")

class Calculatrix
{
    
    enum Result: Printable {
        case Value(Double)
        case Erro(String)
        
        var description: String {
            switch self {
            case .Value(let value):
                return  CalculatorFormatter.sharedInstance.stringFromNumber(value) ?? ""
            case .Erro(let errorMessage):
                return errorMessage
            }
        }
    }
}


let formatter = CalculatorFormatter()
println(formatter)
println(formatter)
println(formatter.stringFromNumber(20.00) ?? "")
println(formatter.stringFromNumber(55550) ?? "")
