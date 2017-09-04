//
//  ViewController.swift
//  InteractiveAnimations
//
//  Created by Nathan Gitter on 9/4/17.
//  Copyright © 2017 Nathan Gitter. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class ViewController: UIViewController {
    
    private let popupOffset: CGFloat = 440
    
    private lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "content")
        return imageView
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reviews"
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reviews"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = .black
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()
    
    private lazy var reviewsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "reviews")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func layout() {
        
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentImageView)
        contentImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closedTitleLabel)
        closedTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(openTitleLabel)
        openTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 30).isActive = true
        
        reviewsImageView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(reviewsImageView)
        reviewsImageView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        reviewsImageView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        reviewsImageView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
        reviewsImageView.heightAnchor.constraint(equalToConstant: 428).isActive = true
        
    }
    
    private var currentState: State = .closed
    
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    private var animationProgress = [CGFloat]()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
                self.closedTitleLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.openTitleLabel.transform = .identity
                self.openTitleLabel.alpha = 1
                self.closedTitleLabel.alpha = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
                self.closedTitleLabel.transform = .identity
                self.openTitleLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
                self.openTitleLabel.alpha = 0
                self.closedTitleLabel.alpha = 1
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            self.runningAnimators.removeAll()
        }
        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            runningAnimators.forEach { $0.pauseAnimation() }
            animationProgress = runningAnimators.map { $0.fractionComplete }
        case .changed:
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
        case .ended:
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            ()
        }
    }
    
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizerState.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
    }
    
}
