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
            action: "scale:"))
        graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView,
            action: "originMove:"))
        let tap = UITapGestureRecognizer(target: graphView, action: "origin:")
        tap.numberOfTapsRequired = 2
        graphView.addGestureRecognizer(tap)
        updateUI()
        }
    }
    
    
    private var brain = Calculatrix()
    
    typealias PropertyList = AnyObject
    var program: PropertyList? { didSet {
        brain.setVariavel("M", value: 0)
        brain.program = program!
        updateUI()
        }
    }
    
    func updateUI() {
        graphView?.setNeedsDisplay()
        title = brain.description != "?" ? brain.description : "График"
    }
    
    func y(x: CGFloat) -> CGFloat? {
        brain.setVariavel("M", value: Double (x))
        if let y = brain.calcular() {
            return CGFloat(y)
        }
        return nil
        
    }

}

