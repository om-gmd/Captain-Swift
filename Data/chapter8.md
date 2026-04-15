# Connecting to the World: Networking Superpowers

Our superheroes can't save the world if they're stuck in their headquarters! To truly make an impact, they need to connect with the outside world, receive mission updates, send reports, and gather intelligence from remote databases. In app development, this means using networking superpowers to communicate with servers over the internet. This chapter will teach you how to give your apps the ability to connect to the world, fetch data, and handle all sorts of online interactions.

## URLSession: The Intergalactic Communicator

`URLSession` is Apple's powerful framework for handling network requests. It's like the intergalactic communicator that your superhero team uses to send and receive messages from distant planets (servers). Whether you're downloading an image, fetching JSON data, or uploading a file, `URLSession` is your primary tool.

### Making a Simple Data Task: Fetching a Mission Briefing

The most common way to fetch data is by creating a data task. This task retrieves the contents of a URL into memory.

```swift
import Foundation

func fetchMissionBriefing() {
    // 1. Create a URL for the mission briefing
    guard let url = URL(string: "https://api.example.com/mission/briefing") else {
        print("Error: Invalid URL")
        return
    }

    // 2. Create a URLSession (usually use the shared session for simple tasks)
    let session = URLSession.shared

    // 3. Create a data task
    let task = session.dataTask(with: url) { data, response, error in
        // This closure is called when the network request completes

        // 4. Handle any errors
        if let error = error {
            print("Network Error: \(error.localizedDescription)")
            return
        }

        // 5. Check the HTTP response status code
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Server Error: Invalid response or status code")
            return
        }

        // 6. Process the received data
        if let data = data {
            if let briefing = String(data: data, encoding: .utf8) {
                print("--- Mission Briefing Received ---")
                print(briefing)
            } else {
                print("Error: Could not decode data as text")
            }
        }
    }

    // 7. Start the task!
    task.resume()
}
```

**Explanation:**
- `URL(string:)` — Creates a URL object from a string. It's important to `guard let` it because the string might not be a valid URL.
- `URLSession.shared` — A convenient singleton session object for basic requests. For more complex needs (like background downloads), you'd create your own `URLSession` instance.
- `dataTask(with:completionHandler:)` — Creates a task that retrieves the contents of a URL and calls a completion handler when done. The handler provides `Data?`, `URLResponse?`, and `Error?`.
- Error Handling — Always check for `error` first. Then, cast `response` to `HTTPURLResponse` to check the `statusCode` (200-299 usually means success).
- `task.resume()` — This is crucial! Tasks are created in a suspended state; you must call `resume()` to start them.

> 🦸 **Superhero Tip: Always Handle Errors!**
> Network requests can fail for many reasons (no internet, server down, invalid URL). Always include robust error handling to make your app resilient and user-friendly.

## Async/Await for Networking: Streamlining Your Communications

In Chapter 2, we learned about `async/await` for managing asynchronous tasks. This pattern is incredibly useful for networking, as fetching data from a server is inherently an asynchronous operation. `URLSession` has modern async/await APIs that make network code much cleaner and easier to read.

```swift
import Foundation

// MARK: - Async/Await Networking Example

struct VillainProfile: Codable, Identifiable {
    let id: String
    let name: String
    let threatLevel: Int
    let lastSeenLocation: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case unknown
}

func fetchVillainProfiles() async throws -> [VillainProfile] {
    guard let url = URL(string: "https://api.example.com/villains") else {
        throw NetworkError.invalidURL
    }

    // Use the async/await version of data(from:)
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.invalidResponse
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode([VillainProfile].self, from: data)
    } catch {
        throw NetworkError.decodingError
    }
}

// How to call this async function:
Task {
    do {
        let profiles = try await fetchVillainProfiles()
        print("--- Villain Profiles Fetched ---")
        for villain in profiles {
            print("Name: \(villain.name), Threat Level: \(villain.threatLevel)")
        }
    } catch {
        print("Failed to fetch villain profiles: \(error)")
    }
}
```

**Key Advantages of async/await for Networking:**
- **Linear Code Flow** — Your code reads from top to bottom, making it much easier to follow compared to nested completion handlers
- **Error Propagation** — `throws` and `try` allow you to handle errors naturally using Swift's error handling system
- **Readability** — Less boilerplate, more focus on the actual logic

## Task: Launching Background Operations

When you need to call an `async` function from a non-async context (like a button tap in SwiftUI), you wrap the call in a `Task` block. This creates a new asynchronous context where your async code can run.

