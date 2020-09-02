//
//  Separator.swift
//  GT
//
//  Created by Maksim Tochilkin on 30.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

class SeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 8, y: bounds.midY))
        line.addLine(to: CGPoint(x: bounds.width - 8, y: bounds.midY ))
        UIColor.gray.setStroke()
        line.stroke()
        
        let handleSize = CGSize(width: bounds.width / 5, height: bounds.height / 2)
        let handleOrigin = CGPoint(x: bounds.midX - handleSize.width / 2, y: bounds.midY - handleSize.height / 2)
        let handle = UIBezierPath(roundedRect: CGRect(origin: handleOrigin, size: handleSize), cornerRadius: handleSize.height / 2)
        UIColor.gray.setFill()
        handle.fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var longPress: UILongPressGestureRecognizer!
    
    func commonInit() {
        longPress = UILongPressGestureRecognizer()
        addGestureRecognizer(longPress)
        backgroundColor = .clear
    }
}
