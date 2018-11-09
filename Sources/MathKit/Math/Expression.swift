//
//  Expression.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical expression
public class Expression: Value {
    
    // MARK: Expression values
    
    /// List of the terms added together to form the expression
    public var terms = [Term]()
    
    /// Is `self` the difference of squares?
    internal var isDifferenceOfSquares: Bool {
        
        if terms.count != 2 { return false }
        
        let (numA, termA) = terms[0].extractNumbers()
        let (numB, termB) = terms[1].extractNumbers()
        
        if (try? (numA > Number.zero && numB > Number.zero) || (numA < Number.zero && numB < Number.zero)) ?? true { return false }
        
        return termA.isSquare && termB.isSquare
        
    }
    
    /// Is `self` the sum or difference of cubes?
    internal var isSumOrDifferenceOfCubes: Bool {
        
        if terms.count != 2 { return false }
        
        return terms[0].extractNumbers().1.isCube && terms[1].extractNumbers().1.isCube
        
    }
    
    /// Does `self` have a quadratic pattern?
    internal var isQuadraticPattern: Bool {
        
        if terms.count != 3 { return false }
        
        let termA = terms[0].extractNumbers().1
        let termB = terms[1].extractNumbers().1
        let termC = terms[2].extractNumbers().1
        
        if termC.objects.count != 0 { return false }
        
        if let t = try? termA.divide(term: termB) { return t.extractNumbers().1 == termB }
        else { return false }
        
    }
    
    internal override var isLinear: Bool {
        
        for t in terms {
        
            if !t.isLinear { return false }
        
        }
        
        return true
        
    }
    
    // MARK: Initializers
    
    /**
     
    Initializes based on the given `Term`s
     
    - Parameter terms: the `Term`s in `self`
     
    */
    public convenience init(terms: [Term]) {
        
        self.init()
        
        self.terms = terms
        
    }
    
    /**
     
    Initializes based on the given `String`
     
    - Parameter string: the `String` that `self` will be based on
    - Parameter system: the `System` that `self` is initialized within
     
    */
    public convenience init(string: String, system: System) throws {
        
        self.init()
        
        let str = string.contains(" ") ? string.replacingOccurrences(of: " ", with: "") : string
        
        var bracketsIn = 0
        var currentTerm = ""
        for c in str {
            
            if bracketsIn == 0 && System.additiveCharacters.contains(c) {
                
                if currentTerm != "" {
                    
                    terms.append(try Term(string: currentTerm, system: system))
                    
                }
                currentTerm = ""
                
            } else if System.openBrackets.contains(c) {
                    
                bracketsIn += 1
                    
            } else if System.closeBrackets.contains(c) {
                    
                bracketsIn -= 1
                    
            }
            
            currentTerm += String(c)
            
        }
        terms.append(try Term(string: currentTerm, system: system))
        
    }
    
    // MARK: Functions
    
    /**
     
    Simplifies `self`
     
    - Parameter system: the system that the expression is being simplified within; used for settings
    - Returns: a simplified version of `self`
    
    */
    public func simplify(system: System? = nil) throws -> Expression {
        
        var expression = self.copy()
        
        for i in 0..<expression.terms.count {
            
            expression.terms[i] = try expression.terms[i].factor(system: system)
            
        }
        
        expression = try expression.combineLikeTerms(system: system)
        
        let distributed = Expression()
        for t in expression.terms {
            
            distributed.terms += try t.expand().terms
            
        }
        
        let combined = try distributed.combineLikeTerms(system: system)
        var i = combined.terms.count - 1
        while i >= 0 {
            
            if let simplified = try combined.terms[i].simplify() {
                
                combined.terms[i] = simplified
                
            } else { combined.terms.remove(at: i) }
            i -= 1
            
        }
        if combined.terms == [] { combined.terms = [Term(objects: [Object(base: Number.zero)])] }
        
        return combined.order()
        
    }
    
