//
//  FilterItemCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


final class FilterItemCell: UITableViewCell, ConfiguringCell, UIPickerViewDataSource, UIPickerViewDelegate {
    typealias Content = [String]
    @IBOutlet weak var picker: UIPickerView!
    
    var items: [String] = []
    
    func configure(with content: [String]) {
        self.picker.dataSource = self
        self.picker.delegate = self
        self.items = content
        picker.reloadAllComponents()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.backgroundColor = .systemGroupedBackground
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let path = store.filters[self.tag]
        store.submit(.addFilter(path, items[row]))
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        items[row]
    }
}
