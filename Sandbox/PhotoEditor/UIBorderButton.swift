//
//  UIBorderButton.swift
//  SwiftLearning
//
//  Created by Maxim Gushlenko on 17/05/2018.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

enum BorderButtonStyle {
    case circle
    case square
}

enum BorderButtonPosition {
    case topLeft
    case topCenter
    case topRight
    case centerLeft
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    case undefined
}

enum BorderButtonState {
    case normal
    case selected
    case minimized
}

protocol UIBorderButtonDelegate {
    func didTouched(_ button: UIBorderButton)
    func didUntouched(_ button: UIBorderButton)
}

class UIBorderButton: UIView {
    
    var delegate: UIBorderButtonDelegate?
    var touched: Bool = false
    var position: BorderButtonPosition = .undefined
    var style: BorderButtonStyle = .circle {
        willSet {
            self.style = newValue
            refreshStyle()
        }
    }
    
    private var shapeLayer = CALayer()
    
    private var normalSize: [BorderButtonStyle : CGSize] = [.circle : CGSize(width: 18, height: 18),
                                                            .square : CGSize(width: 13, height: 13)]
    
    private var selectedSizes: [BorderButtonStyle : CGSize] = [.circle : CGSize(width: 25, height: 25),
                                                               .square : CGSize(width: 20, height: 20)]
    
    private var minimizedSizes: [BorderButtonStyle : CGSize] = [.circle : CGSize(width: 5, height: 5),
                                                            .square : CGSize(width: 4, height: 4)]
    
    // MARK: - Public method's
    class func create(position: BorderButtonPosition, style: BorderButtonStyle) -> UIBorderButton {
        let button = UIBorderButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.position = position
        button.style = style
        
        return button
    }
    
    func setPosition(_ x: CGFloat, _ y: CGFloat) {
        frame = CGRect(x: x, y: y, width: frame.size.width, height: frame.size.height)
    }
    
    // MARK: - Private method's
    private func refreshStyle () {
        shapeLayer.removeFromSuperlayer()
        shapeLayer = CALayer()
        shapeLayer.frame = CGRect(x: 0 , y: 0, width: self.normalSize[self.style]!.width, height: self.normalSize[self.style]!.height)
        shapeLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        switch style {
        case .circle:
            shapeLayer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            shapeLayer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            shapeLayer.cornerRadius = shapeLayer.frame.size.height / 2
            break
            
        case .square:
            shapeLayer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            shapeLayer.borderWidth = 1.0
            shapeLayer.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            break
        }
        
        layer.addSublayer(shapeLayer)
    }
    
    func setState (_ state: BorderButtonState) {
        switch state {
        case .normal:
            shapeLayerCenteredResizeToSize(normalSize[style]!)
            break
            
        case .selected:
            shapeLayerCenteredResizeToSize(selectedSizes[style]!)
            break
            
        case .minimized:
            shapeLayerCenteredResizeToSize(minimizedSizes[style]!)
            break
        }
    }
    
    private func shapeLayerCenteredResizeToSize (_ size: CGSize) {
        UIView.animate(withDuration: 0.1) {
            let currentPoint = self.shapeLayer.frame.origin
            self.shapeLayer.frame = CGRect(origin: currentPoint, size: size)
            self.shapeLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            
            if self.style == .circle {
                self.shapeLayer.cornerRadius = self.shapeLayer.frame.size.height / 2
            } else {
                self.shapeLayer.cornerRadius = 0
            }
        }
    }
    
    // MARK: -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let button = touch.view as! UIBorderButton
        button.touched = true
        delegate?.didTouched(button)
        
        setState(.selected)
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        setState(.normal)
        
        let touch: UITouch = touches.first!
        let button = touch.view as! UIBorderButton
        button.touched = false
        delegate?.didUntouched(button)
        
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        setState(.normal)
        
        let touch: UITouch = touches.first!
        let button = touch.view as! UIBorderButton
        button.touched = false
        delegate?.didUntouched(button)
        
        super.touchesEnded(touches, with: event)
    }
}
