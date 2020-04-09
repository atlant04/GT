//
//  CoursePickerView.swift
//  GT
//
//  Created by Maksim Tochilkin on 28.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

protocol CoursePickerViewControllerDelegate {
    func didSelect(row: Int)
}


class CoursePickerViewController: UIViewController {
    let picker = UIPickerView()
    let pickerViewHolder = UIView()
    let doneButton = UIButton()
    var heightAnchor: NSLayoutConstraint!
    
    var delegate: CoursePickerViewControllerDelegate?
    
    
    override func loadView() {
        view = UIView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        pickerViewHolder.translatesAutoresizingMaskIntoConstraints = false
//        doneButton.translatesAutoresizingMaskIntoConstraints = false
//        doneButton.isUserInteractionEnabled = true
//        doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
//        doneButton.backgroundColor = .systemYellow
        pickerViewHolder.addSubview(picker)
//        pickerViewHolder.addSubview(doneButton)
        picker.fill(pickerViewHolder)
        view.addSubview(pickerViewHolder)
        
        pickerViewHolder.backgroundColor = .systemBackground
        pickerViewHolder.layer.cornerRadius = 40
        pickerViewHolder.layer.cornerCurve = .continuous
        pickerViewHolder.layer.masksToBounds = true
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dismissViewR(_:))))
        
        heightAnchor = pickerViewHolder.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            pickerViewHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            pickerViewHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            pickerViewHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            heightAnchor
        ])

    }
    
    var isDismissed = false
    
    @objc func dismissViewR(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: self.view)
        if velocity.y > 800 && !isDismissed {
            isDismissed = true
            self.heightAnchor.constant = 0

            let row = picker.selectedRow(inComponent: 0)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = .clear
                self.view.layoutIfNeeded()
            }) { _ in
                self.delegate?.didSelect(row: row)
                self.view.removeFromSuperview()
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present() {
        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = delegate.window  {
            view.frame = window.frame
            window.addSubview(self.view)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.heightAnchor.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.7)
            self.view.layoutIfNeeded()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
