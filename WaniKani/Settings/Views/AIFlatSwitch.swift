//
//  AIFlatSwitch.swift
//  AIFlatSwitch
//
//  Created by cocoatoucher on 11/02/15.
//  Copyright (c) 2015 cocoatoucher. All rights reserved.
//

import UIKit

@IBDesignable open class AIFlatSwitch: UIControl {

  let finalStrokeEndForCheckmark: CGFloat = 0.85
  let finalStrokeStartForCheckmark: CGFloat = 0.3
  let checkmarkBounceAmount: CGFloat = 0.1
  let animationDuration: CFTimeInterval = 0.3

  @IBInspectable open var lineWidth: CGFloat = 2.0 {
    didSet {
      self.circle.lineWidth = lineWidth
      self.checkmark.lineWidth = lineWidth
      self.trailCircle.lineWidth = lineWidth
    }
  }

  @IBInspectable open var strokeColor: UIColor = UIColor.black {
    didSet {
      self.circle.strokeColor = strokeColor.cgColor
      self.checkmark.strokeColor = strokeColor.cgColor
    }
  }

  @IBInspectable open var trailStrokeColor: UIColor = UIColor.gray {
    didSet {
      self.trailCircle.strokeColor = trailStrokeColor.cgColor
    }
  }

  @IBInspectable open override var isSelected: Bool {
    get {
      return selectedInternal
    }
    set {
      super.isSelected = newValue
      self.setSelected(newValue, animated: false)
    }
  }

