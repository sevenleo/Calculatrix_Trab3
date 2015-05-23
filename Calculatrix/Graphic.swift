//
//  Graphic.swift
//  Calculatrix
//
//  Created by Leo Neves on 5/19/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//
import UIKit

protocol GraphViewDataSource: class {
    func y(x: CGFloat) -> CGFloat?
}

@IBDesignable
class Graphic: UIView {
    let plano = Cartesiano(color: UIColor.blackColor())
    
    private var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable
    var escala: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    var origem00: CGPoint? { didSet { setNeedsDisplay() }}
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    
    override func drawRect(rect: CGRect) {
        origem00 =  origem00 ?? graphCenter
        plano.contentScaleFactor = contentScaleFactor
        plano.drawAxesInRect(bounds, origem00: origem00!, pontos: escala)
        drawCurveInRect(bounds, origem00: origem00!, pontos: escala)
    }
    
    func drawCurveInRect(bounds: CGRect, origem00: CGPoint, pontos: CGFloat){
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var ponto = CGPoint()
        
        var valorinicial = true
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            ponto.x = CGFloat(i) / contentScaleFactor
            if let y = dataSource?.y((ponto.x - origem00.x) / escala) {
                if !y.isNormal && !y.isZero {
                    valorinicial = true
                    continue
                }
                ponto.y = origem00.y - y * escala
                if valorinicial {
                    path.moveToPoint(ponto)
                    valorinicial = false
                } else {
                    path.addLineToPoint(ponto)
                }
            } else {
                valorinicial = true
            }
        }
        path.stroke()
    }
    
    func escala(gesto: UIPinchGestureRecognizer) {
        if gesto.state == .Changed {
            escala *= gesto.scale
            gesto.scale = 1.0
        }
    }
    
    func origem00Move(gesto: UIPanGestureRecognizer) {
        switch gesto.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesto.translationInView(self)
            if translation != CGPointZero {
                origem00?.x += translation.x
                origem00?.y += translation.y
                gesto.setTranslation(CGPointZero, inView: self)
            }
        default: break
        }
    }
    
    func origem00(gesto: UITapGestureRecognizer) {
        if gesto.state == .Ended {
            origem00 = gesto.locationInView(self)
        }
    }
    
}
