//
//  ConfigView.swift
//  GT
//
//  Created by Maksim Tochilkin on 30.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


class ConfigView: UIView {
    weak var searchVC: SearchViewController?
    let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 4
        slider.value = 2
        slider.addTarget(self, action: #selector(handleColumnChange), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    var oldValue: Int = 0
    @objc
    func handleColumnChange() {
        let newValue = Int(slider.value)
        if newValue != oldValue {
            searchVC?.columnNumber = newValue
            oldValue = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        oldValue = Int(slider.value)
        backgroundColor = .clear
        let style: UIBlurEffect.Style = traitCollection.userInterfaceStyle == .light ? .light : .dark
        let blur = UIBlurEffect(style: style)
        let effect = UIVisualEffectView(effect: blur)
        addSubview(effect)
        effect.translatesAutoresizingMaskIntoConstraints = false
        fill(with: effect)
        
        addSubview(slider)
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: centerYAnchor),
            slider.centerXAnchor.constraint(equalTo: centerXAnchor),
            slider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            slider.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
