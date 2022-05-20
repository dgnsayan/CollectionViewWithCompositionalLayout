//
//  LabelCell.swift
//  CompositionalLayout
//
//  Created by Doğan Sayan on 31.03.2022.
//

import UIKit

class LabelCell: UICollectionViewCell {
    
    public lazy var textLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    // coming from programatic UI setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // coming from storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // helper initializer method
    private func commonInit(){
        textLabelConstraints()
    }
    
    
    private func textLabelConstraints(){
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    
}
