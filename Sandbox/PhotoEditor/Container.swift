//
//  Container.swift
//  SwiftLearning
//
//  Created by Maxim Gushlenko on 17/05/2018.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

private let borderWidth: CGFloat = 1.4

enum  LayerContainerState {
    case active
    case inactive
    case installed
}

class Container: UIView, BorderButtonDelegate {
    
    var imageView: UIImageView!
    
    var borderView: UIView!
    var borderButtons = NSMutableArray()
    var selectedBorderButton: BorderButton?
    
    var state: LayerContainerState = .active
    var blockRotationAndResizing = false        // ??
    var isInstalled = false
    
    /*
     Переменные для расчётов.
     */
    var firstTouchLocation: CGPoint!
    var firstFrame: CGRect!
    
    var firstVector: CGPoint!
    var firstVectorAngle: CGFloat!
    
    var mainTransform: CGAffineTransform = CGAffineTransform.identity
    var selfTransform: CGAffineTransform = CGAffineTransform.identity
    var borderButtonTransform: CGAffineTransform = CGAffineTransform.identity
    
    
    var bezierPaths: NSMutableArray = NSMutableArray()
    
    
    
    // MARK: - Public method's
    func prepare() {
        createBorder()
        setupImageView()
        recalculateBorderPosition()
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    private func setupImageView () {
        imageView = UIImageView(frame: borderView.bounds)
        borderView.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleToFill
        
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    func changeState(_ newState: LayerContainerState) {
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
        
        let x: CGFloat = self.superview!.center.x - point.x
        let y: CGFloat = self.superview!.center.y - point.y
        
        let angle: CGFloat = atan2(y, x)
        
        return angle
    }
    
    // MARK: - BorderButtonDelegate
    func didTouched(_ button: BorderButton) {
        selectedBorderButton = button
        minimizeBorderButtons(true)
    }
    
    func didUntouched(_ button: BorderButton) {
        selectedBorderButton = nil
        minimizeBorderButtons(false)
    }
    
    // MARK: - UIResponder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch: UITouch = touches.first!
        
        /*
         При первом касании к картинке если рамка не активная - делаем её активной.
         */
        if state == .inactive {
            changeState(.active)
        }
        
        /*
         Данные, которые нобходимо запомнить при первом касании к кнопке. Они понадобятся для расчётов далее, когда начнём двыгать палец.
         */
        
        firstFrame = self.frame
        
        firstTouchLocation = touch.location(in: self.superview!.superview)
        firstVectorAngle = angleForVectorFromCenterTo(firstTouchLocation)
        mainTransform = self.superview!.transform
        selfTransform = self.transform
        borderButtonTransform = (borderButtons.firstObject as! BorderButton).transform
        firstVector = calculateVectorWith(firstTouchLocation)
    }
    
    private func calculateVectorWith(_ endPoint: CGPoint) -> CGPoint {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        guard let button = selectedBorderButton else {
            return CGPoint(x: x, y: y)
        }
        
        switch button.position {
            
        /*
         Круглые кнопки (rotate, scale).
         */
        case .topLeft, .topRight, .bottomLeft, .bottomRight:
            x = endPoint.x - self.superview!.center.x
            y = endPoint.y - self.superview!.center.y
            break
            
        /*
         Квадратные кнопки (width, height).
         */
        case .centerRight:
            x = endPoint.x - self.superview!.frame.origin.x
            y = endPoint.y - self.superview!.frame.origin.y
            break
            
        default:
            break
        }
        
        return CGPoint(x: x, y: y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch = touches.first!
        let currentLocation = touch.location(in: self.superview!.superview)
        
        /*
         Обработка для круглых кнопок (scale, rotate).
         */
        if selectedBorderButton != nil && selectedBorderButton?.style == .circle && isInstalled == false && state == .active {
            
            /*
             Считаем векторы.
             */
            let firstVectorLenght = sqrt(firstVector.x * firstVector.x + firstVector.y * firstVector.y)
            
            let secondVector = calculateVectorWith(currentLocation)
            let secondVectorLenght = sqrt(secondVector.x * secondVector.x + secondVector.y * secondVector.y)
            
            /*
             Считаем угл между первым и вторым вектором. Так мы узнаем на сколько нужно повернуть картинку.
             */
            let deltaScale = secondVectorLenght / firstVectorLenght
            
            /*
             Считаем разницу в длинне между первым и вторым вектором. Так мы узнаем на сколько нужно cкейлить картинку.
             */
            let secondVectorAngle = angleForVectorFromCenterTo(currentLocation)
            let deltaRotate = secondVectorAngle - firstVectorAngle
            
            /*
             Теперь полученные переменные задаем в CGAffineTransform.
             */
            let transformRotate = mainTransform.rotated(by: deltaRotate)
            let transformScale = transformRotate.scaledBy(x: deltaScale, y: deltaScale)
            
            self.superview!.transform = transformScale
            
            /*
             Отменяем скейл для кнопок потому, что они не должны увеличиватся вместе с картинкой. По сути - просто инвертируем скейла delta.
             */
            let deltaScaleInverted = firstVectorLenght / secondVectorLenght
            
            for button in borderButtons {
                (button as! BorderButton).transform = borderButtonTransform.scaledBy(x: deltaScaleInverted, y: deltaScaleInverted)
            }
            
            drawLineFromPoint(start: firstVector, toPoint: secondVector, ofColor: UIColor.yellow, inView: self)
            
            return
        }
        
        /*
         Обработка для квадратных кнопок (height, width).
         */
        if selectedBorderButton != nil && selectedBorderButton?.style == .square && isInstalled == false && state == .active {
            
            /*
             Считаем векторы.
             */
            let firstVectorLenght = sqrt(firstVector.x * firstVector.x + firstVector.y * firstVector.y)

            let secondVector = calculateVectorWith(currentLocation)
            let secondVectorLenght = sqrt(secondVector.x * secondVector.x + secondVector.y * secondVector.y)
            
            let deltaDistance = secondVectorLenght - firstVectorLenght
            
//            self.frame = CGRect(x: firstFrame.origin.x, y: firstFrame.origin.y, width: firstFrame.width + deltaDistance, height: firstFrame.height)
//
//            recalculateBorderPosition()
            
            //
            
            let deltaScale = secondVectorLenght / firstVectorLenght
            
            let transformTranslation = selfTransform.translatedBy(x: -deltaScale, y: 0)
            let transformScale = transformTranslation.scaledBy(x: deltaScale, y: 1)
            
            self.transform = transformScale
            
            /*
             Отменяем скейл для кнопок потому, что они не должны увеличиватся вместе с картинкой. По сути - просто инвертируем скейла delta.
             */
            let deltaScaleInverted = firstVectorLenght / secondVectorLenght
            
            for button in borderButtons {
                (button as! BorderButton).transform = borderButtonTransform.scaledBy(x: deltaScaleInverted, y: deltaScaleInverted)
            }
            
            drawLineFromPoint(start: firstVector, toPoint: secondVector, ofColor: UIColor.yellow, inView: self)
            
            return
        }
    }
    
    // MARK: - UIGestureRecognizer
    @objc func pinch(_ gesture: UIPinchGestureRecognizer) {
        
        /*
         Пока отключил. Проблема в том, что тут нужно реализовать прямо пропорциональный скейл BorderButton's, чтобы они всегда были одного размера. Это уже реализовано, но не тут.
         */
        
        //        if let view = gesture.view {
        //
        //            switch gesture.state {
        //            case .changed:
        //                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
        //                                          y: gesture.location(in: view).y - view.bounds.midY)
        //
        //                let translate = mainTransform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
        //                let scale = translate.scaledBy(x: gesture.scale, y: gesture.scale)
        //                let compensationTranslate = scale.translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
        //                mainTransform = compensationTranslate
        //                self.superview!.transform = mainTransform
        //
        //                for button in borderButtons {
        //                    (button as! BorderButton).transform = borderButtonTransform.scaledBy(x: -gesture.scale, y: -gesture.scale)
        //                }
        //
        //                gesture.scale = 1
        //                print("msg___ scale: \(gesture.scale) ")
        //            default:
        //                return
        //            }
        //        }
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        
        if bezierPaths.count > 10 {
            let object: CAShapeLayer = bezierPaths.object(at: 0) as! CAShapeLayer
            object.removeFromSuperlayer()
            bezierPaths.removeObject(at: 0)
        }
        
        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
        bezierPaths.add(shapeLayer)
    }
    /*
     Код, который может пригодится при расчётах в ширине обода рамки.
      */
//            let xScale = sqrt(self.transform.a * self.transform.a + self.transform.c * self.transform.c)
//            let yScale = sqrt(self.transform.b * self.transform.b + self.transform.d * self.transform.d)
//
//            let previousBorderWidth = borderView.layer.borderWidth
//            let percentage = borderWidth/self.frame.size.width * 100
//            let newBorderWidth = delta > 1 ? borderWidth/delta : borderWidth + 1 * delta
//            let calculatedBorderWidth = newBorderWidth > borderWidth ? borderWidth : newBorderWidth

//            borderView.layer.borderWidth = calculatedBorderWidth
}
