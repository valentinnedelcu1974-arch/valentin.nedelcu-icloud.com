import SwiftUI
import AVFoundation

struct Station: Codable, Identifiable, Hashable {
    var id: String { url }
    let name: String
    let genre: String
    let url: String
}

@MainActor final class RadioModel: ObservableObject {
    @Published var stations: [Station] = []
    @Published var current: Station?
    @Published var playing = false
    @Published var favorites: Set<String> = []
    @Published var message = "Alege un post pentru a asculta"
    private var player: AVPlayer?
    init() {
        if let data = UserDefaults.standard.data(forKey: "stations"), let saved = try? JSONDecoder().decode([Station].self, from: data) { stations = saved }
        else { stations = [Station(name: "Exemplu – adaugă stream", genre: "Configurare", url: "https://example.com/stream.mp3")] }
        favorites = Set(UserDefaults.standard.stringArray(forKey: "favorites") ?? [])
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    }
    func save() { if let data = try? JSONEncoder().encode(stations) { UserDefaults.standard.set(data, forKey: "stations") } }
    func add(name: String, genre: String, url: String) {
        guard let parsed = URL(string: url), parsed.scheme == "https", parsed.host != nil else { message = "Folosește un URL HTTPS valid"; return }
        stations.append(Station(name: name, genre: genre, url: url)); save()
    }
    func remove(at offsets: IndexSet) { stations.remove(atOffsets: offsets); save() }
    func play(_ station: Station) {
        guard let url = URL(string: station.url) else { return }
        player?.pause(); player = AVPlayer(url: url); current = station; player?.play(); playing = true
        message = "Redare: \(station.name)"
    }
    func toggle() { guard let player else { return }; if playing { player.pause() } else { player.play() }; playing.toggle() }
    func favorite(_ station: Station) { if favorites.contains(station.url) { favorites.remove(station.url) } else { favorites.insert(station.url) }; UserDefaults.standard.set(Array(favorites), forKey: "favorites") }
}

struct ContentView: View {
    @StateObject private var model = RadioModel()
    @State private var search = ""
    @State private var onlyFavorites = false
    @State private var adding = false
    @State private var name = ""
    @State private var genre = ""
    @State private var url = ""
    var filtered: [Station] { model.stations.filter { (!onlyFavorites || model.favorites.contains($0.url)) && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || $0.genre.localizedCaseInsensitiveContains(search)) } }
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HStack { Image(systemName: "dot.radiowaves.left.and.right").font(.largeTitle); VStack(alignment: .leading) { Text("RADIO ONLINE PRO").font(.headline); Text("Live • Favorite • Simplu").font(.caption).foregroundStyle(.secondary) }; Spacer() }.padding(.horizontal)
                Toggle("Doar favorite", isOn: $onlyFavorites).padding(.horizontal)
                List {
                    ForEach(filtered) { station in
                        HStack {
                            Button { model.play(station) } label: { VStack(alignment: .leading, spacing: 4) { Text(station.name).font(.headline); Text(station.genre).font(.caption).foregroundStyle(.secondary) } }.buttonStyle(.plain)
                            Spacer()
                            Button { model.favorite(station) } label: { Image(systemName: model.favorites.contains(station.url) ? "heart.fill" : "heart").foregroundStyle(.pink) }.buttonStyle(.borderless)
                            Button { model.play(station) } label: { Image(systemName: "play.circle.fill").font(.title2) }.buttonStyle(.borderless)
                        }
                    }.onDelete(perform: model.remove)
                }.searchable(text: $search, prompt: "Caută posturi")
                VStack(spacing: 8) {
                    Text(model.current?.name ?? "Niciun post selectat").font(.headline)
                    Text(model.message).font(.caption).foregroundStyle(.secondary)
                    Button { model.toggle() } label: { Image(systemName: model.playing ? "pause.circle.fill" : "play.circle.fill").font(.system(size: 52)) }
                    Text("Volumul se reglează din butoanele iPhone").font(.caption2).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity).padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 22)).padding(.horizontal)
            }
            .navigationTitle("Radio")
            .toolbar { Button { adding = true } label: { Label("Adaugă post", systemImage: "plus") } }
            .sheet(isPresented: $adding) {
                NavigationStack { Form { TextField("Numele postului", text: $name); TextField("Gen (Pop, Rock etc.)", text: $genre); TextField("URL direct HTTPS către stream", text: $url).textInputAutocapitalization(.never).keyboardType(.URL)
                    Section { Text("Adaugă doar streamuri pentru care ai drept de retransmisie. URL-ul trebuie să fie flux audio, nu pagina web a radioului.").font(.footnote) }
                }.navigationTitle("Post nou").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Închide") { adding = false } }; ToolbarItem(placement: .confirmationAction) { Button("Salvează") { model.add(name: name, genre: genre, url: url); if URL(string: url)?.scheme == "https" && !name.isEmpty { adding = false; name = ""; genre = ""; url = "" } }.disabled(name.isEmpty || url.isEmpty) } } }
            }
        }.tint(.purple)
    }
}

@main struct RadioOnlineProApp: App { var body: some Scene { WindowGroup { ContentView() } } }
