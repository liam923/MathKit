//
//  Number.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/9/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

public class Number: Value, Hashable {
    
    // MARK: Basic Numbers
    
    public static var negativeOne: Number { return Number(int: -1) }
    public static var zero: Number { return Number(int: 0) }
    public static var one: Number { return Number(int: 1) }
    public static var pi: Number { return Number(double: 3.1415926535897932384626433832795028841971693993751) }
    public static var e: Number { return Number(double: 2.7182818284590452353602874713526624977572470936999) }
    
    // MARK: Number properties
    
    /// The `Double` value of the real part of `self`
    internal var realNum = 0.0
    
    /// The `Double` value of the imaginary part of `self`
    internal var imaginaryNum = 0.0
    
    /// `self` as an `Int`
    public var asInteger: Int? {
        
        if imaginaryNum == 0.0 && realNum.truncatingRemainder(dividingBy: 1.0) == 0 {
            
            return Int(realNum)
            
        } else { return nil }
        
    }
    
    /// The complex conjugate of `self`
    public var conjugate: Number {
        
        let num = Number(real: realNum, imaginary: -imaginaryNum)
        return num
        
    }
    
    /// `true` if `self` is real
    public var isReal: Bool {
        
        return imaginaryNum == 0.0
        
    }
    
    /// (numerator, denominator); `nil` if unreal or takes to long
    internal var approximateRational: (Int, Int)? {
        
        if isReal {
            
            let epsilon = 0.000000001
            
            var numerator = 0.0
            var denominator = (realNum >= 0.0) ? 1.0 : -1.0
            
            var divided = numerator / denominator
            while abs(divided - realNum) > epsilon {
                
                if abs(divided) > abs(realNum) { denominator += realNum > 0.0 ? 1 : -1 }
                else { numerator += 1 }
                
                divided = numerator / denominator
                
                if numerator + denominator > 10000 { return nil }
                
            }
            
            return (Int(numerator), Int(denominator))
            
        } else { return nil }
        
    }
    
    // MARK: Initializers
    
    /**
 
    Initilizes with given value
     
    - Parameter double: value given to `self`
     
    */
    public convenience init(double: Double) {
        
        self.init()
        realNum = double
        
    }
    
    /**
     
    Initilizes with given value
     
    - Parameter int: value given to `self`
     
    */
    public convenience init(int: Int) {
        
        self.init()
        realNum = Double(int)
        
    }
    
    /**
 
    Initializes with the given values
     
    - Parameter real: the real part of the number
    - Parameter imaginary: the imaginary part of the number
     
    */
    public convenience init(real: Double, imaginary: Double) {
        
        self.init()
        realNum = real
        imaginaryNum = imaginary
        
    }
    
    /**
     
    Initializes based on the given `String`
     
    - Parameter string: the `String` that `self` will be based on
    - Parameter system: the `System` that `self` is initialized within
     
    */
    public convenience init(string: String, system: System) throws {
        
        if let d = Double(string) {
            
            self.init(double: d)
            
        } else { throw SolvingError.parsingError }
        
    }
    
    // MARK: Functions
    
    public func add(_ number: Number) -> Number {
        
        let num = Number(real: realNum + number.realNum, imaginary: imaginaryNum + number.imaginaryNum)
        return num
        
    }
    
    public func subtract(_ number: Number) -> Number {
        
        let num = Number(real: self.realNum - number.realNum, imaginary: self.imaginaryNum - number.imaginaryNum)
        return num
        
    }
    
    public func multiply(_ number: Number) -> Number {
        
        let real = (self.realNum * number.realNum) - (self.imaginaryNum * number.imaginaryNum)
        let imaginary = (self.realNum * number.imaginaryNum) + (self.imaginaryNum * number.realNum)
        
        let num = Number(real: real, imaginary: imaginary)
        
        return num
        
    }
    
    public func divide(_ number: Number) -> Number {
        
        let real = ((self.realNum * number.realNum) + (self.imaginaryNum * number.imaginaryNum)) / ((number.realNum * number.realNum) + (number.imaginaryNum * number.imaginaryNum))
        let imaginary = ((self.imaginaryNum * number.realNum) - (self.realNum * number.imaginaryNum)) / ((number.realNum * number.realNum) + (number.imaginaryNum * number.imaginaryNum))
        
        let num = Number(real: real, imaginary: imaginary)
        
        return num
        
    }
    
