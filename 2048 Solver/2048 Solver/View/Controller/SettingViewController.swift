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
    
    var aiAlgorithmTitleLabel: UILabel!
    var aiAlgorithmTableView: UITableView!
    var kAIAlgorithmCellIdentifier: String = "AICell"
    
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
        setupViews()
        presentingAnimator.presentingViewSize = CGSize(width: ceil(screenWidth * (is320ScreenWidth ? 0.82 : 0.7) + 24), height: 280.0)
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
        
        // Title Label
        animationDurationTitleLabel = UILabel()
        animationDurationTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationTitleLabel"] = animationDurationTitleLabel
        mainContainerView.addSubview(animationDurationTitleLabel)
        
        animationDurationTitleLabel.text = "Animation Duration:"
        animationDurationTitleLabel.textColor = UIColor.blackColor()
        animationDurationTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationTitleLabel.textAlignment = NSTextAlignment.Left
        animationDurationTitleLabel.numberOfLines = 1
        
        //
        animationDurationNumberLabel = UILabel()
        animationDurationNumberLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationNumberLabel"] = animationDurationNumberLabel
        mainContainerView.addSubview(animationDurationNumberLabel)
        
        animationDurationNumberLabel.text = String(format: "%0.2f", sharedAnimationDuration)
        animationDurationNumberLabel.textColor = UIColor.blackColor()
        animationDurationNumberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        animationDurationNumberLabel.textAlignment = NSTextAlignment.Center
        animationDurationNumberLabel.numberOfLines = 1
        
        animationDurationNumberUnderscoreView = UIView()
        animationDurationNumberUnderscoreView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationNumberUnderscoreView"] = animationDurationNumberUnderscoreView
        mainContainerView.addSubview(animationDurationNumberUnderscoreView)
        
        animationDurationNumberUnderscoreView.backgroundColor = UIColor.blackColor()
        
        //
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
        
        animationDurationSlider = BlackSlider()
        animationDurationSlider.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["animationDurationSlider"] = animationDurationSlider
        mainContainerView.addSubview(animationDurationSlider)
        animationDurationSlider.minimumValue = 0.0
        animationDurationSlider.maximumValue = 1.0
        animationDurationSlider.value = Float(sharedAnimationDuration)
        animationDurationSlider.addTarget(self, action: "animationDurationSliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // aiAlgorithmTitleLabel
        aiAlgorithmTitleLabel = UILabel()
        aiAlgorithmTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["aiAlgorithmTitleLabel"] = aiAlgorithmTitleLabel
        mainContainerView.addSubview(aiAlgorithmTitleLabel)
        
        aiAlgorithmTitleLabel.text = "AI Algorithm:"
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
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[aiAlgorithmTitleLabel]", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-24-[aiAlgorithmTableView]-24-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[saveButton]-(-5)-[cancelButton(==saveButton)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        // V:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mainContainerView][saveButton(50)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mainContainerView][cancelButton]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        mainContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[animationDurationTitleLabel]-10-[animationDurationSlider]-10-[aiAlgorithmTitleLabel]-10-[aiAlgorithmTableView]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
    
    func animationDurationSliderValueChanged(sender: UISlider) {
        let string = String(format: "%0.2f", sender.value)
        animationDurationNumberLabel.text = string
    }
    
    func saveButtonTapped(sender: UIButton) {
        logDebug()
        sharedAnimationDuration = NSTimeInterval(animationDurationSlider.value)
        mainViewController.aiSelectedChoiceIndex = aiAlgorithmTableView.indexPathForSelectedRow()!.row
        
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
        return 34
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 34
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kAIAlgorithmCellIdentifier) as! AIAlgorithmCell
        // Configuration
        let aiTuple = mainViewController.aiChoices[indexPath.row]!
        cell.titleLabel.text = aiTuple.description
        return cell
    }
}