    /**
 
    Combines like terms in `self`
     
    - Parameter system: the system that the expression is being simplified within; used for settings
    - Returns: a combined version of `self`
     
    */
    internal func combineLikeTerms(system: System? = nil) throws -> Expression {
        
        var summedTerms = [Term]()
        for t in terms {
            
            var match = false
            for i in 0..<summedTerms.count {
                
                if let sum = t.add(term: summedTerms[i], system: system ?? System()) {
                    
                    summedTerms[i] = sum
                    match = true
                    
                }
                
            }
            if !match { summedTerms.append(t.copy()) }
            
        }
        
        let expression = Expression(terms: summedTerms)
        
        switch system?.fractionMode ?? FractionMode.combineLikeFractions {
            
        case .combineAllFractions:
            var lcm = Term(objects: [Object(base: Number.one)])
            let nonFractions = Expression(terms: summedTerms)
            let fractions = Expression()
            var i = nonFractions.terms.count - 1
            while i >= 0 {
                
                if let den = try nonFractions.terms[i].getDenominator()?.getReciprocal() {
                    
                    lcm = try lcm.lcm(with: den)
                    fractions.terms.append(nonFractions.terms[i])
                    nonFractions.terms.remove(at: i)
                    
                }
                i -= 1
                
            }
            if fractions.terms.count != 0 {
            
                let numerator = try fractions.multiply(byTerm: lcm).simplify(system: system)
                let fractionTerm = try Term(objects: [Object(base: numerator)] +  Object(base: lcm, exponent: Number.negativeOne).factor(system: system).objects).combineObjects()
                expression.terms = nonFractions.terms + [fractionTerm]
                
            }
            
        case .combineAllTerms:
            var lcm = Term(objects: [Object(base: Number.one)])
            for t in summedTerms {
                
                if let den = try t.getDenominator()?.getReciprocal() {
                    
                    lcm = try lcm.lcm(with: den)
                    
                }
                
            }
            if (try? lcm.evaluate()) != Number.one {
                
                let numerator = try expression.multiply(byTerm: lcm).simplify(system: system)
                let term = try Term(objects: [Object(base: numerator)] +  Object(base: lcm, exponent: Number.negativeOne).factor(system: system).objects).combineObjects()
                expression.terms = [term]
                
            }
            
        case .combineLikeFractions:
            let fractions = Expression()
            let nonFractions = Expression(terms: summedTerms)
            var i = nonFractions.terms.count - 1
            while i >= 0 {
                
                if let den = try nonFractions.terms[i].getDenominator() {
                    
                    var match = false
                    for j in 0..<fractions.terms.count {
                        
                        let den2 = try fractions.terms[j].getDenominator()!.getReciprocal()
                        let product = try den.multiply(term: den2)
                        if let multiplier = (try? product.objects.first?.evaluate()), multiplier != nil, product.objects.count == 1 {
                            
                            let numerator = try Expression(terms: [nonFractions.terms[i].getNumerator().multiply(term: Term(objects: [Object(base: multiplier!)])), fractions.terms[j].getNumerator()]).simplify(system: system)
                            
                            fractions.terms[j] = try Term(objects: [Object(base: numerator)] + den2.getReciprocal().objects)
                            
                            match = true
                            break
                            
                        }
                        
                    }
                    if !match { fractions.terms.append(nonFractions.terms[i]) }
                    nonFractions.terms.remove(at: i)
                    
                }
                i -= 1
                
            }
            
            expression.terms = nonFractions.terms + fractions.terms
            
            
        case .neverCombineFractions:
            break
            
        }
        
        return expression
        
    }
    
    public override func factor(system: System? = nil) throws -> Term {
        
        let term = Term()
        
        //factor each term
        var expression = self.copy()
        for i in 0..<expression.terms.count {
            
            expression.terms[i] = try expression.terms[i].factor(system: system)
            
        }
        
        //take out all denominators
        let reciprocal = Term()
        for t in expression.terms {
            
            let objects = try t.getDenominator()?.objects ?? []
            term.objects += objects
            for o in objects {
                
                let reciprocalO = o.copy()
                reciprocalO.exponent = try reciprocalO.exponent.evaluate() * Number.negativeOne
                reciprocal.objects.append(reciprocalO)
                
            }
            
        }
        expression = try expression.multiply(byTerm: reciprocal)
        
        //take out gcf of all terms
        var gcf: Term? = nil
        for t in expression.terms {
            
            if let g = gcf { gcf = try g.gcf(with: t) }
            else { gcf = t.copy() }
            
        }
        
        if let gcf = gcf, (gcf.objects.first?.base ?? Number.zero) != Number.zero {
            
            term.objects += gcf.objects
            expression = try expression.multiply(byTerm: gcf.getReciprocal())
            
        }
        
        //expand
        expression = try expression.simplify(system: system)
        
        //other stuff
        var factors = [expression]
        var i = 0
        while i < factors.count {
            
            if let f = try factors[i].getFactor(), let quotient = try factors[i].divide(byExpression: f) {
                
                factors[i] = quotient
                factors.append(try f.simplify(system: system))
                i = 0
                
            } else { i += 1 }
            
        }
        
        //add remaining expressions
        for f in factors {
            
            term.objects.append(Object(base: f.copy()))
            
        }
        
        return try term.combineObjects()
        
    }
 
