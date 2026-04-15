# Swift Basics: Your Superpower Foundation

Every superhero needs a strong foundation, and for iOS developers, that foundation is the Swift programming language! Swift is like the special energy that powers all your amazing apps. Let's learn some of its core components, which are like the basic moves in your superhero training.

## Variables and Constants: Your Ever-Ready Utility Belt

Imagine your superhero utility belt. Some pouches hold gadgets you might swap out often, while others hold essential items that never change. In Swift, we have variables and constants for just this purpose.

### Variables (var): The Changing Gadgets

A variable is like a pouch in your utility belt that can hold different gadgets. You can put a grappling hook in it, then later swap it for a smoke bomb. Its value can change!

```swift
var heroName = "Captain Swift"
print(heroName) // Output: Captain Swift

heroName = "The Code Crusader" // You can change the value!
print(heroName) // Output: The Code Crusader
```

**Why var?** You use `var` when you know a piece of information might need to change during your app's adventure. For example, a player's score in a game, or a user's selected theme.

### Constants (let): The Unchanging Origin Story

A constant is like your superhero's origin story — once it's set, it never changes! It's a value that stays the same throughout your app's journey.

```swift
let secretIdentity = "Manus AI"
print(secretIdentity) // Output: Manus AI

// secretIdentity = "Another Name" // ERROR! You can't change a constant!
```

**Why let?** Use `let` for values that should never change. This makes your code safer and easier to understand, as you know this value is fixed. Examples include the maximum number of lives in a game or a fixed API key.

> 🦸 **Superhero Tip: Choose Wisely!**
> Always try to use `let` first. If Swift tells you that you need to change the value, then switch to `var`. This is a good habit that makes your code more robust!

## Data Types: The Different Kinds of Power

Just like there are different kinds of superpowers (super strength, super speed, flight), Swift has different data types to store different kinds of information.

- **String** — For text, like a hero's catchphrase or a secret message. Always enclosed in double quotes.
- **Int** — For whole numbers, like the number of villains defeated or a hero's age.
- **Double** — For numbers with decimal points, like a hero's flight speed (e.g., 3.14 miles per second).
- **Bool** — For true/false values, like whether a hero is flying (true) or not (false).

```swift
let catchphrase = "To infinity and beyond!"
let villainsDefeated = 10
let flightSpeed = 3.14
var isFlying = true
```

Swift is very smart and can often figure out the type of data you're using, but sometimes you might need to be specific. This is called **Type Inference**.

## Optionals: The Mystery Box

Imagine you open a mystery box. It might contain a super-gadget, or it might be empty! In Swift, an Optional is like that mystery box. It's a type that can either hold a value or hold nothing (which we call `nil`). We use a question mark `?` after a type to make it optional.

```swift
var superGadget: String? = "Invisibility Cloak" // It might have a gadget
print(superGadget) // Output: Optional("Invisibility Cloak")

superGadget = nil // Oh no, the box is empty!
print(superGadget) // Output: nil
```

**Why Optionals?** They help prevent crashes in your app! If you try to use a gadget that isn't there, your app would get confused and stop working. Optionals force you to check if there's a value before you use it.

### Unwrapping Optionals: Safely Opening the Box

**1. Optional Binding (if let)** — The safest way. It's like saying, "If there's a gadget in the box, then let's take it out and use it!"

```swift
var secretWeapon: String? = "Laser Blaster"

if let weapon = secretWeapon {
    print("Our hero is equipped with a \(weapon)!") // Output: Our hero is equipped with a Laser Blaster!
} else {
    print("No weapon found, time for hand-to-hand combat!")
}

secretWeapon = nil

if let weapon = secretWeapon {
    print("Our hero is equipped with a \(weapon)!")
} else {
    print("No weapon found, time for hand-to-hand combat!") // Output: No weapon found, time for hand-to-hand combat!
}
```

**2. Guard Let** — Like a security guard checking your ID at the entrance to the superhero HQ. If you don't have it, you can't come in!

```swift
func activateSuperPower(gadget: String?) {
    guard let activatedGadget = gadget else {
        print("Superpower activation failed: No gadget provided!")
        return // Stop the function here if no gadget
    }
    print("Superpower activated using \(activatedGadget)!")
}

activateSuperPower(gadget: "Flight Boots") // Output: Superpower activated using Flight Boots!
activateSuperPower(gadget: nil) // Output: Superpower activation failed: No gadget provided!
```

**3. Nil-Coalescing Operator (??)** — "Give me the gadget if there is one, otherwise give me this default gadget!" It provides a fallback value.

