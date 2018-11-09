//
//  Errors.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/6/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Error resulting in an undefined value
public enum CalculationError: Error {
    
    /// Division by zero
    case divideByZero
    
    /// Zero to the power of zero
    case zeroToTheZero
    
    /// Outside the domain of a function
    case domainError
    
    /// A function argument is missing
    case missingFunctionArgument
    
    /// A function definition is missing
    case missingFunctionDefinition
    
    /// A complex number is raised to a fractional exponent
    case rootOfComplexNumber
    
    /// A number is raised to a complex number
    case raisedToComplexNumber
    
}

/// Error resulting in an inability to solve
public enum SolvingError: Error {
    
    /// The equation is not algebraic
    case nonAlgebraic
    
    /// The equation is too complex
    case tooComplex
    
    /// An illegal string is passed
    case parsingError
    
    /// Non-Comparable (i.e. complex) numbers are compared
    case nonComparable
    
    /// Syntax error
    case syntax
    
}
