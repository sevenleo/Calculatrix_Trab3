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
    var contentScaleFactor: CGFloat = 1
    convenience init(color: UIColor, contentScaleFactor: CGFloat) {
        self.init()
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.contentScaleFactor = contentScaleFactor
    }

    func drawAxesInRect(bounds: CGRect, origem00: CGPoint, pontos: CGFloat)
    {
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: bounds.minX, y: align(origem00.y)))
        path.addLineToPoint(CGPoint(x: bounds.maxX, y: align(origem00.y)))
        path.moveToPoint(CGPoint(x: align(origem00.x), y: bounds.minY))
        path.addLineToPoint(CGPoint(x: align(origem00.x), y: bounds.maxY))
        path.stroke()
        drawHashmarksInRect(bounds, origem00: origem00, pontos: abs(pontos))
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    

    
    private func drawHashmarksInRect(bounds: CGRect, origem00: CGPoint, pontos: CGFloat)
    {
        if ((origem00.x >= bounds.minX) && (origem00.x <= bounds.maxX)) || ((origem00.y >= bounds.minY) && (origem00.y <= bounds.maxY))
        {

            var unitsPerHashmark = MinPontos / pontos
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            
            let pointsPerHashmark = pontos * unitsPerHashmark
            
           
            var startingHashmarkRadius: CGFloat = 1
            if !CGRectContainsPoint(bounds, origem00) {
                let leftx = max(origem00.x - bounds.maxX, 0)
                let rightx = max(bounds.minX - origem00.x, 0)
                let downy = max(origem00.y - bounds.minY, 0)
                let upy = max(bounds.maxY - origem00.y, 0)
                startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
            }
            
            
            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: origem00, size: CGSize(width: bboxSize, height: bboxSize))
            
            let padrao = NSNumberFormatter()
            padrao.maximumFractionDigits = Int(round(-log10(Double(unitsPerHashmark))))
            padrao.minimumIntegerDigits = 1
            
            while !CGRectContainsRect(bbox, bounds)
            {
                let label = padrao.stringFromNumber((origem00.x-bbox.minX)/pontos)!
                if let leftHashmarkPoint = alignedPoint(x: bbox.minX, y: origem00.y, insideBounds:bounds) {
                    drawHashmarkAtLocation(leftHashmarkPoint, .Top("-\(label)"))
                }
                if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origem00.y, insideBounds:bounds) {
                    drawHashmarkAtLocation(rightHashmarkPoint, .Top(label))
                }
                if let topHashmarkPoint = alignedPoint(x: origem00.x, y: bbox.minY, insideBounds:bounds) {
                    drawHashmarkAtLocation(topHashmarkPoint, .Left(label))
                }
                if let bottomHashmarkPoint = alignedPoint(x: origem00.x, y: bbox.maxY, insideBounds:bounds) {
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
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: location.x-dx, y: location.y-dy))
        path.addLineToPoint(CGPoint(x: location.x+dx, y: location.y+dy))
        path.stroke()
        
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
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}