  fileprivate var trailCircle: CAShapeLayer = CAShapeLayer()
  fileprivate var circle: CAShapeLayer = CAShapeLayer()
  fileprivate var checkmark: CAShapeLayer = CAShapeLayer()
  fileprivate var checkmarkMidPoint: CGPoint = CGPoint.zero
  fileprivate var selectedInternal: Bool = false

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.configure()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.configure()
  }

  open override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)

    if layer == self.layer {

      var offset: CGPoint = CGPoint.zero
      let radius = fmin(self.bounds.width, self.bounds.height) / 2 - 1
      offset.x = (self.bounds.width - radius * 2) / 2.0
      offset.y = (self.bounds.height - radius * 2) / 2.0

      CATransaction.begin()
      CATransaction.setDisableActions(true)

      let ovalRect = CGRect(x: offset.x, y: offset.y, width: radius * 2, height: radius * 2)

      let circlePath = UIBezierPath(ovalIn: ovalRect)
      trailCircle.path = circlePath.cgPath

      circle.transform = CATransform3DIdentity
      circle.frame = self.bounds
      circle.path = UIBezierPath(ovalIn: ovalRect).cgPath
      circle.transform = CATransform3DMakeRotation(CGFloat.pi * 212 / 180, 0, 0, 1)

      let origin = CGPoint(x: offset.x + radius, y: offset.y + radius)
      var checkStartPoint = CGPoint.zero
      checkStartPoint.x = origin.x + radius * cos(212 * CGFloat.pi / 180)
      checkStartPoint.y = origin.y + radius * sin(212 * CGFloat.pi / 180)

      let checkmarkPath = UIBezierPath()
      checkmarkPath.move(to: checkStartPoint)

      self.checkmarkMidPoint = CGPoint(x: offset.x + radius * 0.9, y: offset.y + radius * 1.4)
      checkmarkPath.addLine(to: self.checkmarkMidPoint)

      var checkEndPoint = CGPoint.zero
      checkEndPoint.x = origin.x + radius * cos(320 * CGFloat.pi / 180)
      checkEndPoint.y = origin.y + radius * sin(320 * CGFloat.pi / 180)

      checkmarkPath.addLine(to: checkEndPoint)

      checkmark.frame = self.bounds
      checkmark.path = checkmarkPath.cgPath

      CATransaction.commit()
    }
  }

  fileprivate func configure() {

    self.backgroundColor = UIColor.clear
    configureShapeLayer(trailCircle)
    trailCircle.strokeColor = trailStrokeColor.cgColor
    configureShapeLayer(circle)
    circle.strokeColor = strokeColor.cgColor
    configureShapeLayer(checkmark)
    checkmark.strokeColor = strokeColor.cgColor
    self.setSelected(false, animated: false)
    self.addTarget(self, action: #selector(AIFlatSwitch.onTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
  }

  internal func onTouchUpInside(_ sender: AnyObject) {
    self.setSelected(!self.isSelected, animated: true)
    self.sendActions(for: UIControlEvents.valueChanged)
  }

  fileprivate func configureShapeLayer(_ shapeLayer: CAShapeLayer) {
    shapeLayer.lineJoin = kCALineJoinRound
    shapeLayer.lineCap = kCALineCapRound
    shapeLayer.lineWidth = self.lineWidth
    shapeLayer.fillColor = UIColor.clear.cgColor
    self.layer.addSublayer(shapeLayer)
  }

  open func setSelected(_ isSelected: Bool, animated: Bool) {
    self.selectedInternal = isSelected

    checkmark.removeAllAnimations()
    circle.removeAllAnimations()
    trailCircle.removeAllAnimations()

    self.resetValues(animated)

    if animated {
      self.addAnimationsForSelected(selectedInternal)
    }
  }

  fileprivate func resetValues(_ animated: Bool) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    if (selectedInternal && animated) || (selectedInternal == false) && (animated == false) {
      checkmark.strokeEnd = 0.0
      checkmark.strokeStart = 0.0
      trailCircle.opacity = 0.0
      circle.strokeStart = 0.0
      circle.strokeEnd = 1.0
    } else {
      checkmark.strokeEnd = finalStrokeEndForCheckmark
      checkmark.strokeStart = finalStrokeStartForCheckmark
      trailCircle.opacity = 1.0
      circle.strokeStart = 0.0
      circle.strokeEnd = 0.0
    }
    CATransaction.commit()
  }
  // swiftlint:disable:next function_body_length
  fileprivate func addAnimationsForSelected(_ selected: Bool) {
    let circleAnimationDuration = animationDuration * 0.5

    let checkmarkEndDuration = animationDuration * 0.8
    let checkmarkStartDuration = checkmarkEndDuration - circleAnimationDuration
    let checkmarkBounceDuration = animationDuration - checkmarkEndDuration

    let checkmarkAnimationGroup = CAAnimationGroup()
    checkmarkAnimationGroup.isRemovedOnCompletion = false
    checkmarkAnimationGroup.fillMode = kCAFillModeForwards
    checkmarkAnimationGroup.duration = animationDuration
    checkmarkAnimationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

    let checkmarkStrokeEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
    checkmarkStrokeEnd.duration = checkmarkEndDuration + checkmarkBounceDuration
    checkmarkStrokeEnd.isRemovedOnCompletion = false
    checkmarkStrokeEnd.fillMode = kCAFillModeForwards
    checkmarkStrokeEnd.calculationMode = kCAAnimationPaced

    if selected {
      checkmarkStrokeEnd.values = NSArray(objects: NSNumber(value: 0.0), NSNumber(value: Float(finalStrokeEndForCheckmark + checkmarkBounceAmount)), NSNumber(value: Float(finalStrokeEndForCheckmark))) as [AnyObject]
      checkmarkStrokeEnd.keyTimes = [NSNumber(value: 0.0), NSNumber(value: checkmarkEndDuration), NSNumber(value: checkmarkEndDuration + checkmarkBounceDuration)]
    } else {
      checkmarkStrokeEnd.values = NSArray(objects: NSNumber(value: Float(finalStrokeEndForCheckmark)), NSNumber(value: Float(finalStrokeEndForCheckmark + checkmarkBounceAmount)), NSNumber(value: -0.1)) as [AnyObject]
      checkmarkStrokeEnd.keyTimes = [NSNumber(value: 0.0), NSNumber(value: checkmarkBounceDuration), NSNumber(value: checkmarkEndDuration + checkmarkBounceDuration)]
    }

    let checkmarkStrokeStart = CAKeyframeAnimation(keyPath: "strokeStart")
    checkmarkStrokeStart.duration = checkmarkStartDuration + checkmarkBounceDuration
    checkmarkStrokeStart.isRemovedOnCompletion = false
    checkmarkStrokeStart.fillMode = kCAFillModeForwards
    checkmarkStrokeStart.calculationMode = kCAAnimationPaced

    if selected {
      checkmarkStrokeStart.values = NSArray(objects: NSNumber(value: 0.0), NSNumber(value: Float(finalStrokeStartForCheckmark + checkmarkBounceAmount)), NSNumber(value: Float(finalStrokeStartForCheckmark))) as [AnyObject]
      checkmarkStrokeStart.keyTimes = [NSNumber(value: 0.0), NSNumber(value: checkmarkStartDuration), NSNumber(value: checkmarkStartDuration + checkmarkBounceDuration)]
    } else {
      checkmarkStrokeStart.values = NSArray(objects: NSNumber(value: Float(finalStrokeStartForCheckmark)), NSNumber(value: Float(finalStrokeStartForCheckmark + checkmarkBounceAmount)), NSNumber(value: 0.0)) as [AnyObject]
      checkmarkStrokeStart.keyTimes = [NSNumber(value: 0.0), NSNumber(value: checkmarkBounceDuration), NSNumber(value: checkmarkStartDuration + checkmarkBounceDuration)]
    }

    if selected {
      checkmarkStrokeStart.beginTime = circleAnimationDuration
    }

    checkmarkAnimationGroup.animations = [checkmarkStrokeEnd, checkmarkStrokeStart]
    checkmark.add(checkmarkAnimationGroup, forKey: "checkmarkAnimation")

    let circleAnimationGroup = CAAnimationGroup()
    circleAnimationGroup.duration = animationDuration
    circleAnimationGroup.isRemovedOnCompletion = false
    circleAnimationGroup.fillMode = kCAFillModeForwards
    circleAnimationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

    let circleStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
    circleStrokeEnd.duration = circleAnimationDuration
    if selected {
      circleStrokeEnd.beginTime = 0.0

      circleStrokeEnd.fromValue = NSNumber(value: 1.0)
      circleStrokeEnd.toValue = NSNumber(value: -0.1)
    } else {
      circleStrokeEnd.beginTime = animationDuration - circleAnimationDuration

      circleStrokeEnd.fromValue = NSNumber(value: 0.0)
      circleStrokeEnd.toValue = NSNumber(value: 1.0)
    }
    circleStrokeEnd.isRemovedOnCompletion = false
    circleStrokeEnd.fillMode = kCAFillModeForwards

    circleAnimationGroup.animations = [circleStrokeEnd]
    circle.add(circleAnimationGroup, forKey: "circleStrokeEnd")

    let trailCircleColor = CABasicAnimation(keyPath: "opacity")
    trailCircleColor.duration = animationDuration
    if selected {
      trailCircleColor.fromValue = NSNumber(value: 0.0)
      trailCircleColor.toValue = NSNumber(value: 1.0)
    } else {
      trailCircleColor.fromValue = NSNumber(value: 1.0)
      trailCircleColor.toValue = NSNumber(value: 0.0)
    }
    trailCircleColor.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

    trailCircleColor.fillMode = kCAFillModeForwards
    trailCircleColor.isRemovedOnCompletion = false
    trailCircle.add(trailCircleColor, forKey: "trailCircleColor")
  }

}