```swift
import SwiftUI

struct MissionControlView: View {
    @State private var statusMessage = "Ready for orders."

    var body: some View {
        VStack {
            Text(statusMessage)
                .font(.title2)
                .padding()

            Button("Download Top Secret Files") {
                Task {
                    statusMessage = "Downloading..."
                    do {
                        // Simulate a long download
                        try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                        statusMessage = "Files downloaded successfully!"
                    } catch {
                        statusMessage = "Download failed: \(error.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

## Actors: Protecting Shared Resources

Imagine multiple superheroes trying to access the same super-computer at the same time to update mission data. Without proper coordination, they might overwrite each other's changes, leading to chaos! In concurrent programming, this is known as a **data race**.

**Actors** are a feature in Swift (introduced in Swift 5.5) designed to safely manage shared mutable state in a concurrent environment. An actor ensures that only one task can access its mutable state at a time, preventing data races.

Think of an actor as a highly organized data vault with a single, very polite attendant. You can send requests to the attendant, but only one request is processed at a time, ensuring everything stays in order.

```swift
import Foundation

actor SharedMissionLog {
    private var logEntries: [String] = []

    func addEntry(_ entry: String) {
        logEntries.append("\(Date()): \(entry)")
        print("Added entry: \(entry)")
    }

    func getLog() -> [String] {
        return logEntries
    }

    func clearLog() {
        logEntries.removeAll()
        print("Mission log cleared.")
    }
}

// How to interact with an actor:
let missionLog = SharedMissionLog()

Task {
    // When calling an actor's method, you must use 'await'
    await missionLog.addEntry("Captain Swift deployed.")
    await missionLog.addEntry("Villain detected in Sector 7.")

    let currentLog = await missionLog.getLog()
    print("--- Current Mission Log ---")
    for entry in currentLog {
        print(entry)
    }

    await missionLog.clearLog()
    let clearedLog = await missionLog.getLog()
    print("Log after clearing: \(clearedLog.count) entries")
}
```

**Key Points about Actors:**
- `actor` keyword — Declares a new actor type
- `await` — You must `await` calls to an actor's methods or properties from outside the actor
- **Isolation** — An actor's mutable state is isolated to that actor, preventing concurrent access issues

**Why Actors?** They make writing safe concurrent code much easier, especially when dealing with shared resources like network caches, databases, or global state managers.

## Error Handling in Networking: When the Communicator Fails

Network requests are prone to many types of failures. Always define custom error types for clear, user-friendly messages.

```swift
import Foundation

enum MissionAPIError: Error, LocalizedError {
    case invalidServerResponse
    case dataDecodingFailed(Error)
    case networkUnavailable
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .invalidServerResponse:
            return "The server returned an unexpected response."
        case .dataDecodingFailed(let error):
            return "Failed to process mission data: \(error.localizedDescription)"
        case .networkUnavailable:
            return "No internet connection. Please check your network."
        case .custom(let message):
            return message
        }
    }
}

func getUrgentMission() async throws -> String {
    guard let url = URL(string: "https://api.example.com/urgent_mission") else {
        throw MissionAPIError.custom("Invalid URL")
    }

    do {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MissionAPIError.invalidServerResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            if let missionDetails = String(data: data, encoding: .utf8) {
                return missionDetails
            } else {
                throw MissionAPIError.dataDecodingFailed(
                    NSError(domain: "", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Could not decode mission details"])
                )
            }
        case 400...499:
            throw MissionAPIError.custom("Client error: \(httpResponse.statusCode)")
        case 500...599:
            throw MissionAPIError.custom("Server error: \(httpResponse.statusCode)")
        default:
            throw MissionAPIError.custom("Unexpected status code: \(httpResponse.statusCode)")
        }
    } catch URLError.notConnectedToInternet {
        throw MissionAPIError.networkUnavailable
    } catch {
        throw MissionAPIError.custom("An unexpected error occurred: \(error.localizedDescription)")
    }
}

