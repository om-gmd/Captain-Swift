# Building Real Apps: Step-by-Step (The Best Part!)

Congratulations, future iOS Superheroes! You've trained hard, mastered the fundamentals of Swift, explored the classic powers of UIKit, and embraced the magic of SwiftUI. You've learned about managing data, connecting to the world, and polishing your apps to a brilliant shine. Now, it's time for the ultimate test: building real-world applications from the ground up! This is where all your superpowers come together.

In this chapter, we'll embark on several exciting missions, building complete apps step-by-step. For each app, we'll cover:

- **The Mission Briefing** — What is the app, and what features will it have?
- **Architectural Blueprint** — How will we structure the app?
- **Step-by-Step Construction** — We'll build the app piece by piece, explaining each part
- **Why We Chose This Pattern** — A reflection on the design decisions

Get ready to code! Your first mission awaits…

## Mission 1: Super Todo Hero (SwiftUI + MVVM + SwiftData)

Every superhero needs a way to keep track of their important tasks, from stopping villains to remembering to feed their super-pets. Our Super Todo Hero app will be a simple yet powerful task manager, demonstrating how to use SwiftUI for the UI, MVVM for clean architecture, and SwiftData for persistent storage.

### Mission Briefing: Super Todo Hero Features

- **Add New Tasks** — Heroes can quickly add new missions (todos)
- **Mark as Complete** — Heroes can mark missions as completed
- **Delete Tasks** — Completed or abandoned missions can be removed
- **Filter Tasks** — View all missions, only active missions, or only completed missions
- **Persistent Storage** — All missions are saved and loaded automatically using SwiftData

### Architectural Blueprint

- **Model** — A `Mission` class for SwiftData to represent a single task
- **ViewModel** — A `MissionListViewModel` class to manage the list, handle adding/deleting/updating, and provide filtered lists
- **View** — A `MissionListView` SwiftUI view to display the missions
- **Persistence** — SwiftData handles saving and loading automatically

### Step 1: The Mission Model (Mission.swift)

```swift
import Foundation
import SwiftData

@Model
class Mission {
    var name: String
    var isCompleted: Bool
    var timestamp: Date

    init(name: String, isCompleted: Bool = false, timestamp: Date = Date()) {
        self.name = name
        self.isCompleted = isCompleted
        self.timestamp = timestamp
    }
}
```

- `@Model` — Makes our Mission class a SwiftData model, saved automatically to the persistent store
- `name` — The description of the mission
- `isCompleted` — A boolean to track if the mission is done
- `timestamp` — When the mission was created, useful for sorting

### Step 2: The Mission List ViewModel (MissionListViewModel.swift)

```swift
import Foundation
import SwiftData

@Observable
class MissionListViewModel {
    private var modelContext: ModelContext?

    var missions: [Mission] = []
    var filter: MissionFilter = .all

    enum MissionFilter: String, CaseIterable, Identifiable {
        case all = "All Missions"
        case active = "Active Missions"
        case completed = "Completed Missions"

        var id: String { self.rawValue }
    }

    var filteredMissions: [Mission] {
        switch filter {
        case .all:
            return missions.sorted(using: KeyPathComparator(\Mission.timestamp, order: .reverse))
        case .active:
            return missions.filter { !$0.isCompleted }
                .sorted(using: KeyPathComparator(\Mission.timestamp, order: .reverse))
        case .completed:
            return missions.filter { $0.isCompleted }
                .sorted(using: KeyPathComparator(\Mission.timestamp, order: .reverse))
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchMissions()
    }

    func fetchMissions() {
        guard let context = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<Mission>(
                sortBy: [SortDescriptor(\Mission.timestamp, order: .reverse)]
            )
            missions = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch missions: \(error.localizedDescription)")
        }
    }

    func addMission(name: String) {
        guard let context = modelContext else { return }
        let newMission = Mission(name: name)
        context.insert(newMission)
        fetchMissions()
    }

    func toggleMissionCompletion(mission: Mission) {
        mission.isCompleted.toggle()
        fetchMissions()
    }

    func deleteMission(at offsets: IndexSet) {
        guard let context = modelContext else { return }
        for index in offsets {
            context.delete(filteredMissions[index])
        }
        fetchMissions()
    }
}
```

