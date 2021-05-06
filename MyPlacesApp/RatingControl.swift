//
//  RaitingControl.swift
//  Pods
//
//  Created by Daniyar Mussin on 06.05.2021.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    
    var rating = 0{
        didSet {
            updateButtonSelectedState()
        }
    }
    
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) { didSet {
        setupButtons()
    }
    }
    @IBInspectable var starCount: Int = 5 { didSet {
        setupButtons()
    }
    }
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
       
        // Calculate rating
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private Methods
    
    private func setupButtons(){
        
        
        // Removing buttons
        for button in ratingButtons{
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        
        // Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        // Cycle for creating buttons
        for _ in 0..<starCount {
            
            // Create the button
            let button = UIButton()
            
            // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Adding constrains
            button.translatesAutoresizingMaskIntoConstraints = false // autoconstrains = off
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Adding button to the StackView
            addArrangedSubview(button)
            
            // Adding the new button on the raiting button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectedState()
    }
    
    // selecting buttons after click logic
    private func updateButtonSelectedState(){
        for (index, button) in ratingButtons.enumerated(){
            button.isSelected = index < rating
        }
    }
}