    public func exponentiate(_ number: Number) throws -> Number {
        
        guard number.imaginaryNum == 0.0 else {
            throw CalculationError.raisedToComplexNumber
        }
        
        if let number = number.asInteger, number >= 0, self.imaginaryNum != 0.0 {
            
            if number == 0 {
                
                guard self.realNum != 0 || self.imaginaryNum != 0 else {
                    throw CalculationError.zeroToTheZero
                }
                
                return Number.one
                
            }
            
            var num = self.copy() as! Number
            for _ in 1..<number {
                
                num *= self
                
            }
            
            return num
            
        } else if self.imaginaryNum == 0.0 {
            
            if self.realNum == 0.0 { return Number.zero }
            
            if let (numerator, denominator) = number.approximateRational {
                
                var denominator = denominator
                
                let baseSign = self.realNum > 0.0 ? 1 : -1
                let exponentSign = denominator > 0 ? 1 : -1
                
                let base = self.realNum * Double(baseSign)
                denominator *= exponentSign
                
                var power = pow(base, Double(numerator) / Double(denominator))
                if exponentSign == -1 { power = 1.0 / power }
                
                if numerator % 2 == 1 { power *= Double(baseSign) }
                
                if denominator % 2 == 0 && baseSign == -1 {
                    
                    return Number(real: 0.0, imaginary: -1.0 * power)
                    
                } else { return Number(double: power) }
                
            } else {
                
                return Number(double: pow(abs(self.realNum), number.realNum)) * (self.realNum >= 0.0 ? Number.one : Number.negativeOne)
                
            }
            
        } else { throw CalculationError.rootOfComplexNumber }
        
    }
    
    /**
 
    Calculates remainder
     
    - Parameter number: the number that is used as the mod base
    - Returns: `self` % `number`
     
    */
    public func mod(_ number: Number) throws -> Number {
        
        guard self.isReal && number.isReal else { throw CalculationError.domainError }
        
        let num = self.realNum.truncatingRemainder(dividingBy: number.realNum)
        
        return Number(double: num)
        
    }
    
    /**
     
    Gets the absolute value
     
    - Returns: the absolute value; nil if unreal
     
    */
    public func absoluteValue() -> Number? {
        
        if isReal {
            
            if try! self < Number.zero { return Number.negativeOne * self }
            else { return self.copy() as? Number }
            
        } else { return nil }
        
    }
    
    public override func equals(_ value: Value) -> Bool {
        
        if !(value is Number) { return false }
        else { return  super.equals(value) && self.realNum == (value as! Number).realNum && self.imaginaryNum == (value as! Number).imaginaryNum }
        
    }
    
    public override func copy() -> Value {
        
        let number = Number(real: realNum, imaginary: imaginaryNum)
        
        return number
        
    }
    
    public override func evaluate() throws -> Number {
        
        return self.copy() as! Number
        
    }
    
    public func floor() throws -> Number {
        
        guard self.isReal else { throw CalculationError.domainError }
        
        let num = Int(self.realNum)
        
        if try! self < Number.zero { return Number(int: num + 1) }
        else { return Number(int: num) }
        
    }
    
    /**
     
    Gets the greatest common factor with another `Number`
     
    - Parameter number: the other `Number`
    - Returns: the gcf of `self` and `number`
     
    */
    internal func gcf(with number: Number) -> Number {
        
        if let a = self.asInteger, let b = number.asInteger {
            
            return Number(int: Int.gcf(a, b))
            
        } else { return Number.one }
        
    }
    
    /**
     
    Gets the least common multiple with another `Number`
    
    - Parameter number: the other `Number`
    - Returns: the lcm of `self` and `number`
     
    */
    internal func lcm(with number: Number) throws -> Number {
        
        return self * number / self.gcf(with: number)
        
    }
    
    public override func getVariables() -> [Variable] {
        
        return []
        
    }
    
    // MARK: CustomStringConvertible
    
    public override var description: String {
        
        func formattedDouble(num: Double) -> String {
            
            let components = num.description.components(separatedBy: "e")
            
            var powerDes = ""
            if components.count > 1 {
                
                powerDes = "*10^"
                let e = Int(components[1])!
                powerDes += e > 0 ? "\(e)" : "(\(e))"
                
            }
            
            var numDes = components[0]
            while numDes.last == "0" {
                
                numDes.removeLast()
                
            }
            if numDes.last == "." {
                
                numDes.removeLast()
                
            }
            
            return numDes == "1" && powerDes != "" ? String(powerDes[powerDes.index(after: powerDes.startIndex)...]) : numDes + powerDes
            
        }
        
        let realDes = formattedDouble(num: realNum)
        let imaginaryDes = formattedDouble(num: imaginaryNum) + "ⅈ"
        
        if realNum == 0.0 && imaginaryNum == 0.0 { return super.description + "0" }
        else if realNum == 0.0 {
            
            return super.description + imaginaryDes
            
        } else if imaginaryNum == 0.0 {
            
            return super.description + realDes
            
        } else {
            
            return "\(super.description)\(realDes)\(imaginaryNum > 0.0 ? "+" : "")\(imaginaryDes)"
            
        }
        
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return realNum.hashValue
        
    }
    
}

