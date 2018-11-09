# MathKit

> _MathKit is a Swift library for manipulating, solving, and graphing mathematic equations, expressions, and functions._



## Features



- [x] Simplifies expressions

- [x] Factors expressions

- [x] Solves equations

- [x] Analytically finds derivitives of functions

- [x] Graphs functions



## Installation
#### Swift Package Manager
Add `MathKit` as a dependency in your `Package.swift` file:
```swift
dependencies: [
.package(url: "https://github.com/liam923/MathKit.git", from: "1.0.1")
]
```
#### Manually
Simply download and drop ```Sources/MathKit``` into your project.
## Usage Example
Before we do anything, we have to import `MathKit` and set up a `System`:
```swift
import MathKit

let system = System()
```
#### Simplify or Factor an Expression
```swift
let expression = try! Expression(string: "3(x + 3)^2 - 29 + 4(x + 2) - 13x", system: system)
try! print(expression.simplify(system: system)) //  3x^2 + 9x + 6
try! print(expression.factor(system: system)) //  3(x + 1)(x + 2)
```
#### Solve an Equation
```swift
let equation = try! Equation(string: "x^2 + 1 = 3 - x", system: system)
try! print(equation.solve(forVariable: system.variable(withSymbol: "x"))) // [1, -2]
```
#### Find Derivative
```swift
let function = try! Expression(string: "deriv(5x^3 + ln(x) + sin(x), x, x)", system: system)
try! print(function.simplify(system: system)) // 15(x)^(2) + (x)^(-1) + cos(x)
```
#### Graph Function
```swift
// create the function to graph
let f = system.function(withName: "f", variables: [system.variable(withSymbol: "x")])
f.value = try! Expression(string: "x + 1", system: system)
// create the graph itself
let graph = GraphScene(size: CGSize(width: 500, height: 500))
graph.functions.append((f, true, .red))
graph.update() // scene is now an SKView that displays the graph of f(x) = x + 1
```

## Meta
William Stevenson – liam923@verizon.net

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/liam923](https://github.com/liam923)