### Step 3: The Mission List View (MissionListView.swift)

```swift
import SwiftUI
import SwiftData

struct MissionListView: View {
    @State private var newMissionName = ""
    @State private var showAddMissionSheet = false
    @Environment(MissionListViewModel.self) private var viewModel

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(MissionListViewModel.MissionFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    ForEach(viewModel.filteredMissions) { mission in
                        HStack {
                            Button {
                                viewModel.toggleMissionCompletion(mission: mission)
                            } label: {
                                Image(systemName: mission.isCompleted ?
                                      "checkmark.circle.fill" : "circle")
                                    .foregroundColor(mission.isCompleted ? .green : .gray)
                            }
                            .buttonStyle(.plain)

                            Text(mission.name)
                                .strikethrough(mission.isCompleted)
                                .foregroundColor(mission.isCompleted ? .secondary : .primary)
                        }
                    }
                    .onDelete(perform: viewModel.deleteMission)
                }
                .navigationTitle("Super Todo Hero")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showAddMissionSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                }
                .sheet(isPresented: $showAddMissionSheet) {
                    AddMissionView(newMissionName: $newMissionName,
                                   showAddMissionSheet: $showAddMissionSheet)
                        .environment(viewModel)
                }
            }
        }
        .onAppear(perform: viewModel.fetchMissions)
    }
}

struct AddMissionView: View {
    @Binding var newMissionName: String
    @Binding var showAddMissionSheet: Bool
    @Environment(MissionListViewModel.self) private var viewModel

    var body: some View {
        NavigationView {
            Form {
                TextField("New Mission Name", text: $newMissionName)
                Button("Add Mission") {
                    if !newMissionName.isEmpty {
                        viewModel.addMission(name: newMissionName)
                        newMissionName = ""
                        showAddMissionSheet = false
                    }
                }
                .disabled(newMissionName.isEmpty)
            }
            .navigationTitle("Add New Mission")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showAddMissionSheet = false }
                }
            }
        }
    }
}
```

**Why We Chose This Pattern:**
- **SwiftUI** for the UI — declarative and easy to read
- **MVVM** — keeps business logic out of the View
- **SwiftData** — automatic persistence with minimal boilerplate
- **@Observable ViewModel** — efficient UI updates only when needed

> ⚡ **Mini Challenge: Super Todo Hero Enhancements!**
> Add a priority level (low, medium, high) to the Mission model. Show different colored indicators based on priority in the list. Add a filter option for "High Priority Only".

## Mission 2: Weather Hero (SwiftUI + Networking + MVVM)

Build a weather app using a real public API. You'll practice networking, JSON decoding, async/await, and displaying dynamic data.

### The Weather Data Model

```swift
import Foundation

struct WeatherResponse: Codable {
    let name: String
    let main: MainData
    let weather: [WeatherDescription]
    let wind: WindData

    struct MainData: Codable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case humidity
        }
    }

    struct WeatherDescription: Codable {
        let main: String
        let description: String
        let icon: String
    }

    struct WindData: Codable {
        let speed: Double
    }
}
```

### The Weather ViewModel

```swift
import Foundation

@Observable
class WeatherViewModel {
    var weatherData: WeatherResponse?
    var isLoading = false
    var errorMessage: String?

    var temperatureDisplay: String {
        guard let temp = weatherData?.main.temp else { return "--°" }
        return "\(Int(temp))°C"
    }

    var conditionDisplay: String {
        weatherData?.weather.first?.description.capitalized ?? "Unknown"
    }

    func fetchWeather(for city: String) async {
        guard !city.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        let apiKey = "YOUR_API_KEY" // Get free key from openweathermap.org
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encoded)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid city name"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch {
            errorMessage = "Could not fetch weather. Please check the city name."
        }

        isLoading = false
    }
}
```

### The Weather View

