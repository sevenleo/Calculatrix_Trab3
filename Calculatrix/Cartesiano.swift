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

