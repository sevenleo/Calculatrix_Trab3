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

    func geraGraphico(espaco: CGRect, origem00: CGPoint, pontos: CGFloat)
    {
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        let base = UIBezierPath()
        base.moveToPoint(CGPoint(x: espaco.minX, y: alinhar(origem00.y)))
        base.addLineToPoint(CGPoint(x: espaco.maxX, y: alinhar(origem00.y)))
        base.moveToPoint(CGPoint(x: alinhar(origem00.x), y: espaco.minY))
        base.addLineToPoint(CGPoint(x: alinhar(origem00.x), y: espaco.maxY))
        base.stroke()
        desenhar(espaco, origem00: origem00, pontos: abs(pontos))
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    

    
    private func desenhar(espaco: CGRect, origem00: CGPoint, pontos: CGFloat)
    {
        if ((origem00.x >= espaco.minX) && (origem00.x <= espaco.maxX)) || ((origem00.y >= espaco.minY) && (origem00.y <= espaco.maxY))
        {

            var unidades = MinPontos / pontos
            if unidades < 1 {
                unidades = pow(10, ceil(log10(unidades)))
            } else {
                unidades = floor(unidades)
            }
            
            let totalPontos = pontos * unidades
            
           
            var raioDeDesenho: CGFloat = 1
            if !CGRectContainsPoint(espaco, origem00) {
                let leftx = max(origem00.x - espaco.maxX, 0)
                let rightx = max(espaco.minX - origem00.x, 0)
                let downy = max(origem00.y - espaco.minY, 0)
                let upy = max(espaco.maxY - origem00.y, 0)
                raioDeDesenho = min(min(leftx, rightx), min(downy, upy)) / totalPontos + 1
            }
            
            
            let Tamanho = totalPontos * raioDeDesenho * 2
            var espacoInterno = CGRect(center: origem00, size: CGSize(width: Tamanho, height: Tamanho))
            
            let padrao = NSNumberFormatter()
            padrao.maximumFractionDigits = Int(round(-log10(Double(unidades))))
            padrao.minimumIntegerDigits = 1
            
            while !CGRectContainsRect(espacoInterno, espaco)
            {
                let rotulo = padrao.stringFromNumber((origem00.x-espacoInterno.minX)/pontos)!
                if let leftlimite = risca(x: espacoInterno.minX, y: origem00.y, insideBounds:espaco) {
                    Redesenhar(leftlimite, .Top("-\(rotulo)"))
                }
                if let rightlimite = risca(x: espacoInterno.maxX, y: origem00.y, insideBounds:espaco) {
                    Redesenhar(rightlimite, .Top(rotulo))
                }
                if let uplimite = risca(x: origem00.x, y: espacoInterno.minY, insideBounds:espaco) {
                    Redesenhar(uplimite, .Left(rotulo))
                }
                if let downlimite = risca(x: origem00.x, y: espacoInterno.maxY, insideBounds:espaco) {
                    Redesenhar(downlimite, .Left("-\(rotulo)"))
                }
                espacoInterno.inset(dx: -totalPontos, dy: -totalPontos)
            }
        }
    }
    
    private func Redesenhar(location: CGPoint, _ text: texto)
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
        
        text.criartexto(location, color: color)
    }
    
    private enum texto
    {
        case Left(String)
        case Right(String)
        case Top(String)
        case Bottom(String)
        
        static let limitevertical: CGFloat = 3
        static let limitehorizontal: CGFloat = 6
        
        func criartexto(location: CGPoint, color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.sizeWithAttributes(attributes))
            switch self {
            case Top: textRect.origin.y += textRect.size.height / 2 + texto.limitevertical
            case Left: textRect.origin.x += textRect.size.width / 2 + texto.limitehorizontal
            case Bottom: textRect.origin.y -= textRect.size.height / 2 + texto.limitevertical
            case Right: textRect.origin.x -= textRect.size.width / 2 + texto.limitehorizontal
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
    

    
    private func risca(#x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let ponto = CGPoint(x: alinhar(x), y: alinhar(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, ponto)) {
                return nil
            }
        }
        return ponto
    }
    
    private func alinhar(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * escalar) / escalar
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}