```swift
let backupGadget = "Smoke Bomb"
let equippedGadget = superGadget ?? backupGadget
print("Hero is ready with: \(equippedGadget)") // If superGadget is nil, it will be "Smoke Bomb"
```

> ⚡ **Mini Challenge: Optional Adventure!**
> Imagine you have an optional Int called superHeroLevel. Write code using if let to print "Your hero is level X!" if it has a value, or "Your hero needs more training!" if it's nil.

## Functions: Your Super Moves

Every superhero has special moves they can perform. In programming, these special moves are called functions. A function is a block of code that performs a specific task. You can call it whenever you need that task done, saving you from writing the same code over and over again.

```swift
func performSuperPunch() {
    print("POW! Super Punch delivered!")
}

performSuperPunch() // Call the function to use the super move!
performSuperPunch() // You can use it again and again!
```

### Parameters: Giving Your Moves More Power

Sometimes, your super move needs a little extra information to work. These extra pieces of information are called parameters.

```swift
func flyToLocation(destination: String, speed: Double) {
    print("Flying to \(destination) at a super speed of \(speed) mph!")
}

flyToLocation(destination: "Metropolis", speed: 1000.0)
flyToLocation(destination: "Gotham City", speed: 500.0)
```

### Return Values: What Your Move Gives Back

Some super moves don't just do something; they also give you something back. This is called a return value.

```swift
func scanForVillain(area: String) -> String {
    print("Scanning \(area) for villains...")
    // Imagine complex scanning logic here
    return "Dr. Doom found in the abandoned warehouse!"
}

let villainLocation = scanForVillain(area: "Downtown")
print(villainLocation)
// Output:
// Scanning Downtown for villains...
// Dr. Doom found in the abandoned warehouse!
```

The `-> String` part tells Swift that this function will return a `String` value.

## Closures: Power Scrolls for Later Use

Imagine you have a special "Power Scroll" that contains instructions for a super move, but you don't want to use it right now. You want to give it to another hero, or save it for a specific moment. In Swift, these Power Scrolls are called closures.

A closure is a block of code that can be passed around and executed later. They are very powerful and you'll see them everywhere in SwiftUI!

```swift
let activateShield = { (strength: Int) in
    print("Shield activated with strength level \(strength)!")
}

activateShield(10) // Output: Shield activated with strength level 10!
```

The `in` keyword separates the parameters and return type from the body of the closure. Closures are often used for things like handling button taps, responding to network requests, or performing animations.

