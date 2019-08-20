//
//  SettingViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
//import Google
import ChouTi
import ChouTiUI

class SettingViewController: UIViewController {

    var mainContainerView: UIView!
    
    var animationDurationTitleLabel: UILabel!
    var animationDurationNumberLabel: UILabel!
    var animationDurationNumberUnderscoreView: UIView!
    var animationDurationUnitLabel: UILabel!
    
    var animationDurationSlider: BlackSlider!
    
    var dimensionTitleLabel: UILabel!
    var dimensionNumberLabel: UILabel!
    var dimensionSlider: BlackSlider!
    var dimension: Int!
    
    var aiAlgorithmTitleLabel: UILabel!
    var aiAlgorithmTableView: UITableView!
    var kAIAlgorithmCellIdentifier: String = "AICell"
    let kTableViewRowHeight: CGFloat = 34.0
    
    var saveButton: BlackBorderButton!
    var cancelButton: BlackBorderButton!
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    var saveClosure: (() -> ())? = nil
    var cancelClosure: (() -> ())? = nil
    var dismissClosure: (() -> ())? = nil
    
    let animator = DropPresentingAnimator()
    
    weak var mainViewController: MainViewController!
    
    convenience init(mainViewController: MainViewController) {
        self.init()

        self.mainViewController = mainViewController
        
        // 230 is height without table view rows, 10 bottom spacing
        var height: CGFloat = 230 + 10
        height += CGFloat(mainViewController.aiChoices.count) * kTableViewRowHeight
        
        animator.animationDuration = 0.75
        animator.allowDragToDismiss = false
        animator.shouldDismissOnTappingOutsideView = true
        animator.overlayViewStyle = .Normal(UIColor(white: 0.0, alpha: 0.7))
        animator.presentingViewSize = CGSize(width: ceil(screenWidth * (is320ScreenWidth ? 0.82 : 0.7) + 24), height: height)
        
        modalPresentationStyle = .custom
        transitioningDelegate = animator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dimension = mainViewController.dimension
        
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Select AI
        let selectedIndexPath = NSIndexPath(forRow: mainViewController.aiSelectedChoiceIndex, inSection: 0)
        aiAlgorithmTableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: "Setting View")
//        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createScreenView().build() as Dictionary)
    }
    
    private func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 5.0
        
        // MainContainerView
        mainContainerView = UIView()
        mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        views["mainContainerView"] = mainContainerView
        view.addSubview(mainContainerView)
        
        // Animation Duration Title Label
        animationDurationTitleLabel = UILabel()
        animationDurationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        views["animationDurationTitleLabel"] = animationDurationTitleLabel
        mainContainerView.addSubview(animationDurationTitleLabel)
        
        animationDurationTitleLabel.text = "Animation Duration:"
        animationDurationTitleLabel.textColor = UIColor.black
        animationDurationTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationTitleLabel.textAlignment = .left
        animationDurationTitleLabel.numberOfLines = 1
        
        // Animation Duration Number Label
        animationDurationNumberLabel = UILabel()
        animationDurationNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        views["animationDurationNumberLabel"] = animationDurationNumberLabel
        mainContainerView.addSubview(animationDurationNumberLabel)
        
        animationDurationNumberLabel.text = String(format: "%0.2f", sharedAnimationDuration)
        animationDurationNumberLabel.textColor = UIColor.black
        animationDurationNumberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationNumberLabel.textAlignment = .center
        animationDurationNumberLabel.numberOfLines = 1
        
        // Animation Duration Under score view
        animationDurationNumberUnderscoreView = UIView()
        animationDurationNumberUnderscoreView.translatesAutoresizingMaskIntoConstraints = false
        views["animationDurationNumberUnderscoreView"] = animationDurationNumberUnderscoreView
        mainContainerView.addSubview(animationDurationNumberUnderscoreView)
        
        animationDurationNumberUnderscoreView.backgroundColor = UIColor.black
        
        let cHeight = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: 3.0)
        animationDurationNumberUnderscoreView.addConstraint(cHeight)
        let cWidth = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: .width, relatedBy: .equal, toItem: animationDurationNumberLabel, attribute: .width, multiplier: 1.0, constant: 0.0)
        let cTopSpacing = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: .top, relatedBy: .equal, toItem: animationDurationNumberLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let cLeading = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: .leading, relatedBy: .equal, toItem: animationDurationNumberLabel, attribute: .leading, multiplier: 1.0, constant: 0.0)
        mainContainerView.addConstraints([cWidth, cTopSpacing, cLeading])
        
        // Animation Duration Unit Label
        animationDurationUnitLabel = UILabel()
        animationDurationUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        views["animationDurationUnitLabel"] = animationDurationUnitLabel
        mainContainerView.addSubview(animationDurationUnitLabel)
        
        animationDurationUnitLabel.text = "s"
        animationDurationUnitLabel.textColor = UIColor.black
        animationDurationUnitLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationUnitLabel.textAlignment = .center
        animationDurationUnitLabel.numberOfLines = 1
        
        animationDurationUnitLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        animationDurationUnitLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        animationDurationUnitLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        animationDurationUnitLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        // Animation Duration Slider
        animationDurationSlider = BlackSlider()
        animationDurationSlider.translatesAutoresizingMaskIntoConstraints = false
        views["animationDurationSlider"] = animationDurationSlider
        mainContainerView.addSubview(animationDurationSlider)
        animationDurationSlider.minimumValue = 0.0
        animationDurationSlider.maximumValue = 1.0
        animationDurationSlider.value = Float(sharedAnimationDuration)
        animationDurationSlider.addTarget(self, action: #selector(animationDurationSliderValueChanged(_:)), forControlEvents: .valueChanged)
        
        // Dimension Title Label
        dimensionTitleLabel = UILabel()
        dimensionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        views["dimensionTitleLabel"] = dimensionTitleLabel
        mainContainerView.addSubview(dimensionTitleLabel)
        
        dimensionTitleLabel.text = "Board Size:"
        dimensionTitleLabel.textColor = UIColor.black
        dimensionTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        dimensionTitleLabel.textAlignment = .left
        dimensionTitleLabel.numberOfLines = 1
        
        // Dimension Number Label
        dimensionNumberLabel = UILabel()
        dimensionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        views["dimensionNumberLabel"] = dimensionNumberLabel
        mainContainerView.addSubview(dimensionNumberLabel)
        
        dimensionNumberLabel.text = String(format: "%d×%d", dimension, dimension)
        dimensionNumberLabel.textColor = UIColor.black
        dimensionNumberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        dimensionNumberLabel.textAlignment = .center
        dimensionNumberLabel.numberOfLines = 1
        
        // Dimension Slider
        dimensionSlider = BlackSlider()
        dimensionSlider.translatesAutoresizingMaskIntoConstraints = false
        views["dimensionSlider"] = dimensionSlider
        mainContainerView.addSubview(dimensionSlider)
        dimensionSlider.minimumValue = 2
        dimensionSlider.maximumValue = 12
        dimensionSlider.value = Float(dimension)
        dimensionSlider.addTarget(self, action: #selector(dimensionSliderValueChanged(_:)), for: .valueChanged)
        
        // aiAlgorithmTitleLabel
        aiAlgorithmTitleLabel = UILabel()
        aiAlgorithmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        views["aiAlgorithmTitleLabel"] = aiAlgorithmTitleLabel
        mainContainerView.addSubview(aiAlgorithmTitleLabel)
        
        aiAlgorithmTitleLabel.text = "AI Algorithm:"
        aiAlgorithmTitleLabel.textColor = UIColor.black
        aiAlgorithmTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        aiAlgorithmTitleLabel.textAlignment = .left
        aiAlgorithmTitleLabel.numberOfLines = 1
        
        // aiAlgorithmTableView
        aiAlgorithmTableView = UITableView()
        aiAlgorithmTableView.translatesAutoresizingMaskIntoConstraints = false
        views["aiAlgorithmTableView"] = aiAlgorithmTableView
        mainContainerView.addSubview(aiAlgorithmTableView)
        setupTableView()
        
        // Save button
        saveButton = BlackBorderButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.title = "Save"
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), forControlEvents: .touchUpInside)
        views["saveButton"] = saveButton
        view.addSubview(saveButton)
        
        // Cancel button
        cancelButton = BlackBorderButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.title = "Cancel"
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), forControlEvents: .touchUpInside)
        views["cancelButton"] = cancelButton
        view.addSubview(cancelButton)
        
        // Auto Layout
        // H:
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mainContainerView]|", options: [], metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[animationDurationTitleLabel]-3-[animationDurationNumberLabel]-2-[animationDurationUnitLabel]-(>=12)-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[animationDurationSlider]-32-|", options: [], metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[dimensionTitleLabel]-3-[dimensionNumberLabel]-(>=12)-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[dimensionSlider]-32-|", options: [], metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[aiAlgorithmTitleLabel]", options: [], metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[aiAlgorithmTableView]-24-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[saveButton]-(-5)-[cancelButton(==saveButton)]|", options: [], metrics: metrics, views: views))
        
        // V:
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mainContainerView][saveButton(50)]|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mainContainerView][cancelButton]|", options: [], metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[animationDurationTitleLabel]-10-[animationDurationSlider]-10-[dimensionTitleLabel]-10-[dimensionSlider]-10-[aiAlgorithmTitleLabel]-10-[aiAlgorithmTableView]|", options: [], metrics: metrics, views: views))
    }
    
    @objc func animationDurationSliderValueChanged(_ sender: UISlider) {
        animationDurationNumberLabel.text = String(format: "%0.2f", sender.value)
    }
    
    @objc func dimensionSliderValueChanged(_ sender: UISlider) {
        dimension = Int(floor(sender.value))
        dimensionNumberLabel.text = String(format: "%d×%d", dimension, dimension)
    }
    
    @objc func saveButtonTapped(_ sender: UIButton) {
//        let eventDict = GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "button_press", label: "save_setting", value: nil).build() as Dictionary
//        GAI.sharedInstance().defaultTracker.send(eventDict)

        log.debug()
        sharedAnimationDuration = TimeInterval(animationDurationSlider.value)
        mainViewController.aiSelectedChoiceIndex = aiAlgorithmTableView.indexPathForSelectedRow!.row
        mainViewController.dimension = dimension
        
        saveClosure?()
        dismissClosure?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
//        let eventDict = GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "button_press", label: "cancel_setting", value: nil).build() as Dictionary
//        GAI.sharedInstance().defaultTracker.send(eventDict)

        log.debug()
        cancelClosure?()
        dismissClosure?()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func setupTableView() {
        aiAlgorithmTableView.backgroundColor = UIColor.clear
        aiAlgorithmTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        aiAlgorithmTableView.allowsMultipleSelection = false
        
        aiAlgorithmTableView.registerClass(AIAlgorithmCell.self, forCellReuseIdentifier: kAIAlgorithmCellIdentifier)
        aiAlgorithmTableView.dataSource = self
        aiAlgorithmTableView.delegate = self
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainViewController.aiChoices.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kTableViewRowHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kTableViewRowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kAIAlgorithmCellIdentifier) as! AIAlgorithmCell
        // Configuration
        let aiTuple = mainViewController.aiChoices[indexPath.row]!
        cell.titleLabel.text = aiTuple.description
        return cell
    }
}
