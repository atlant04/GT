//
//  SectionCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 04.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

//class SectionCell: UICollectionViewCell, ConfiguringCell {
//    typealias Content = Section
//    static var reuseIdentifier: String = "section_cell"
//
//    @IBOutlet weak var name: UILabel!
//    @IBOutlet weak var crn: UILabel!
//    @IBOutlet weak var instructor: UILabel!
//    @IBOutlet weak var remaining: UILabel!
//    @IBOutlet weak var image: UIImageView!
//
//
//    func configure(with content: Section) {
//        name.text = content.course?.name
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//}


class SectionCell: UICollectionViewCell, ConfiguringCell {
    typealias Content = Section
    static var reuseIdentifier: String = "section_cell"
    var isEditing: Bool = false
    
    
    let image: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cross"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let crn: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let instructor: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Test"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let waitlist: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.adjustsFontSizeToFitWidth = true
           label.font = UIFont.systemFont(ofSize: 20)
           return label
    }()
    
    let seats: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.adjustsFontSizeToFitWidth = true
           label.font = UIFont.systemFont(ofSize: 20)
           return label
    }()
    
    func configure(with content: Section) {
        name.text = "\(content.course?.identifier ?? "") Section: \(content.id ?? "")"
        crn.text = "CRN: \(content.crn ?? "")"
        seats.text = "Remaining: \(content.seats?.remaining ?? "0")"
        waitlist.text = "Remaining on waitlist: \(content.seats?.remainingWL ?? "0")"
        if let seats = Int(content.seats?.remaining ?? "0") {
            if seats > 0 {
                image.image = UIImage(named: "check")
            } else {
                image.image = UIImage(named: "cross")
            }
        }
        if let school = content.course?.school, let color = schoolColors[school] {
            contentView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let seatsStack = UIStackView(arrangedSubviews: [seats, waitlist])
        seatsStack.axis = .vertical
        seatsStack.distribution = .fillEqually
        
        let innerStack = UIStackView(arrangedSubviews: [name, crn, instructor, seatsStack])
        innerStack.axis = .vertical
        
        let headerStack = UIStackView(arrangedSubviews: [image, innerStack])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.alignment = .top
        headerStack.spacing = 8
        headerStack.isLayoutMarginsRelativeArrangement = true
        headerStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
//        let stack = UIStackView(arrangedSubviews: [headerStack, seatsStack])
//        stack.axis = .vertical
//        stack.translatesAutoresizingMaskIntoConstraints = false
        
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //image.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        contentView.addSubview(headerStack)
        headerStack.fill(contentView)
        contentView.backgroundColor = .systemYellow
        contentView.layer.cornerRadius = 20
        contentView.layer.cornerCurve = .continuous
        
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