> ⚡ **Mini Challenge: Closure Command!**
> Create a closure that takes a String (a villain's name) and prints "Defeated [Villain Name]!" Then, call your closure with a villain's name.

## Structs vs. Classes: Hero Trading Cards vs. Hero Headquarters

In Swift, structs and classes are both ways to create your own custom data types. They are like blueprints for creating objects, but they have a fundamental difference in how they handle copies.

### Structs: Hero Trading Cards (Value Types)

Think of a struct like a superhero trading card. When you give a friend a trading card, they get their own copy of that card. If they draw a mustache on their card, your original card remains untouched. Structs are **value types**.

```swift
struct HeroStats {
    var strength: Int
    var speed: Int
}

var captainSwiftStats = HeroStats(strength: 100, speed: 90)
var sidekickStats = captainSwiftStats // sidekickStats gets a COPY

sidekickStats.strength = 50 // Changing sidekickStats doesn't affect captainSwiftStats

print("Captain Swift Strength: \(captainSwiftStats.strength)") // Output: 100
print("Sidekick Strength: \(sidekickStats.strength)")            // Output: 50
```

**When to use structs:** Most of the time in SwiftUI, you'll be using structs! They are great for representing data that you want to copy and keep independent.

### Classes: Hero Headquarters (Reference Types)

Now, imagine a class as the superhero headquarters. If you tell a friend where the headquarters is, you're both referring to the same building. If your friend paints the door red, you'll also see a red door because you're looking at the same place. Classes are **reference types**.

```swift
class VillainLair {
    var location: String

    init(location: String) {
        self.location = location
    }
}

let originalLair = VillainLair(location: "Hidden Volcano")
let secretAgentReport = originalLair // secretAgentReport refers to the SAME lair

secretAgentReport.location = "Abandoned Warehouse" // Changing secretAgentReport affects originalLair

print("Original Lair Location: \(originalLair.location)") // Output: Abandoned Warehouse
print("Secret Agent Report Location: \(secretAgentReport.location)") // Output: Abandoned Warehouse
```

> 🦸 **Superhero Tip: Structs are Your Friends!**
> In SwiftUI, structs are generally preferred because they make it easier to reason about your code and how data changes. When you pass a struct around, you know you're working with a fresh copy, which helps prevent unexpected side effects.

## Protocols: The Superhero Code of Conduct

A protocol in Swift is like a superhero code of conduct or a set of rules that a hero must follow. It defines a blueprint of methods, properties, and other requirements that a class, struct, or enum can adopt.

```swift
protocol Flyable {
    var flightSpeed: Double { get set } // A property that can be read and set
    func fly() // A method that must be implemented
}

struct IronHero: Flyable {
    var flightSpeed: Double = 1500.0

    func fly() {
        print("IronHero is flying at \(flightSpeed) mph!")
    }
}

let ironHero = IronHero()
ironHero.fly() // Output: IronHero is flying at 1500.0 mph!
```

**Why Protocols?** Protocols are incredibly powerful for creating flexible and modular code. They allow you to define common behaviors that different types can share, without worrying about their specific implementation details. This is a cornerstone of SwiftUI development.

## Extensions: Giving Heroes New Powers

Sometimes, a hero might need a new power or ability that they didn't originally have. In Swift, extensions allow you to add new functionality to an existing class, struct, enum, or protocol, even if you don't have access to the original source code.

```swift
extension String {
    func shout() -> String {
        return self.uppercased() + "!!!"
    }
}

let message = "Beware, villains!"
print(message.shout()) // Output: BEWARE, VILLAINS!!!
```

**Why Extensions?** Extensions are great for organizing your code, making it more readable, and adding utility methods to types without modifying their original definition. They are used extensively in SwiftUI to add convenient modifiers to views.

## Error Handling: When Things Go Wrong

Even the best superheroes encounter unexpected problems. In programming, these problems are called errors. Swift has a robust system for error handling that allows your app to gracefully respond to and recover from these issues, instead of crashing.

```swift
enum GadgetError: Error {
    case outOfPower
    case jammed
    case brokenWire
}

func activateGadget(powerLevel: Int) throws -> String {
    if powerLevel < 10 {
        throw GadgetError.outOfPower
    }
    // Imagine more complex logic that might throw other errors
    return "Gadget activated successfully!"
}

// We use do-catch blocks, like preparing for a mission with potential dangers
do {
    let result = try activateGadget(powerLevel: 5) // This will throw an error!
    print(result)
} catch GadgetError.outOfPower {
    print("Mission failed: Gadget is out of power! Recharge it!")
} catch {
    print("An unknown gadget error occurred: \(error)")
}

do {
    let result = try activateGadget(powerLevel: 20)
    print(result) // Output: Gadget activated successfully!
} catch {
    print("An error occurred: \(error)")
}
```

**Why Error Handling?** It makes your apps more reliable and user-friendly. Instead of just stopping, your app can tell the user what went wrong and suggest a solution.

## Async/Await: Coordinating Super-Tasks

Superheroes often have to perform multiple tasks at once, or wait for a long task to finish before moving on. In Swift, asynchronous programming with `async` and `await` helps us manage tasks that take time without freezing our app.

```swift
func fetchMissionData() async throws -> String {
    print("Fetching mission data... (this takes time!)")
    // Simulate a network request that takes 2 seconds
    try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
    print("Mission data fetched!")
    return "Top Secret Mission Briefing: Locate the Cosmic Cube!"
}

// To call an async function, use Task to create a new asynchronous context
Task {
    do {
        let data = try await fetchMissionData()
        print(data)
    } catch {
        print("Failed to fetch mission data: \(error)")
    }
}
// Output (after a 2-second delay):
// Fetching mission data... (this takes time!)
// Mission data fetched!
// Top Secret Mission Briefing: Locate the Cosmic Cube!
```

- **async** — Marks a function as being able to perform asynchronous work.
- **await** — Pauses the execution of the current async function until the awaited task is complete, allowing other tasks to run in the meantime.

**Why Async/Await?** It makes your app feel smooth and responsive. Users don't like waiting for apps to load data or perform complex calculations. `async/await` allows your app to stay interactive while background tasks are being completed.

> ⚡ **Mini Challenge: Async Adventure!**
> Create an async function called chargeSuperSuit() that prints "Charging suit…" waits for 3 seconds, and then prints "Super Suit 100% charged!" Call this function using a Task.

---

This concludes your basic training in Swift! You've learned the fundamental building blocks that will empower you to create incredible iOS applications. Next, we'll dive into the world of UIKit, our classic hero for building interfaces.
