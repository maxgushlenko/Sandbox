//
//  UILayerObject.swift
//  SwiftLearning
//
//  Created by Maxim Gushlenko on 17/05/2018.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

enum LayerObjectState {
    case active
    case inactive
    case installed
}

class UILayerObject: UIView, UIBorderButtonDelegate {

    var borderButtons = NSMutableArray()
    var borderView: UIView!
    var imageView: UIImageView!
    var selectedBorderButton: UIBorderButton?
    var state: LayerObjectState = .active
    var blockRotationAndResizing = false
    var isInstalled = false
    
    var firstLocation: CGPoint = CGPoint.zero
    var firstAngle: CGFloat = 0.0
    var firstTransform: CGAffineTransform = CGAffineTransform.identity
    var firstVector: CGPoint = CGPoint.zero
    
    // MARK: - Public method's
    func prepare() {
        createBorder()
        setupImageView()
        recalculateBorderPosition()
    }
    
    private func setupImageView () {
        imageView = UIImageView(frame: borderView.bounds)
        borderView.addSubview(imageView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(changePositionGesture))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(panGesture)
        imageView.contentMode = .scaleToFill
    }
    
    // MARK: -
    @objc private func changePositionGesture (_ sender: UIPanGestureRecognizer) {
        if state == .active && (sender.state == .began || sender.state == .changed) {
            let translation = sender.translation(in: self.superview)
            let changeX = self.center.x + translation.x
            let changeY = self.center.y + translation.y
            self.center = CGPoint(x: changeX, y: changeY)
            sender.setTranslation(CGPoint.zero, in: self.superview)
        }
    }
    
    func changeState(_ newState: LayerObjectState) {
        state = newState
        
        switch newState {
        case .active:
            if !isInstalled {
                minimizeBorderButtons(false)
                hideBorder(false)
                blockRotationAndResizing = false
            }
            break
            
        case .inactive:
            if !isInstalled {
                minimizeBorderButtons(true)
                hideBorder(true)
                blockRotationAndResizing = true
            }
            break
            
        case .installed:
            minimizeBorderButtons(true)
            hideBorder(true)
            blockRotationAndResizing = true
            isInstalled = true
            isUserInteractionEnabled = false
            
            break
        }
    }
    
