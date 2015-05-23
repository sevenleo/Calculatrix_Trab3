//
//  GraphicControl.swift
//  Calculatrix
//
//  Created by Leo Neves on 5/19/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//
import UIKit

class GraphicControl: UIViewController, GraphViewDataSource {
    
    @IBOutlet weak var graphView: Graphic! { didSet {
        
        graphView.dataSource = self
        
        graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView,
            action: "escala:"))
        graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView,
            action: "origem00Move:"))
        let gesto = UITapGestureRecognizer(target: graphView, action: "origem00:")
        gesto.numberOfTapsRequired = 2
        graphView.addGestureRecognizer(gesto)
        atualizaGUI()
        }
    }
    
    
    private var calculadora = Calculatrix()
    
    typealias PropertyList = AnyObject
    var program: PropertyList? { didSet {
        calculadora.setVariavel("M", value: 0)
        calculadora.program = program!
        atualizaGUI()
        }
    }
    
    func atualizaGUI() {
        graphView?.setNeedsDisplay()
        title = calculadora.description != "?" ? calculadora.description : "Plano cartesiano"
    }
    
    func y(x: CGFloat) -> CGFloat? {
        calculadora.setVariavel("M", value: Double (x))
        if let y = calculadora.calcular() {
            return CGFloat(y)
        }
        return nil
        
    }

}

