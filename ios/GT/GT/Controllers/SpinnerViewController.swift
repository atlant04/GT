//
//  SpinnerViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 28.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
import UIKit


class SpinnerViewController: UIViewController {
//    let spinner = UIActivityIndicatorView(style: .large)
//    
//    override func loadView() {
//        view = UIView()
//        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
//        view.backgroundColor = .systemRed
//        
//        spinner.startAnimating()
//        spinner.translatesAutoresizingMaskIntoConstraints = false
//        spinner.color = .systemBackground
//        view.addSubview(spinner)
//                
//        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//    }
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please stand still...\nCourses are loading. It will only happen once"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(spinner)
        view.addSubview(label)
        
        
        let size = label.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        label.bottomAnchor.constraint(equalTo: spinner.topAnchor, constant: -24).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    func start() {
        guard let scene = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate), let window = scene.window else { return }
        view.frame = window.frame
        window.addSubview(view)
    }
    
    func stop() {
        view.removeFromSuperview()
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        self.addChild(child)
        child.view.frame = UIScreen.main.bounds
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