    /**
     
    Gets a factor of `self`
     
    - Returns: a factor of `self`; `nil` if none can be found
     
    */
    private func getFactor() throws -> Expression? {
        
        if terms.count < 2 { return nil }
        
        if terms.count == 2 {
            
            if isDifferenceOfSquares {
                
                let termA3 = terms[0]
                let termB3 = terms[1]
                
                let termA = Term()
                let termB = Term()
                
                for o in termA3.objects {
                    
                    var newO = o.copy()
                    newO.exponent = try newO.exponent.evaluate() / Number(int: 2)
                    if var base = try? newO.base.evaluate() {
                        
                        let sign = (try? base > Number.zero ? Number.one : Number.negativeOne) ?? Number.one
                        base = base * sign
                        
                        newO = try Object(base: sign * (base ^ (Number.one / Number(int: 2))))
                        
                    }
                    termA.objects.append(newO)
                    
                }
                for o in termB3.objects {
                    
                    var newO = o.copy()
                    newO.exponent = try newO.exponent.evaluate() / Number(int: 2)
                    if var base = try? newO.base.evaluate() {
                        
                        let sign = (try? base > Number.zero ? Number.one : Number.negativeOne) ?? Number.one
                        base = base * sign
                        
                        newO = try Object(base: sign * (base ^ (Number.one / Number(int: 2))))
                        
                    }
                    termB.objects.append(newO)
                    
                }
                
                let expression = Expression()
                expression.terms = [termA, termB]
                
                return expression
                
            } else if isSumOrDifferenceOfCubes {
                
                let termA3 = terms[0]
                let termB3 = terms[1]
                
                let termA = Term()
                let termB = Term()
                
                for o in termA3.objects {
                    
                    var newO = o.copy()
                    newO.exponent = try newO.exponent.evaluate() / Number(int: 3)
                    if var base = try? newO.base.evaluate() {
                        
                        let sign = (try? base > Number.zero ? Number.one : Number.negativeOne) ?? Number.one
                        base = base * sign
                        
                        newO = try Object(base: sign * (base ^ (Number.one / Number(int: 3))))
                        
                    }
                    termA.objects.append(newO)
                    
                }
                for o in termB3.objects {
                    
                    var newO = o.copy()
                    newO.exponent = try newO.exponent.evaluate() / Number(int: 3)
                    if var base = try? newO.base.evaluate() {
                        
                        let sign = (try? base > Number.zero ? Number.one : Number.negativeOne) ?? Number.one
                        base = base * sign
                        
                        newO = try Object(base: sign * (base ^ (Number.one / Number(int: 3))))
                        
                    }
                    termB.objects.append(newO)
                    
                }
                
                let expression = Expression()
                expression.terms = [termA, termB]
                
                return expression
                
            }
            
        } else if isQuadraticPattern {
            
            let a = terms[0].extractNumbers().0
            let (b, x) = terms[1].extractNumbers()
            let c = terms[2].extractNumbers().0
            
            if a.asInteger == nil || b.asInteger == nil || c.asInteger == nil { return nil }
            
            let discriminant = try ((b ^ Number(int: 2)) - (Number(int: 4) * a * c)) ^ Number(double: 0.5)
            if discriminant.asInteger == nil { return nil }
            
            //e/d
            var zeroNumerator = -b + discriminant
            var zeroDenominator = (Number(int: 2) * a)
            
            let gcf = zeroNumerator.gcf(with: zeroDenominator)
            
            zeroNumerator /= gcf
            zeroDenominator /= gcf
            
            //(dx + e)
            let dx = Term(objects: [Object(base: zeroDenominator)] + x.objects)
            let e = Term(objects: [Object(base: zeroNumerator * Number.negativeOne)])
            
            let expression = Expression()
            expression.terms = [dx, e]
            
            return expression
            
        } else {
            
            //try (a+b)^n
            let n = terms.count - 1
            let a = terms[0].copy()
            let b = terms[n].copy()
            
            let quantity = Expression()
            quantity.terms = [a, b]
            let t = Term(objects: [Object(base: quantity, exponent: Number(int: n))])
            if try t.expand() == self { return quantity }
            
            //try grouping
            let expression = Expression(terms: [terms[0]])
            var gcf = terms[0]
            for i in 1...(terms.count / 2) {
                
                expression.terms.append(terms[i])
                gcf = try gcf.gcf(with: terms[i])
                if terms.count % (i + 1) == 0 {
                    
                    var allMatch = true
                    let factor = try expression.multiply(byTerm: gcf.getReciprocal())
                    for startI in 1..<(terms.count / (i + 1)) {
                        
                        let group = Expression()
                        for t in 0...i {
                            
                            group.terms.append(terms[startI * (i + 1) + t])
                            
                        }
                        if group.compare(toExpression: factor) == nil { allMatch = false; break }
                        
                    }
                    if allMatch { return factor }
                    
                }
                
            }
            
        }
        
        return nil
        
    }
    
