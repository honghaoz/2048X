//
//  BlackSelectionControl.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/30/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class BlackSelectionControl: UIControl {
    
    private let selectionDotView = UIView()
    
    override var bounds: CGRect {
        didSet {
            updateSelectionDotView()
        }
    }
    
    // MARK:- Init Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
    }
    
    private func setupViews() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 5.0
        
        selectionDotView.backgroundColor = UIColor.black
        updateSelectionDotView()
        
        addSubview(selectionDotView)
    }
    
    func updateSelectionDotView() {
        selectionDotView.frame = frameForSelectionDotView()
    }
    
    func frameForSelectionDotView() -> CGRect {
        let width = bounds.width * 0.4
        let height = bounds.height * 0.4
        let x = (bounds.width - width) / 2.0
        let y = (bounds.height - height) / 2.0
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override var highlighted: Bool {
        didSet {
            selectionDotView.alpha = highlighted ? 1.0 : 0.0
        }
    }
    
    override var selected: Bool {
        didSet {
            selectionDotView.alpha = selected ? 1.0 : 0.0
        }
    }
}