// MARK: Arithmetic Operators

public func +(lhs: Number, rhs: Number) -> Number {
    
    return lhs.add(rhs)
    
}

public func -(lhs: Number, rhs: Number) -> Number {
    
    return lhs.subtract(rhs)
    
}

public func *(lhs: Number, rhs: Number) -> Number {
    
    return lhs.multiply(rhs)
    
}

public func /(lhs: Number, rhs: Number) -> Number {
    
    return lhs.divide(rhs)
    
}

public func %(lhs: Number, rhs: Number) throws -> Number {
    
    return try lhs.mod(rhs)
    
}

public func ^(lhs: Number, rhs: Number) throws -> Number {
    
    return try lhs.exponentiate(rhs)
    
}

public func +=(lhs: inout Number, rhs: Number) {
    
    let result = lhs + rhs
    
    lhs.realNum = result.realNum
    lhs.imaginaryNum = result.imaginaryNum
    
}

public func -=(lhs: inout Number, rhs: Number) {
    
    let result = lhs - rhs
    
    lhs.realNum = result.realNum
    lhs.imaginaryNum = result.imaginaryNum
    
}

public func *=(lhs: inout Number, rhs: Number) {
    
    let result = lhs * rhs
    
    lhs.realNum = result.realNum
    lhs.imaginaryNum = result.imaginaryNum
    
}

public func /=(lhs: inout Number, rhs: Number) {
    
    let result = lhs / rhs
    
    lhs.realNum = result.realNum
    lhs.imaginaryNum = result.imaginaryNum
    
}

public func +(lhs: Number, rhs: Int) -> Number {
    
    return lhs + Number(int: rhs)
    
}

public func +=(lhs: inout Number, rhs: Int) {
    
    lhs = lhs + rhs
    
}

public prefix func -(rhs: Number) -> Number {
    
    return Number.negativeOne * rhs
    
}

// MARK: Comparison operators

public func ==(lhs: Number, rhs: Number) -> Bool {
    
    return lhs.equals(rhs)
    
}

public func !=(lhs: Number, rhs: Number) -> Bool {
    
    return !(lhs == rhs)
    
}

public func <=(lhs: Number, rhs: Number) throws -> Bool {
    
    guard lhs.imaginaryNum == 0.0 && rhs.imaginaryNum == 0.0 else {
        throw SolvingError.nonComparable
    }
    
    return lhs.realNum <= rhs.realNum
    
}

public func >=(lhs: Number, rhs: Number) throws -> Bool {
    
    guard lhs.imaginaryNum == 0.0 && rhs.imaginaryNum == 0.0 else {
        throw SolvingError.nonComparable
    }
    
    return lhs.realNum >= rhs.realNum
    
}

public func <(lhs: Number, rhs: Number) throws -> Bool {
    
    guard lhs.imaginaryNum == 0.0 && rhs.imaginaryNum == 0.0 else {
        throw SolvingError.nonComparable
    }
    
    return lhs.realNum < rhs.realNum
    
}

public func >(lhs: Number, rhs: Number) throws -> Bool {
    
    guard lhs.imaginaryNum == 0.0 && rhs.imaginaryNum == 0.0 else {
        throw SolvingError.nonComparable
    }
    
    return lhs.realNum > rhs.realNum
    
}

// MARK: Double

extension Double {
    
    /**
 
    Initializes from a `Number`
     
    - Parameter number: value given to `self`
     
    */
    init?(_ number: Number) {
        
        if number.isReal { self = number.realNum }
        else { return nil }
        
    }
    
}

// MARK: Int

extension Int {
    
    /**
     
    Initializes from a `Number`
     
    - Parameter number: value given to `self`
     
    */
    init?(_ number: Number) {
        
        if number.isReal { self = Int(number.realNum) }
        else { return nil }
        
    }
    
    static func gcf(_ a: Int, _ b: Int) -> Int {
        
        let c = abs(a)
        let d = abs(b)
        
        let max = c > d ? c : d
        let min = c < d ? c : d
        
        if min == 0 { return 0 }
        
        let remainder = max % min
        if remainder == 0 { return min }
        else { return Int.gcf(min, remainder) }
        
    }
    
}