    /*
     При нажатии/отпуск на одну из Border buttons нужно уменьшить/нормализовать в размере остальные кнопки.
     */
    func minimizeBorderButtons(_ minimize: Bool) {
        for button in borderButtons {
            let borderButton = button as! UIBorderButton
            if !borderButton.touched {
                if minimize {
                    borderButton.setState(.minimized)
                } else {
                    borderButton.setState(.normal)
                }
            }
        }
    }
    
    
    // MARK: - Private method's
    private func hideBorder (_ hide: Bool) {
        
        UIView.animate(withDuration: 0.1) {
            
            self.borderView.layer.borderColor = hide ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0).cgColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            
            for button in self.borderButtons {
                let borderButton = button as! UIBorderButton
                borderButton.alpha = hide ? 0.0 : 1.0
            }
        }
    }
    
    private func createBorder () {
        borderButtons.removeAllObjects()
//        self.backgroundColor = UIColor.orange
        /*
         Верхние кнопки
         */
        let topLeft = UIBorderButton.create(position: .topLeft, style: .circle)
        borderButtons.add(topLeft)
        
        let topCenter = UIBorderButton.create(position: .topCenter, style: .square)
        borderButtons.add(topCenter)
        
        let topRight = UIBorderButton.create(position: .topRight, style: .circle)
        borderButtons.add(topRight)
        
        /*
         Средние кнопки
         */
        let centerLeft = UIBorderButton.create(position: .centerLeft, style: .square)
        borderButtons.add(centerLeft)
        
        let centerRight = UIBorderButton.create(position: .centerRight, style: .square)
        borderButtons.add(centerRight)
        
        /*
         Нижние кнопки
         */
        let bottomLeft = UIBorderButton.create(position: .bottomLeft, style: .circle)
        borderButtons.add(bottomLeft)
        
        let bottomCenter = UIBorderButton.create(position: .bottomCenter, style: .square)
        borderButtons.add(bottomCenter)
        
        let bottomRight = UIBorderButton.create(position: .bottomRight, style: .circle)
        borderButtons.add(bottomRight)
        
        /*
         Вью для отображения рамки и картинки.
         */
        let borderWidth: CGFloat = 1.4
        let borderPosition = topLeft.frame.size.height / 2 - borderWidth / 2
        let borderSize = CGSize(width: frame.size.width - borderPosition * 2, height: frame.size.height - borderPosition * 2)
        borderView = UIView(frame: CGRect(x: borderPosition, y: borderPosition, width: borderSize.width, height: borderSize.height));
        borderView.layer.borderWidth = borderWidth
        borderView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(borderView)
        
        /*
         Задаем всем кнопкам делегат, позицию и добавляем на вью.
         */
        for button in borderButtons {
            let borderButton = button as! UIBorderButton
            borderButton.delegate = self
            addSubview(borderButton)
        }
        
        hideBorder(false)
    }
    
    private func calculatePositionForBorderButton (_ button: UIBorderButton) {
        /*
         Для читабельности кода и облегчения расчётов, заранее разделил всё необходимое на два.
         */
        let superviewSize = frame.size
        let preparedButtonSize = CGSize(width: button.frame.size.width / 2, height: button.frame.size.height / 2)
        let preparedSuperviewSize = CGSize(width: superviewSize.width / 2, height: superviewSize.height / 2)
        /*
         */
        
        switch button.position {
        case .topLeft:
            button.setPosition(0, 0)
            break
            
        case .topCenter:
            button.setPosition(preparedSuperviewSize.width - preparedButtonSize.width, 0)
            break
            
        case .topRight:
            button.setPosition(superviewSize.width - button.frame.width, 0)
            break
            
        case .centerLeft:
            button.setPosition(0, preparedSuperviewSize.height - preparedButtonSize.height)
            break
            
        case .centerRight:
            button.setPosition(superviewSize.width - button.frame.width, preparedSuperviewSize.height - preparedButtonSize.height)
            break
            
        case .bottomLeft:
            button.setPosition(0, superviewSize.height - button.frame.width)
            break
            
        case .bottomCenter:
            button.setPosition(preparedSuperviewSize.width - preparedButtonSize.width, superviewSize.height - button.frame.width)
            break
            
        case .bottomRight:
            button.setPosition(superviewSize.width - button.frame.width, superviewSize.height - button.frame.height)
            break
            
        default:
            button.setPosition(self.center.x, self.center.y)
            break
        }
    }
    
    private func recalculateBorderPosition () {
        for button in borderButtons {
            calculatePositionForBorderButton(button as! UIBorderButton)
            imageView.frame = borderView.bounds
        }
    }
    
    // MARK: - UIBorderButtonDelegate
    func didTouched(_ button: UIBorderButton) {
        minimizeBorderButtons(true)
        selectedBorderButton = button
    }
    
    func didUntouched(_ button: UIBorderButton) {
        minimizeBorderButtons(false)
        selectedBorderButton = nil
    }
    
    // MARK: - Touch responder part
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*
         При первом касании к картинке если рамка не активная - делаем её активной.
         */
        if state == .inactive {
            changeState(.active)
        }
        
        let touch: UITouch = touches.first!
        
        /*
         Данные, которые нобходимо запомнить при первом касании к картинке. Они понадобятся для расчётов далее, когда начнём двыгать палец.
         */
        
        firstLocation = touch.location(in: self.superview)
        firstAngle = angleForVectorFromCenterTo(firstLocation)
        firstTransform = self.transform
        firstVector = CGPoint(x: firstLocation.x - self.center.x, y: firstLocation.y - self.center.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*
         Обработка для круглых кнопок (scale, rotate).
         */
        if selectedBorderButton != nil && selectedBorderButton?.style == .circle && isInstalled == false && state == .active {
            
            let touch: UITouch = touches.first!
            let currentLocation = touch.location(in: self.superview)
            
            /*
             Считаем разницу в длинне между первым и вторым вектором. Так мы узнаем на сколько нужно cкейлить картинку.
             */
            let secondVector = CGPoint(x: currentLocation.x - self.center.x, y: currentLocation.y - self.center.y)
            let secondVectorLenght = sqrt(secondVector.x * secondVector.x + secondVector.y * secondVector.y)
            
            let firstVectorLenght = sqrt(firstVector.x * firstVector.x + firstVector.y * firstVector.y)
            
            let delta = secondVectorLenght / firstVectorLenght
            
            /*
             Считаем угл между первым и вторым вектором. Так мы узнаем на сколько нужно повернуть картинку.
             */
            
            let secondAngle = angleForVectorFromCenterTo(currentLocation)
            let delta2 = secondAngle - firstAngle
            
            /*
             Теперь полученные переменные задаем в CGAffineTransform.
             */
            let transform = firstTransform.rotated(by: delta2)
            let transformScaled = transform.scaledBy(x: delta, y: delta)
            self.transform = transformScaled
        }
    }
    
    /*
     Начальная точка вектора для scale и rotate начинается с центра картинки.
     */
    private func angleForVectorFromCenterTo(_ point: CGPoint) -> CGFloat{
        
        let x: CGFloat = self.center.x - point.x
        let y: CGFloat = self.center.y - point.y

        let angle: CGFloat = atan2(y, x)
        
        return angle
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
}
