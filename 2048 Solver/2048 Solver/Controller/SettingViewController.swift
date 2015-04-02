//
//  SettingViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

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
    
    let presentingAnimator = PresentingAnimator()
    
    var mainViewController: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 230 is height without table view rows, 10 bottom spacing
        var height: CGFloat = 230 + 10
        height += CGFloat(mainViewController.aiChoices.count) * kTableViewRowHeight
        presentingAnimator.presentingViewSize = CGSize(width: ceil(screenWidth * (is320ScreenWidth ? 0.82 : 0.7) + 24), height: height)
        
        //
        dimension = mainViewController.dimension
        
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Select AI
        let selectedIndexPath = NSIndexPath(forRow: mainViewController.aiSelectedChoiceIndex, inSection: 0)
        aiAlgorithmTableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
    }
    
    private func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor
        view.layer.borderColor = UIColor.blackColor().CGColor
        view.layer.borderWidth = 5.0
        
        // MainContainerView
        mainContainerView = UIView()
        mainContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["mainContainerView"] = mainContainerView
        view.addSubview(mainContainerView)
        
        // Animation Duration Title Label
        animationDurationTitleLabel = UILabel()
        animationDurationTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationTitleLabel"] = animationDurationTitleLabel
        mainContainerView.addSubview(animationDurationTitleLabel)
        
        animationDurationTitleLabel.text = "Animation Duration:"
        animationDurationTitleLabel.textColor = UIColor.blackColor()
        animationDurationTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationTitleLabel.textAlignment = NSTextAlignment.Left
        animationDurationTitleLabel.numberOfLines = 1
        
        // Animation Duration Number Label
        animationDurationNumberLabel = UILabel()
        animationDurationNumberLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationNumberLabel"] = animationDurationNumberLabel
        mainContainerView.addSubview(animationDurationNumberLabel)
        
        animationDurationNumberLabel.text = String(format: "%0.2f", sharedAnimationDuration)
        animationDurationNumberLabel.textColor = UIColor.blackColor()
        animationDurationNumberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationNumberLabel.textAlignment = NSTextAlignment.Center
        animationDurationNumberLabel.numberOfLines = 1
        
        // Animation Duration Under score view
        animationDurationNumberUnderscoreView = UIView()
        animationDurationNumberUnderscoreView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationNumberUnderscoreView"] = animationDurationNumberUnderscoreView
        mainContainerView.addSubview(animationDurationNumberUnderscoreView)
        
        animationDurationNumberUnderscoreView.backgroundColor = UIColor.blackColor()
        
        let cHeight = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: 3.0)
        animationDurationNumberUnderscoreView.addConstraint(cHeight)
        let cWidth = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: animationDurationNumberLabel, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)
        let cTopSpacing = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: animationDurationNumberLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        let cLeading = NSLayoutConstraint(item: animationDurationNumberUnderscoreView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: animationDurationNumberLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
        mainContainerView.addConstraints([cWidth, cTopSpacing, cLeading])
        
        // Animation Duration Unit Label
        animationDurationUnitLabel = UILabel()
        animationDurationUnitLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationUnitLabel"] = animationDurationUnitLabel
        mainContainerView.addSubview(animationDurationUnitLabel)
        
        animationDurationUnitLabel.text = "s"
        animationDurationUnitLabel.textColor = UIColor.blackColor()
        animationDurationUnitLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationUnitLabel.textAlignment = NSTextAlignment.Center
        animationDurationUnitLabel.numberOfLines = 1
        
        animationDurationUnitLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        animationDurationUnitLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        animationDurationUnitLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        animationDurationUnitLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        
        // Animation Duration Slider
        animationDurationSlider = BlackSlider()
        animationDurationSlider.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationSlider"] = animationDurationSlider
        mainContainerView.addSubview(animationDurationSlider)
        animationDurationSlider.minimumValue = 0.0
        animationDurationSlider.maximumValue = 1.0
        animationDurationSlider.value = Float(sharedAnimationDuration)
        animationDurationSlider.addTarget(self, action: "animationDurationSliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Dimension Title Label
        dimensionTitleLabel = UILabel()
        dimensionTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["dimensionTitleLabel"] = dimensionTitleLabel
        mainContainerView.addSubview(dimensionTitleLabel)
        
        dimensionTitleLabel.text = "Board Size:"
        dimensionTitleLabel.textColor = UIColor.blackColor()
        dimensionTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        dimensionTitleLabel.textAlignment = NSTextAlignment.Left
        dimensionTitleLabel.numberOfLines = 1
        
        // Dimension Number Label
        dimensionNumberLabel = UILabel()
        dimensionNumberLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["dimensionNumberLabel"] = dimensionNumberLabel
        mainContainerView.addSubview(dimensionNumberLabel)
        
        dimensionNumberLabel.text = String(format: "%d×%d", dimension, dimension)
        dimensionNumberLabel.textColor = UIColor.blackColor()
        dimensionNumberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        dimensionNumberLabel.textAlignment = NSTextAlignment.Center
        dimensionNumberLabel.numberOfLines = 1
        
        // Dimension Slider
        dimensionSlider = BlackSlider()
        dimensionSlider.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["dimensionSlider"] = dimensionSlider
        mainContainerView.addSubview(dimensionSlider)
        dimensionSlider.minimumValue = 2
        dimensionSlider.maximumValue = 12
        dimensionSlider.value = Float(dimension)
        dimensionSlider.addTarget(self, action: "dimensionSliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // aiAlgorithmTitleLabel
        aiAlgorithmTitleLabel = UILabel()
        aiAlgorithmTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["aiAlgorithmTitleLabel"] = aiAlgorithmTitleLabel
        mainContainerView.addSubview(aiAlgorithmTitleLabel)
        
        aiAlgorithmTitleLabel.text = "Algorithm:"
        aiAlgorithmTitleLabel.textColor = UIColor.blackColor()
        aiAlgorithmTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        aiAlgorithmTitleLabel.textAlignment = NSTextAlignment.Left
        aiAlgorithmTitleLabel.numberOfLines = 1
        
        // aiAlgorithmTableView
        aiAlgorithmTableView = UITableView()
        aiAlgorithmTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["aiAlgorithmTableView"] = aiAlgorithmTableView
        mainContainerView.addSubview(aiAlgorithmTableView)
        setupTableView()
        
        // Save button
        saveButton = BlackBorderButton()
        saveButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        saveButton.title = "Save"
        saveButton.addTarget(self, action: "saveButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["saveButton"] = saveButton
        view.addSubview(saveButton)
        
        // Cancel button
        cancelButton = BlackBorderButton()
        cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelButton.title = "Cancel"
        cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["cancelButton"] = cancelButton
        view.addSubview(cancelButton)
        
        // Auto Layout
        // H:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mainContainerView]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[animationDurationTitleLabel]-3-[animationDurationNumberLabel]-2-[animationDurationUnitLabel]-(>=12)-|", options: NSLayoutFormatOptions.AlignAllFirstBaseline, metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-32-[animationDurationSlider]-32-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[dimensionTitleLabel]-3-[dimensionNumberLabel]-(>=12)-|", options: NSLayoutFormatOptions.AlignAllFirstBaseline, metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-32-[dimensionSlider]-32-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[aiAlgorithmTitleLabel]", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-24-[aiAlgorithmTableView]-24-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[saveButton]-(-5)-[cancelButton(==saveButton)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        // V:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mainContainerView][saveButton(50)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mainContainerView][cancelButton]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[animationDurationTitleLabel]-10-[animationDurationSlider]-10-[dimensionTitleLabel]-10-[dimensionSlider]-10-[aiAlgorithmTitleLabel]-10-[aiAlgorithmTableView]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
    
    func animationDurationSliderValueChanged(sender: UISlider) {
        animationDurationNumberLabel.text = String(format: "%0.2f", sender.value)
    }
    
    func dimensionSliderValueChanged(sender: UISlider) {
        dimension = Int(floor(sender.value))
        dimensionNumberLabel.text = String(format: "%d×%d", dimension, dimension)
    }
    
    func saveButtonTapped(sender: UIButton) {
        logDebug()
        sharedAnimationDuration = NSTimeInterval(animationDurationSlider.value)
        mainViewController.aiSelectedChoiceIndex = aiAlgorithmTableView.indexPathForSelectedRow()!.row
        mainViewController.dimension = dimension
        
        saveClosure?()
        dismissClosure?()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelButtonTapped(sender: UIButton) {
        logDebug()
        cancelClosure?()
        dismissClosure?()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingViewController: UIViewControllerTransitioningDelegate {
    // MARK: - UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingAnimator.presenting = true
        return presentingAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingAnimator.presenting = false
        return presentingAnimator
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func setupTableView() {
        aiAlgorithmTableView.backgroundColor = UIColor.clearColor()
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