    /**
 
    Solves `self` for given `Variable` if `self` is a binomial or a quadratic pattern
     
    - Parameter variable: `Variable` being solved for
    - Returns: solutions for `variable`
    - Predondition: `self` is simplified
     
    */
    internal func solveFactor(forVariable variable: Variable) throws -> [Value] {
        
        var solutions = [Value]()
        
        //sort terms by degree of variable
        var termsSorted = [Number:[Term]]()
        for t in terms {
            
            let (exponent, term) = try t.extract(variable: variable)
            termsSorted[exponent] = (termsSorted[exponent] ?? []) + [term]
            
        }
        
        if termsSorted.count == 2 {
            
            let degrees = Array(termsSorted.keys)
            
            let d1: Number
            var terms1 = [Term]()
            var terms2 = [Term]()
            
            if degrees[0] == Number.zero {
                
                d1 = degrees[1]
                terms1 = termsSorted[degrees[1]]!
                terms2 = termsSorted[degrees[0]]!
                
            } else {
                
                d1 = degrees[0]
                terms1 = termsSorted[degrees[0]]!
                terms2 = termsSorted[degrees[1]]!
                
            }
            
            for i in 0..<terms1.count { terms1[i] = try terms1[i].extract(variable: variable).1 }
            for i in 0..<terms2.count { terms2[i] = try terms2[i].extract(variable: variable).1 }
            
            // terms1(x)^(d1) + terms2 = 0; x = (-terms2/terms1)^(1/d1)
            
            let object1 = Object(base: Expression(terms: terms2))
            let object2 = Object(base: Expression(terms: terms1), exponent: Number.negativeOne)
            
            let q = Term(objects: [object1, object2])
            q.objects.append(Object(base: Number.negativeOne))
            if let simplified = try q.factor(system: nil).simplify() {
                
                for o in simplified.objects {
                    
                    o.exponent = try o.exponent.evaluate() / d1
                    
                }
                
                try solutions.append(simplified.expand().simplify())
                
                if d1.approximateRational!.0 % 2 == 0 {
                    
                    simplified.objects.append(Object(base: Number.negativeOne))
                    try solutions.append(simplified.expand().simplify())
                    
                }
                
            } else { solutions.append(Number.zero) }
            
        } else if termsSorted.count == 3 {
            
            var a = Expression()
            var b = Expression()
            var c = Expression()
            
            var n = Number.zero
            
            for (exponent, terms) in termsSorted {
                
                if exponent == Number.zero {
                    
                    c = Expression(terms: terms)
                    
                } else {
                    
                    if n == Number.zero {
                        
                        n = exponent.copy() as! Number
                        b = Expression(terms: terms)
                        
                    } else if n * Number(int: 2) == exponent {
                        
                        a = Expression(terms: terms)
                        
                    } else if exponent * Number(int: 2) == n {
                        
                        a = b
                        b = Expression(terms: terms)
                        
                    } else { return solutions }
                    
                }
                
            }
            
            let negB = try Expression().subtract(expression: b)
            let twoA = try a.multiply(byTerm: Term(objects: [Object(base: Number(int: 2))]))
            let discriminant = try b.multiply(byExpression: b).subtract(expression: a.multiply(byExpression: c).multiply(byTerm: Term(objects: [Object(base: Number(int: 4))])))
            
            for sign in [-1, 1] {
                
                let discriminantTerm = Term(objects: [Object(base: Number(int: sign)), Object(base: discriminant, exponent: Number(double: 0.5))])
                let numerator = Expression(terms: negB.terms + [discriminantTerm])
                let solution = Expression(terms: [Term(objects: [Object(base: numerator), Object(base: twoA, exponent: Number.negativeOne)])])
                
                if let (num, _) = n.approximateRational {
                
                    let obj = Object(base: solution, exponent: Number.one / n)
                    let sol = try obj.expand()?.simplify() ?? Expression(terms: [Term(objects: [obj])])
                    
                    try solutions.append(sol.simplify())
                    
                    if num % 2 == 0 {
                        
                        try solutions.append(sol.multiply(byTerm: Term(objects: [Object(base: Number.negativeOne)])).simplify())
                        
                    }
                    
                }
                
            }
            
        }
        
        return solutions

    }
    