/* Usei este arquivo como base, adaptei e traduzi algumas variaveis


//
//  AxesDrawer.swift
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class AxesDrawer
{
private struct Constants {
static let HashmarkSize: CGFloat = 6
}

var color = UIColor.blueColor()
var minimumPointsPerHashmark: CGFloat = 40
var contentScaleFactor: CGFloat = 1 // set this from UIView's contentScaleFactor to position axes with maximum accuracy

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

// this method is the heart of the AxesDrawer
// it draws in the current graphic context's coordinate system
// therefore origin and bounds must be in the current graphics context's coordinate system
// pointsPerUnit is essentially the "scale" of the axes
// e.g. if you wanted there to be 100 points along an axis between -1 and 1,
//    you'd set pointsPerUnit to 50

func drawAxesInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
{
CGContextSaveGState(UIGraphicsGetCurrentContext())
color.set()
let path = UIBezierPath()
path.moveToPoint(CGPoint(x: bounds.minX, y: align(origin.y)))
path.addLineToPoint(CGPoint(x: bounds.maxX, y: align(origin.y)))
path.moveToPoint(CGPoint(x: align(origin.x), y: bounds.minY))
path.addLineToPoint(CGPoint(x: align(origin.x), y: bounds.maxY))
path.stroke()
drawHashmarksInRect(bounds, origin: origin, pointsPerUnit: abs(pointsPerUnit))
CGContextRestoreGState(UIGraphicsGetCurrentContext())
}

// the rest of this class is private

private func drawHashmarksInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
{
if ((origin.x >= bounds.minX) && (origin.x <= bounds.maxX)) || ((origin.y >= bounds.minY) && (origin.y <= bounds.maxY))
{
// figure out how many units each hashmark must represent
// to respect both pointsPerUnit and minimumPointsPerHashmark
var unitsPerHashmark = minimumPointsPerHashmark / pointsPerUnit
if unitsPerHashmark < 1 {
unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
} else {
unitsPerHashmark = floor(unitsPerHashmark)
}

let pointsPerHashmark = pointsPerUnit * unitsPerHashmark

// figure out which is the closest set of hashmarks (radiating out from the origin) that are in bounds
var startingHashmarkRadius: CGFloat = 1
if !CGRectContainsPoint(bounds, origin) {
let leftx = max(origin.x - bounds.maxX, 0)
let rightx = max(bounds.minX - origin.x, 0)
let downy = max(origin.y - bounds.minY, 0)
let upy = max(bounds.maxY - origin.y, 0)
startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
}

// now create a bounding box inside whose edges those four hashmarks lie
let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
var bbox = CGRect(center: origin, size: CGSize(width: bboxSize, height: bboxSize))

// formatter for the hashmark labels
let formatter = NSNumberFormatter()
formatter.maximumFractionDigits = Int(round(-log10(Double(unitsPerHashmark))))
formatter.minimumIntegerDigits = 1

// radiate the bbox out until the hashmarks are further out than the bounds
while !CGRectContainsRect(bbox, bounds)
{
let label = formatter.stringFromNumber((origin.x-bbox.minX)/pointsPerUnit)!
if let leftHashmarkPoint = alignedPoint(x: bbox.minX, y: origin.y, insideBounds:bounds) {
drawHashmarkAtLocation(leftHashmarkPoint, .Top("-\(label)"))
}
if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origin.y, insideBounds:bounds) {
drawHashmarkAtLocation(rightHashmarkPoint, .Top(label))
}
if let topHashmarkPoint = alignedPoint(x: origin.x, y: bbox.minY, insideBounds:bounds) {
drawHashmarkAtLocation(topHashmarkPoint, .Left(label))
}
if let bottomHashmarkPoint = alignedPoint(x: origin.x, y: bbox.maxY, insideBounds:bounds) {
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
case .Left: dx = Constants.HashmarkSize / 2
case .Right: dx = Constants.HashmarkSize / 2
case .Top: dy = Constants.HashmarkSize / 2
case .Bottom: dy = Constants.HashmarkSize / 2
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

// we want the axes and hashmarks to be exactly on pixel boundaries so they look sharp
// setting contentScaleFactor properly will enable us to put things on the closest pixel boundary
// if contentScaleFactor is left to its default (1), then things will be on the nearest "point" boundary instead
// the lines will still be sharp in that case, but might be a pixel (or more theoretically) off of where they should be

private func alignedPoint(#x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
{
let point = CGPoint(x: align(x), y: align(y))
if let permissibleBounds = insideBounds {
if (!CGRectContainsPoint(permissibleBounds, point)) {
return nil
}
}
return point
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






*/