```swift
import SwiftUI

struct WeatherHeroView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.6), .blue.opacity(0.3)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    HStack {
                        TextField("Enter city name...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                Task { await viewModel.fetchWeather(for: searchText) }
                            }
                        Button("Search") {
                            Task { await viewModel.fetchWeather(for: searchText) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()

                    if viewModel.isLoading {
                        ProgressView("Fetching weather...")
                            .tint(.white)
                    } else if let error = viewModel.errorMessage {
                        Text("⚠️ \(error)")
                            .foregroundColor(.yellow)
                    } else if let weather = viewModel.weatherData {
                        VStack(spacing: 12) {
                            Text(weather.name)
                                .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                            Text(viewModel.temperatureDisplay)
                                .font(.system(size: 72, weight: .light)).foregroundColor(.white)
                            Text(viewModel.conditionDisplay)
                                .font(.title2).foregroundColor(.white.opacity(0.8))
                            HStack(spacing: 32) {
                                VStack {
                                    Text("Humidity").font(.caption).foregroundColor(.white.opacity(0.7))
                                    Text("\(weather.main.humidity)%").font(.headline).foregroundColor(.white)
                                }
                                VStack {
                                    Text("Wind").font(.caption).foregroundColor(.white.opacity(0.7))
                                    Text("\(Int(weather.wind.speed)) m/s").font(.headline).foregroundColor(.white)
                                }
                                VStack {
                                    Text("Feels Like").font(.caption).foregroundColor(.white.opacity(0.7))
                                    Text("\(Int(weather.main.feelsLike))°C").font(.headline).foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(16)
                        }
                    } else {
                        Text("🌍 Search for a city to see weather")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
            }
            .navigationTitle("Weather Hero")
        }
    }
}
```

> ⚡ **Mini Challenge: Weather Hero Enhancements!**
> Extend the Weather Hero app to show a 5-day forecast using the /forecast endpoint of the OpenWeatherMap API. Display each day's high/low temperature and weather condition in a horizontal scroll view.

## Mission 3: Social Circle (SwiftUI + UIKit Mixed)

Even superheroes need a social life! Our Social Circle app demonstrates how to handle user-generated content, display dynamic lists, and manage interactions — including wrapping a UIKit component inside SwiftUI using `UIViewControllerRepresentable`.

### The Models

```swift
import Foundation

struct User: Identifiable, Hashable {
    let id = UUID()
    var username: String
    var profilePictureName: String
}

struct Post: Identifiable {
    let id = UUID()
    let user: User
    var content: String
    var imageUrl: String?
    var likeCount: Int
    var isLiked: Bool
    let timestamp: Date
}
```

### The Feed ViewModel

```swift
import Foundation

@Observable
class FeedViewModel {
    var posts: [Post] = [
        Post(user: User(username: "CaptainSwift", profilePictureName: "person.crop.circle.fill"),
             content: "Just saved the city from a giant robot! #heroLife",
             likeCount: 15, isLiked: false, timestamp: Date().addingTimeInterval(-3600)),
        Post(user: User(username: "CodeCrusader", profilePictureName: "person.crop.circle.fill"),
             content: "My new algorithm is flying! 🚀 #coding",
             likeCount: 22, isLiked: true, timestamp: Date().addingTimeInterval(-7200))
    ]

    func toggleLike(for post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isLiked.toggle()
            posts[index].likeCount += posts[index].isLiked ? 1 : -1
        }
    }

    func addPost(content: String, imageUrl: String?) {
        let newPost = Post(
            user: User(username: "NewHero", profilePictureName: "person.fill"),
            content: content, imageUrl: imageUrl,
            likeCount: 0, isLiked: false, timestamp: Date()
        )
        posts.insert(newPost, at: 0)
    }
}
```

### Image Picker — UIKit Wrapped in SwiftUI

This is a real-world example of `UIViewControllerRepresentable`, bridging UIKit's `UIImagePickerController` into SwiftUI:

```swift
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var onImagePicked: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.onImagePicked(info[.originalImage] as? UIImage)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            parent.dismiss()
        }
    }
}
```

> ⚡ **Mini Challenge: Social Circle Enhancements!**
> 1. Implement a user profile view showing all posts by a specific user. Navigate to it when a username is tapped.
> 2. Add the ability to comment on posts — a new Comment model, a text input field, and a comments count on each post card.
> 3. Add a "double-tap to like" gesture on each post card using SwiftUI's TapGesture with count: 2.

---

You've now built three complete, real-world applications! Each one demonstrated different combinations of skills: SwiftData for persistence, URLSession for networking, and UIViewControllerRepresentable for bridging UIKit into SwiftUI. Every real app is just a combination of patterns you've already learned. Now go build your own!
