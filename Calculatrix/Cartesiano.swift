//
//  Cartesiano.swift
//  Calculatrix
//
//  Created by Leo Neves on 5/19/15.
//  Copyright (c) 2015 Leo Neves. All rights reserved.
//
import UIKit

class Cartesiano
{
    private struct Constants {
        static let Pontos: CGFloat = 10 //seriam os pontos vistos
    }
    
    var color = UIColor.blackColor()
    var MinPontos: CGFloat = 30
    var escalar: CGFloat = 1
    convenience init(color: UIColor, escalar: CGFloat) {
        self.init()
        self.color = color
        self.escalar = escalar
    }
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    convenience init(escalar: CGFloat) {
        self.init()
        self.escalar = escalar
    }

    func drawAxesInRect(espaco: CGRect, origem00: CGPoint, pontos: CGFloat)
    {
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        let base = UIBezierPath()
        base.moveToPoint(CGPoint(x: espaco.minX, y: align(origem00.y)))
        base.addLineToPoint(CGPoint(x: espaco.maxX, y: align(origem00.y)))
        base.moveToPoint(CGPoint(x: align(origem00.x), y: espaco.minY))
        base.addLineToPoint(CGPoint(x: align(origem00.x), y: espaco.maxY))
        base.stroke()
        drawHashmarksInRect(espaco, origem00: origem00, pontos: abs(pontos))
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    

    
    private func drawHashmarksInRect(espaco: CGRect, origem00: CGPoint, pontos: CGFloat)
    {
        if ((origem00.x >= espaco.minX) && (origem00.x <= espaco.maxX)) || ((origem00.y >= espaco.minY) && (origem00.y <= espaco.maxY))
        {

            var unitsPerHashmark = MinPontos / pontos
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            
            let pointsPerHashmark = pontos * unitsPerHashmark
            
           
            var startingHashmarkRadius: CGFloat = 1
            if !CGRectContainsPoint(espaco, origem00) {
                let leftx = max(origem00.x - espaco.maxX, 0)
                let rightx = max(espaco.minX - origem00.x, 0)
                let downy = max(origem00.y - espaco.minY, 0)
                let upy = max(espaco.maxY - origem00.y, 0)
                startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
            }
            
            
            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: origem00, size: CGSize(width: bboxSize, height: bboxSize))
            
            let padrao = NSNumberFormatter()
            padrao.maximumFractionDigits = Int(round(-log10(Double(unitsPerHashmark))))
            padrao.minimumIntegerDigits = 1
            
            while !CGRectContainsRect(bbox, espaco)
            {
                let label = padrao.stringFromNumber((origem00.x-bbox.minX)/pontos)!
                if let leftHashmarkPoint = alignedPoint(x: bbox.minX, y: origem00.y, insideBounds:espaco) {
                    drawHashmarkAtLocation(leftHashmarkPoint, .Top("-\(label)"))
                }
                if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origem00.y, insideBounds:espaco) {
                    drawHashmarkAtLocation(rightHashmarkPoint, .Top(label))
                }
                if let topHashmarkPoint = alignedPoint(x: origem00.x, y: bbox.minY, insideBounds:espaco) {
                    drawHashmarkAtLocation(topHashmarkPoint, .Left(label))
                }
                if let bottomHashmarkPoint = alignedPoint(x: origem00.x, y: bbox.maxY, insideBounds:espaco) {
                    drawHashmarkAtLocation(bottomHashmarkPoint, .Left("-\(label)"))
                }
                bbox.inset(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            }
        }
    }
    
    private func drawHashmarkAtLocation(location: CGPoint, _ text: AnchoredText)
    {
        var dx: CGFloat = 0, dy: CGFloat = 0
        switch text {
        case .Left: dx = Constants.Pontos / 2
        case .Right: dx = Constants.Pontos / 2
        case .Top: dy = Constants.Pontos / 2
        case .Bottom: dy = Constants.Pontos / 2
        }
        
        let base = UIBezierPath()
        base.moveToPoint(CGPoint(x: location.x-dx, y: location.y-dy))
        base.addLineToPoint(CGPoint(x: location.x+dx, y: location.y+dy))
        base.stroke()
        
        text.drawAnchoredToPoint(location, color: color)
    }
    
    private enum AnchoredText
    {
        case Left(String)
        case Right(String)
        case Top(String)
        case Bottom(String)
        
        static let VerticalOffset: CGFloat = 3
        static let HorizontalOffset: CGFloat = 6
        
        func drawAnchoredToPoint(location: CGPoint, color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.sizeWithAttributes(attributes))
            switch self {
            case Top: textRect.origin.y += textRect.size.height / 2 + AnchoredText.VerticalOffset
            case Left: textRect.origin.x += textRect.size.width / 2 + AnchoredText.HorizontalOffset
            case Bottom: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.VerticalOffset
            case Right: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.HorizontalOffset
            }
            text.drawInRect(textRect, withAttributes: attributes)
        }
        
        var text: String {
            switch self {
            case Left(let text): return text
            case Right(let text): return text
            case Top(let text): return text
            case Bottom(let text): return text
            }
        }
    }
    

    
    private func alignedPoint(#x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let ponto = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, ponto)) {
                return nil
            }
        }
        return ponto
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * escalar) / escalar
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}