    /**
 
    Orders terms
     
    - Returns: an ordered version of `self`
     
    */
    internal func order() -> Expression {
        
        let compare = { (term1: Term, term2: Term) -> Bool in
            
            var variables1 = [Object]()
            for o in term1.objects {
                
                if o.base is VariableValue { variables1.append(o) }
                
            }
            variables1.sort { ($0.base as! VariableValue).variable.identifier < ($1.base as! VariableValue).variable.identifier }
            
            var variables2 = [Object]()
            for o in term2.objects {
                
                if o.base is VariableValue { variables2.append(o) }
                
            }
            variables2.sort { ($0.base as! VariableValue).variable.identifier < ($1.base as! VariableValue).variable.identifier }
            
            var i = 0
            while i < variables1.count && i < variables2.count {
                
                if (variables1[i].base as! VariableValue).variable.identifier < (variables2[i].base as! VariableValue).variable.identifier {
                    
                    return true
                    
                } else if (variables1[i].base as! VariableValue).variable.identifier > (variables2[i].base as! VariableValue).variable.identifier {
                    
                    return false
                    
                } else if let num1 = try? variables1[i].exponent.evaluate(), let num2 = try? variables2[i].exponent.evaluate() {
                    
                    if (try? num1 > num2) ?? true { return true }
                    else if try! num1 < num2 { return false }
                    
                }
                
                i += 1
                
            }
            
            return variables1.count > variables2.count
            
        }
        
        let expression = self.copy()
        expression.terms.sort(by: compare)
        
        return expression
        
    }
    
    /**
 
    Adds `self` to another `Expression`
     
    - Parameter expression: `Expression` being added to `self`
    - Returns: `self` + `expression` simplified
     
    */
    public func add(expression: Expression, system: System? = nil) throws -> Expression {
        
        let sum = self.copy()
        
        for t in expression.terms {
            
            sum.terms.append(t.copy())
            
        }
        
        return try sum.simplify(system: system)
        
    }
    
    /**
     
    Subtracts another `Expression` from `self`
     
    - Parameter expression: `Expression` being subtracted from `self`
    - Returns: `self` - `expression` simplified
     
    */
    public func subtract(expression: Expression, system: System? = nil) throws -> Expression {
        
        return try self.add(expression: expression.getNegated(), system: system)
        
    }
    
    /**
 
    Multiplies `self` with another `Expression`
     
    - Parameter expression: the `Expression` being multiplied with `self`
    - Returns: the product of `self` and `expression`
     
    */
    public func multiply(byExpression expression: Expression) throws -> Expression {
        
        let product = Expression()
        
        for t1 in expression.terms {
            
            for t2 in self.terms {
                
                try product.terms.append(t1.multiply(term: t2))
                
            }
            
        }
        
        return try product.combineLikeTerms()
        
    }
    
    /**
     
    Multiplies `self` by a `Term`
     
    - Parameter term: the `Term` being multiplied with `self`
    - Returns: the product of `self` and `term`
     
    */
    public func multiply(byTerm term: Term) throws -> Expression {
        
        let product = Expression()
        
        for t1 in self.terms {
            
            try product.terms.append(t1.multiply(term: term))
            
        }
        
        return product
        
    }
    
    /**
 
    Divides `self` by another `Expression`
     
    - Parameter expression: the `Expression` dividing `self`
    - Returns: the quotient; `nil` if there is a remainder
    - Precondition: `self` and `expression` are polynomials
     
    */
    public func divide(byExpression expression: Expression) throws -> Expression? {
        
        var remainder = self.order()
        let divisor = expression.order()
        let quotient = Expression()
        
        if divisor.terms.count == 0 { throw CalculationError.divideByZero }
        
        while remainder.terms.count != 0 && remainder.terms[0].extractNumbers().0 != Number.zero {
            
            let quotientTerm = try remainder.terms[0].divide(term: divisor.terms[0])
            if try quotientTerm.getDenominator() != nil { return nil }
            let product = try divisor.multiply(byTerm: quotientTerm)
            
            quotient.terms.append(quotientTerm)
            
            remainder = try remainder.subtract(expression: product)

        }
        
        return try quotient.simplify()
        
    }
    