Task {
    do {
        let mission = try await getUrgentMission()
        print("Urgent Mission: \(mission)")
    } catch let apiError as MissionAPIError {
        print("Mission API Error: \(apiError.localizedDescription)")
    } catch {
        print("Generic Error: \(error.localizedDescription)")
    }
}
```

**Key Practices for Networking Error Handling:**
- **Custom Error Types** — Define your own `Error` enums conforming to `LocalizedError` for user-friendly messages
- **do-catch Blocks** — Use `do-catch` to gracefully handle potential errors from `try await` calls
- **Specific Error Catching** — Catch specific `URLError` types (like `.notConnectedToInternet`) to provide tailored feedback

## Caching: Storing Intel for Offline Access

Superheroes often need to access intelligence even when their communicators are offline. **Caching** is the process of storing frequently accessed data locally on the device so that it can be retrieved quickly without making a new network request.

### URLCache: Automatic Web Caching

```swift
import Foundation

func configureURLCache() {
    let memoryCapacity = 50 * 1024 * 1024 // 50 MB
    let diskCapacity = 100 * 1024 * 1024 // 100 MB
    let cache = URLCache(memoryCapacity: memoryCapacity,
                         diskCapacity: diskCapacity,
                         diskPath: "myAppCache")
    URLCache.shared = cache
    print("URLCache configured with memory: \(memoryCapacity / 1024 / 1024)MB, disk: \(diskCapacity / 1024 / 1024)MB")
}

// When making requests, use cachePolicy to control caching behavior
func fetchAndCacheImage() async {
    guard let imageUrl = URL(string: "https://example.com/hero_logo.png") else { return }

    let request = URLRequest(url: imageUrl,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: 60)

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        if let image = UIImage(data: data) {
            print("Image fetched/loaded from cache.")
            // Display image
        }
    } catch {
        print("Failed to fetch image: \(error.localizedDescription)")
    }
}
```

`.returnCacheDataElseLoad` tells `URLSession` to return cached data if available, otherwise go to the network.

## Pull-to-Refresh: Getting the Latest Intel

Pull-to-refresh is a common UI gesture where a user pulls down on a scrollable view to trigger a refresh. SwiftUI makes this incredibly simple with the `.refreshable` modifier.

```swift
import SwiftUI

struct MissionUpdatesView: View {
    @State private var updates: [String] = ["Initial briefing received."]
    @State private var isLoading = false

    func fetchLatestUpdates() async {
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        let newUpdate = "New intel: Villain activity detected in Sector \(Int.random(in: 1...10))!"
        updates.insert(newUpdate, at: 0)
        isLoading = false
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(updates, id: \.self) { update in
                    Text(update)
                }
                if isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Mission Updates")
            .refreshable {
                // This block is called when the user pulls to refresh
                await fetchLatestUpdates()
            }
        }
    }
}
```

## Secure Storage (Keychain): Protecting Your Secrets

Sensitive information like authentication tokens, API keys, or user passwords should **never** be stored in `UserDefaults` or plain text files. Instead, you use the **Keychain**.

The Keychain Services API provides a secure way to store small bits of sensitive user data. The data is encrypted and stored in a secure database on the device.

```swift
import Foundation
import Security // Required for Keychain Services

enum KeychainError: Error {
    case duplicateItem
    case unknown(OSStatus)
    case noItem
    case invalidData
}

class SecretVault {
    static let shared = SecretVault()

    private let service = "com.yourcompany.yourapp.auth"

    func saveAuthToken(_ token: String, forAccount account: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // Delete any existing item before adding a new one
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        print("Auth token saved for account: \(account)")
    }

    func loadAuthToken(forAccount account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.noItem
            }
            throw KeychainError.unknown(status)
        }

        guard let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        print("Auth token loaded for account: \(account)")
        return token
    }

    func deleteAuthToken(forAccount account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
        print("Auth token deleted for account: \(account)")
    }
}
```

**Key Concepts for Keychain:**
- `kSecClassGenericPassword` — The most common class for storing generic passwords or tokens
- `kSecAttrService` — A string that identifies the service (your app's bundle ID or a unique string)
- `kSecAttrAccount` — A string that identifies the user account associated with the item
- `SecItemAdd`, `SecItemCopyMatching`, `SecItemDelete` — Functions for adding, retrieving, and deleting items
- `OSStatus` — Keychain functions return an OSStatus code indicating success or failure

> ⚡ **Mini Challenge: Secure Login!**
> Imagine you have a login screen where a user enters a username and password. After successful authentication with a (simulated) server, you receive an authentication token. Write a function that uses SecretVault to save this token to the Keychain for the given username. Then, write another function to retrieve it.

---

This concludes our journey into connecting your apps to the world! You now have the networking superpowers to fetch data, handle asynchronous operations, protect shared resources, manage errors, cache information, and securely store sensitive credentials. Next, we'll make our apps shine with animations, gestures, and polish!
