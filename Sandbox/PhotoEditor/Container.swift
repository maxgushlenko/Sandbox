//
//  Container.swift
//  SwiftLearning
//
//  Created by Maxim Gushlenko on 17/05/2018.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

private let borderWidth: CGFloat = 1.4

enum LayerObjectState {
    case active
    case inactive
    case installed
}

class Container: UIView, BorderButtonDelegate {

    var borderButtons = NSMutableArray()
    var borderView: UIView!
    var imageView: UIImageView!
    var selectedBorderButton: BorderButton?
    var state: LayerObjectState = .active
    var blockRotationAndResizing = false
    var isInstalled = false
    
    var firstLocation: CGPoint = CGPoint.zero
    var firstAngle: CGFloat = 0.0
    var firstTransform: CGAffineTransform = CGAffineTransform.identity
    var firstButtonTransform: CGAffineTransform = CGAffineTransform.identity
    var firstVector: CGPoint = CGPoint.zero
    var firstFrame: CGRect!
    
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
        
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }

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
            let borderButton = button as! BorderButton
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
                let borderButton = button as! BorderButton
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
        let topLeft = BorderButton.create(position: .topLeft, style: .circle)
        borderButtons.add(topLeft)
        
        let topCenter = BorderButton.create(position: .topCenter, style: .square)
        borderButtons.add(topCenter)
        
        let topRight = BorderButton.create(position: .topRight, style: .circle)
        borderButtons.add(topRight)
        
        /*
         Средние кнопки
         */
        let centerLeft = BorderButton.create(position: .centerLeft, style: .square)
        borderButtons.add(centerLeft)
        
        let centerRight = BorderButton.create(position: .centerRight, style: .square)
        borderButtons.add(centerRight)
        
        /*
         Нижние кнопки
         */
        let bottomLeft = BorderButton.create(position: .bottomLeft, style: .circle)
        borderButtons.add(bottomLeft)
        
        let bottomCenter = BorderButton.create(position: .bottomCenter, style: .square)
        borderButtons.add(bottomCenter)
        
        let bottomRight = BorderButton.create(position: .bottomRight, style: .circle)
        borderButtons.add(bottomRight)
        
        /*
         Вью для отображения рамки и картинки.
         */
        
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
            let borderButton = button as! BorderButton
            borderButton.delegate = self
            addSubview(borderButton)
        }
        
        hideBorder(false)
    }
    
    private func calculatePositionForBorderButton (_ button: BorderButton) {
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
            calculatePositionForBorderButton(button as! BorderButton)
            imageView.frame = borderView.bounds
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
    
    @objc func pinch(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            
            switch gesture.state {
            case .changed:
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: gesture.scale, y: gesture.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                self.transform = firstTransform
                
                gesture.scale = 1
                
            default:
                return
            }
        }
    }
    
    // MARK: - BorderButtonDelegate
    func didTouched(_ button: BorderButton) {
        minimizeBorderButtons(true)
        selectedBorderButton = button
    }
    
    func didUntouched(_ button: BorderButton) {
        minimizeBorderButtons(false)
        selectedBorderButton = nil
    }
    
    // MARK: - Touch responder part
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
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
        firstTransform = self.superview!.transform
        print("msg___ tap 1: \(firstButtonTransform)")
        firstButtonTransform = (borderButtons.firstObject as! BorderButton).transform
        print("msg___ tap 2: \(firstButtonTransform)")
        firstVector = CGPoint(x: firstLocation.x - self.center.x, y: firstLocation.y - self.center.y)
        firstFrame = self.frame
//        self.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
//        self.frame = CGRect(x: self.frame.origin.x - self.frame.width / 2, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let currentLocation = touch.location(in: self.superview)
        
        /*
         Обработка для круглых кнопок (scale, rotate).
         */
        if selectedBorderButton != nil && selectedBorderButton?.style == .circle && isInstalled == false && state == .active {
            
            /*
             Считаем разницу в длинне между первым и вторым вектором. Так мы узнаем на сколько нужно cкейлить картинку.
             */
            let secondVector = CGPoint(x: currentLocation.x - self.center.x, y: currentLocation.y - self.center.y)
            let secondVectorLenght = sqrt(secondVector.x * secondVector.x + secondVector.y * secondVector.y)
            
            let firstVectorLenght = sqrt(firstVector.x * firstVector.x + firstVector.y * firstVector.y)
            
            let delta = secondVectorLenght / firstVectorLenght
            let deltaInverted = firstVectorLenght / secondVectorLenght
            /*
             Считаем угл между первым и вторым вектором. Так мы узнаем на сколько нужно повернуть картинку.
             */
            
            let secondAngle = angleForVectorFromCenterTo(currentLocation)
            let delta2 = secondAngle - firstAngle
            
            /*
             Теперь полученные переменные задаем в CGAffineTransform.
             */
            let transformRotate = firstTransform.rotated(by: delta2)
            let transformScaled = transformRotate.scaledBy(x: delta, y: delta)
            
            
            self.superview?.transform = transformScaled
            
            /*
             Отменяем скейл и поворот для кнопок рамки.
             */
            for button in borderButtons {
                let buttonObject = button as! BorderButton
                
//                let transformScaledInvert = self.transform.inverted()
//                let rotateTransform = transformScaledInvert.rotated(by: delta2)
//
                
                buttonObject.transform = firstButtonTransform.scaledBy(x: deltaInverted, y: deltaInverted)
                
                
            }
            
//            let xScale = sqrt(self.transform.a * self.transform.a + self.transform.c * self.transform.c)
//            let yScale = sqrt(self.transform.b * self.transform.b + self.transform.d * self.transform.d)
//
//            let previousBorderWidth = borderView.layer.borderWidth
//            let percentage = borderWidth/self.frame.size.width * 100
//            let newBorderWidth = delta > 1 ? borderWidth/delta : borderWidth + 1 * delta
//            let calculatedBorderWidth = newBorderWidth > borderWidth ? borderWidth : newBorderWidth
            
//             borderView.layer.borderWidth = calculatedBorderWidth
            
//            print("msg___ delta     : \(delta)")
//            print("msg___ percentage: \(percentage)")
//            print("msg___ xScale: \(xScale) yScale: \(yScale) delta: \(delta)")
            
        } else if selectedBorderButton != nil && selectedBorderButton?.style == .square && isInstalled == false && state == .active {
            /*
             Обработка для квадратных кнопок (height, width).
             */
            
            /*
             Считаем разницу в длинне между первым и вторым вектором. Так мы узнаем на сколько нужно cкейлить картинку.
             */
            let secondVector = CGPoint(x: currentLocation.x - self.center.x, y: currentLocation.y - self.center.y)
            let secondVectorLenght = sqrt(secondVector.x * secondVector.x + secondVector.y * secondVector.y)
            
            let firstVectorLenght = sqrt(firstVector.x * firstVector.x + firstVector.y * firstVector.y)
            
            let deltaDistance = secondVectorLenght - firstVectorLenght
            
            recalculateBorderPosition()
            
            self.frame = CGRect(x: firstFrame.origin.x, y: firstFrame.origin.y, width: firstFrame.width + deltaDistance, height: firstFrame.height)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    // MARK: -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
}