    public override func equals(_ value: Value) -> Bool {
        
        if !(value is Expression) { return false }
        if !super.equals(value) { return false }
        
        var remainingTerms = copy().terms
        
        for t in (value as! Expression).terms {
            
            var match = false
            for i in 0..<remainingTerms.count {
                
                if t == remainingTerms[i] {
                
                    remainingTerms.remove(at: i)
                    match = true
                    break
                
                }
                
            }
            if !match { return false }
            
        }
        
        return remainingTerms.count == 0
        
    }
    
    public override func copy() -> Expression {
        
        let expression = Expression()
        
        for t in self.terms { expression.terms.append(t.copy()) }
        
        return expression
        
    }
    
    public override func evaluate() throws -> Number {
        
        var sum = Number.zero
        for t in terms {
            
            sum += try t.evaluate()
            
        }
        
        return sum
        
    }
    
    public override func plugIn(value: Value, forVariable variable: Variable) throws -> Value {
        
        let expression = Expression()
        for t in terms {
            
            let plugged = try t.plugIn(value: value, forVariable: variable)
            
            if let pluggedT = plugged as? Term {
                
                expression.terms.append(pluggedT)
                
            } else {
                
                let term = Term(objects: [Object(base: plugged)])
                expression.terms.append(term)
                
            }
            
        }
        
        return expression
        
    }
    
    /**
 
    Compares `self` to another `Expression`
     
    - Parameter expression: the `Expression` that `self` is compared to
    - Returns: if `self` and `expression` are different only by a numerical factor, `self`/`expression`; otherwise, nil
    - Precondition: `self` and `expression` are simplified
     
    */
    internal func compare(toExpression expression: Expression) -> Number? {
        
        var remainingTerms = copy().terms
        
        var num: Number? = nil
        for t in expression.terms {
            
            var match = false
            for i in 0..<remainingTerms.count {
                
                let quotient = try? remainingTerms[i].divide(term: t)
                if let numQuotient = try? quotient?.evaluate() {
                    
                    if numQuotient == num || num == nil {
                        
                        remainingTerms.remove(at: i)
                        num = numQuotient
                        match = true
                        break
                        
                    }
                    
                }
                
            }
            if !match { return nil }
            
        }
        
        return remainingTerms.count == 0 ? num : nil
        
    }
    
    /**
 
    Multiplies `self` by -1
     
    - Returns: `self` * -1
     
    */
    internal func getNegated() -> Expression {
        
        let negated = self.copy()
        
        for i in 0..<negated.terms.count {
            
            negated.terms[i] = try! negated.terms[i].multiply(term: Term(objects: [Object(base: Number.negativeOne)]))
            
        }
        
        return negated
        
    }
    
    public override func getVariables() -> [Variable] {
        
        var arr = [Variable]()
        
        for t in terms {
            
            for v in t.getVariables() {
                
                var match = false
                for a in arr {
                    
                    if v == a { match = true; break }
                    
                }
                if !match { arr.append(v) }
                
            }
            
        }
        
        var copied = [Variable]()
        for v in arr { copied.append(v.copy()) }
        
        return copied
        
    }
    
    public override func derivative(inTermsOf variable: Variable, system: System) throws -> Value {
        
        var terms = [Term]()
        
        for term in self.terms {
            
            try terms.append(Term(objects: [Object(base: term.derivative(inTermsOf: variable, system: system))]))
            
        }
        
        return Expression(terms: terms)
        
    }
    
    //MARK: CustomStringConvertible
    
    public override var description: String {
        
        var str = ""
        
        var first = true
        for t in terms {
            
            let copy = t.copy()
            var negative = false
            for o in copy.objects {
                
                if o.exponent == Number.one && ((try? ((o.base as? Number) ?? Number.one) < Number.zero) ?? false) {
                    
                    o.base = (o.base as! Number) * Number.negativeOne
                    negative = true
                    
                }
                
            }
            
            if !first { str += negative ? " - " : " + " }
            else { str += negative ? "-" : ""; first = false }
            
            str += copy.description
            
        }
        
        return str
        
    }
    
}
