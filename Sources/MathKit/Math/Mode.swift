//
//  Mode.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents the setting for the units of angle measurements
public enum AngleMode: Int {
    
    /// Angles are measured in degrees
    case degree = 1
    
    /// Angles are measured in radians
    case radian = 0
    
}

/// Represents the setting for how numbers are evaluated
public enum NumberMode {
    
    /// Numbers are evaluated as decimals
    case decimal
    
    /**
     
    Numbers are evaluated as fractions
     
    - approximationAccuracy: how many decimal places fraction approximations are
     
    */
    case fraction(approximationAccuracy: Int)
    
}

/// Represents the mode for when fractions are combined in simplifying
public enum FractionMode {
    
    /// If there is a fraction in any term, all terms are combined into one fraction
    case combineAllTerms
    
    /// Combine every term that is a fraction
    case combineAllFractions
    
    /// Combine fractions with same denominators
    case combineLikeFractions
    
    /// Never allow the numerator of a fraction have more than one term
    case neverCombineFractions
    
}

public enum FunctionMode {
    
    /// Plug the function arguments into the function when solving
    case plugIn
    
    /// Do not plug the function arguments into the function when solving
    case keepWhole
    
}
