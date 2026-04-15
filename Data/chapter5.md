# SwiftUI vs UIKit Showdown + How to Use Both Together

We've trained with the classic master builder, UIKit, and we've learned the new magic spells of SwiftUI. Now, it's time for the ultimate showdown! When should you use which? And more importantly, what happens when you need them to team up?

## The Showdown: When to Choose Which Hero

Choosing between SwiftUI and UIKit is like choosing the right hero for a specific mission. Both are incredibly powerful, but they have different strengths.

### Choose SwiftUI (The Magic Wizard) When:

- **Starting a New App** — If you are building a brand new app today, SwiftUI is almost always the right choice. It's the future of Apple platforms, and it will make your development faster and more enjoyable.
- **Building Standard UIs** — For most common app interfaces (lists, forms, settings screens, standard navigation), SwiftUI is significantly faster to write and easier to maintain.
- **You Want Less Code** — SwiftUI's declarative nature means you write less code to achieve the same results, which means fewer bugs and easier reading.
- **You Love Live Previews** — The Xcode Canvas and live previews are a game-changer for rapid UI iteration.
- **Targeting Multiple Apple Platforms** — SwiftUI makes it much easier to share UI code across iOS, macOS, watchOS, and tvOS.

### Choose UIKit (The Master Builder) When:

- **Maintaining an Older App** — If you are working on an app that was built years ago, it's likely entirely UIKit. You'll need to know UIKit to maintain and add features to it.
- **You Need Extreme Customization** — While SwiftUI is getting better every year, UIKit still offers more granular control over every single pixel and complex animation if you need something highly unconventional.
- **Using Older Third-Party Libraries** — Some older, but essential, third-party libraries might only provide UIKit components.
- **You Need Specific Missing Features** — There are still a few very specific, advanced features (like certain complex text layouts or highly customized collection view layouts) that are easier or only possible in UIKit.

### The Verdict: A Dynamic Duo

The truth is, you don't always have to choose just one! The best iOS developers know how to use both and, more importantly, how to make them work together. Apple designed them to be interoperable.

## Teaming Up: Using UIKit in SwiftUI

Imagine you are building a beautiful new SwiftUI app, but you need a very specific, complex map view that you already built perfectly in UIKit, or you need to use a third-party UIKit component. You can wrap that UIKit view and use it right inside your SwiftUI code!

We do this using the `UIViewRepresentable` protocol. It acts as a translator, turning a UIKit `UIView` into a SwiftUI `View`.

### UIViewRepresentable: The Translator

Let's say we want to use a standard UIKit `UIActivityIndicatorView` (the classic spinning loading wheel) inside our SwiftUI app.

```swift
import SwiftUI
import UIKit

// 1. Create a struct that conforms to UIViewRepresentable
struct ClassicSpinner: UIViewRepresentable {
    let isAnimating: Bool

    // 2. Create the UIKit view
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .systemBlue
        return spinner
    }

    // 3. Update the UIKit view when SwiftUI state changes
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

// Now we can use it in SwiftUI!
struct MissionLoadingView: View {
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            // Use our wrapped UIKit view just like any other SwiftUI view
            ClassicSpinner(isAnimating: isLoading)

            Button(isLoading ? "Stop Loading" : "Start Loading") {
                isLoading.toggle()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
```

**How it works:**
- `makeUIView` — This is called exactly once when SwiftUI needs to create the view. You instantiate and configure your UIKit view here.
- `updateUIView` — This is called whenever the SwiftUI state (like `isAnimating`) changes. You use this to update the properties of your UIKit view to match the new state.

## Teaming Up: Using SwiftUI in UIKit

Now, imagine the opposite scenario. You have a massive, older UIKit app, and you want to start adding new features using the magic of SwiftUI. You can embed a SwiftUI view inside a UIKit view controller!

We do this using a special view controller called `UIHostingController`. It acts as a container that holds your SwiftUI view and presents it to the UIKit world.

### UIHostingController: The Container

```swift
import UIKit
import SwiftUI

// 1. Our shiny new SwiftUI View
struct HeroProfileCard: View {
    let name: String
    let power: String

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            Text(name)
                .font(.largeTitle)
                .bold()
            Text("Power: \(power)")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// 2. Our classic UIKit View Controller
class OldHQViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let showProfileButton = UIButton(type: .system)
        showProfileButton.setTitle("Show Hero Profile (SwiftUI)", for: .normal)
        showProfileButton.titleLabel?.font = .systemFont(ofSize: 20)
        showProfileButton.addTarget(self, action: #selector(showProfileTapped), for: .touchUpInside)

        showProfileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showProfileButton)

        NSLayoutConstraint.activate([
            showProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showProfileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func showProfileTapped() {
        // 3. Create the SwiftUI view
        let swiftUIView = HeroProfileCard(name: "Captain Swift", power: "Declarative Magic")

        // 4. Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)

        // 5. Present it just like any other UIKit view controller!
        present(hostingController, animated: true)
    }
}
```

**How it works:**
- You create your SwiftUI view (`HeroProfileCard`)
- You instantiate a `UIHostingController`, passing your SwiftUI view as its `rootView`
- You can then present, push, or embed this `UIHostingController` just like you would any standard `UIViewController` in your UIKit app

> 🦸 **Superhero Tip: The Best of Both Worlds!**
> Don't be afraid to mix and match! If you are struggling to build a complex layout in UIKit, see if you can build that specific component in SwiftUI and embed it. If you need a highly specialized UIKit control in your new SwiftUI app, wrap it! Knowing how to bridge these two worlds makes you an incredibly versatile iOS developer.

> ⚡ **Mini Challenge: The Ultimate Crossover!**
> Create a simple SwiftUI view that contains a Text view and a Button. When the button is tapped, it should change the text. Now, create a UIKit UIViewController and use a UIHostingController to display your SwiftUI view inside it.

---

This concludes our showdown! You now know the strengths of both UIKit and SwiftUI and how to make them work together as a dynamic duo. Next, we'll look at how to organize our code so our superhero headquarters doesn't become a messy disaster!
