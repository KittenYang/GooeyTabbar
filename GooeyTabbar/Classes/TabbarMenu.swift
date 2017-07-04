//
//  TabbarMenu.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

enum MenuTextureType {
    case withColor(color: UIColor)
    case withBlur(blurStyle: UIBlurEffectStyle)
}

class TabbarMenu: UIView {
    
    /// 是否打开
    var opened : Bool = false
    
    fileprivate var normalRect : UIView!
    fileprivate var springRect : UIView!
    fileprivate var keyWindow  : UIWindow!
    fileprivate weak var backDimmingView: UIVisualEffectView!
    fileprivate var displayLink : CADisplayLink!
    fileprivate var animationCount : Int = 0
    fileprivate var diff : CGFloat = 0
    fileprivate var terminalFrame : CGRect?
    fileprivate var initialFrame : CGRect?
    fileprivate var animateButton : AnimatedButton?
    fileprivate var bouncyMask: CAShapeLayer?
    fileprivate var textureType: MenuTextureType = .withColor(color: UIColor(colorLiteralRed: 50/255.0, green: 58/255.0, blue: 68/255.0, alpha: 1.0))
    
    var topSpace : CGFloat = 64.0 //留白
    fileprivate var tabbarheight : CGFloat = 0.0 //tabbar高度
    
    init(texture: MenuTextureType, tabbarHeight : CGFloat, toTop: CGFloat)
    {
        textureType = texture
        topSpace = toTop
        tabbarheight = tabbarHeight
        terminalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        initialFrame = CGRect(x: 0, y: UIScreen.main.bounds.height - tabbarHeight - topSpace, width: terminalFrame!.width, height: terminalFrame!.height)
        super.init(frame: initialFrame!)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateMask() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width, y: topSpace))
        path.addQuadCurve(to: CGPoint(x: 0, y: topSpace), controlPoint: CGPoint(x: self.frame.width/2, y: topSpace-diff))
        path.close()
        
        bouncyMask?.path = path.cgPath
    }
    
    fileprivate func setUpViews()
    {
        keyWindow = UIApplication.shared.keyWindow
        
        let dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        dimmingView.frame = self.bounds
        dimmingView.alpha = 0.0
        keyWindow.addSubview(dimmingView)
        backDimmingView = dimmingView
        
        switch textureType {
        case .withBlur(let blurStyle):
            self.backgroundColor = UIColor.clear
            let backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            backgroundBlurView.frame = self.bounds
            addSubview(backgroundBlurView)
            var dimmingStyle: UIBlurEffectStyle
            switch blurStyle {
            case .dark:
                dimmingStyle = .light
            default:
                dimmingStyle = .dark
            }
            backDimmingView.effect = UIBlurEffect(style: dimmingStyle)
        case .withColor(let color):
            self.backgroundColor = color
        }
        
        bouncyMask = CAShapeLayer()
        bouncyMask?.frame = bounds
        layer.mask = bouncyMask
        updateMask()
        keyWindow.addSubview(self)
        
        normalRect = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 30 - 50, width: 30, height: 30))
        normalRect.backgroundColor = UIColor.blue
        normalRect.isHidden = true
        keyWindow.addSubview(normalRect)
        
        springRect = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 30/2, y: normalRect.frame.origin.y, width: 30, height: 30))
        springRect.backgroundColor = UIColor.yellow
        springRect.isHidden = true
        keyWindow.addSubview(springRect)
        
        animateButton = AnimatedButton(frame: CGRect(x: 0, y: topSpace + max(5, (tabbarheight - 30)/2), width: 50, height: 30))
        self.addSubview(animateButton!)
        animateButton!.didTapped = { [weak self] (button) -> () in
            if let strongSelf = self {
                strongSelf.triggerAction()
            }
        }
        
    }
    
    func triggerAction()
    {        
        /**
         *  展开
         */
        if !opened {
            animateButton!.switchToOpenMode()
            opened = true
            animationWillBegin()
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: self.springRect.center.y - 40)
            }) { (finish) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: 100)
                    self.backDimmingView.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.springRect.center = CGPoint(x: self.springRect.center.x, y: 100)
                }, completion: { (finish) -> Void in
                    self.animationDidDone()
                })
            }
            UIView.animate(withDuration: 0.3, delay: 0.14, options: .curveEaseOut, animations: { () -> Void in
                self.frame = self.terminalFrame!
            }, completion: nil)
            
        }else{
            /**
             *  收缩
             */
            animateButton!.switchToCloseMode()
            opened = false
            animationWillBegin()
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.frame = self.initialFrame!
                }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50)
                self.backDimmingView.alpha = 0.0
            }, completion: { (finished) in
                self.backDimmingView.removeFromSuperview()
            })
            
            UIView.animate(withDuration: 0.25, delay:0.0, options: .curveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50 + 10)
                }, completion: { (finish) -> Void in
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                        self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50 - 40)
                        }, completion: { (finish) -> Void in
                            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                                self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50)
                                }, completion: { (finish) -> Void in
                                    self.animationDidDone()
//                                    self.removeFromSuperview()
                            })
                    })
            })
        }
    }
    
    
    @objc fileprivate func update(_ displayLink: CADisplayLink)
    {
        let normalRectLayer = normalRect.layer.presentation()
        let springRectLayer = springRect.layer.presentation()
        
        let normalRectFrame = (normalRectLayer!.value(forKey: "frame")! as AnyObject).cgRectValue
        let springRectFrame = (springRectLayer!.value(forKey: "frame")! as AnyObject).cgRectValue
        
        diff = (normalRectFrame?.origin.y)! - (springRectFrame?.origin.y)!
        print("=====\(diff)")
        
        updateMask()
    }
    
    fileprivate func animationWillBegin()
    {
        if displayLink == nil
        {
            self.displayLink = CADisplayLink(target: self, selector: #selector(TabbarMenu.update(_:)))
            self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        animationCount += 1
    }
    
    fileprivate func animationDidDone()
    {
        animationCount -= 1
        if animationCount == 0
        {
            displayLink.invalidate()
            displayLink = nil
        }
    }
    
    
}
