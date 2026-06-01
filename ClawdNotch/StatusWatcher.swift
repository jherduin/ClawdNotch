import Foundation

/// État courant de Claude Code reflété par le notch.
enum NotchStatus: String {
    case working
    case waiting
    case idle
}

/// Surveille en temps réel le fichier `~/.claude/notch_status` via `DispatchSource`
/// (aucun polling). Crée le fichier s'il est absent et republie l'état à chaque
/// modification. Réarme automatiquement la surveillance si le fichier est
/// remplacé de façon atomique (suppression / renommage).
final class StatusWatcher: ObservableObject {

    @Published private(set) var status: NotchStatus = .idle

    private let fileURL: URL
    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: CInt = -1
    private let queue = DispatchQueue(label: "com.clawdnotch.statuswatcher")

    init() {
        let claudeDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude", isDirectory: true)
        fileURL = claudeDir.appendingPathComponent("notch_status")
    }

    deinit {
        stop()
    }

    /// Démarre la surveillance : garantit l'existence du fichier, lit l'état
    /// initial puis arme la `DispatchSource`.
    func start() {
        ensureFileExists()
        readStatus()
        beginWatching()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    // MARK: - Fichier

    private func ensureFileExists() {
        let fm = FileManager.default
        let dir = fileURL.deletingLastPathComponent()
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        if !fm.fileExists(atPath: fileURL.path) {
            try? NotchStatus.idle.rawValue.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    private func readStatus() {
        let raw = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let newStatus = NotchStatus(rawValue: trimmed) ?? .idle

        // `@Published` doit muter sur le thread principal pour SwiftUI.
        DispatchQueue.main.async { [weak self] in
            self?.status = newStatus
        }
    }

    // MARK: - Surveillance

    private func beginWatching() {
        let fd = open(fileURL.path, O_EVTONLY)
        guard fd >= 0 else { return }
        fileDescriptor = fd

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .extend, .delete, .rename],
            queue: queue
        )

        source.setEventHandler { [weak self] in
            guard let self else { return }
            let flags = self.source?.data ?? []
            if flags.contains(.delete) || flags.contains(.rename) {
                // Remplacement atomique du fichier : on réarme sur le nouvel inode.
                self.rearm()
            } else {
                self.readStatus()
            }
        }

        source.setCancelHandler { [weak self] in
            guard let self, self.fileDescriptor >= 0 else { return }
            close(self.fileDescriptor)
            self.fileDescriptor = -1
        }

        self.source = source
        source.resume()
    }

    private func rearm() {
        stop()
        ensureFileExists()
        readStatus()
        beginWatching()
    }
}
