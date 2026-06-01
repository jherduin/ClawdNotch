// swift-tools-version:5.9
import PackageDescription

// Package de développement : permet de compiler et vérifier les sources avec
// `swift build`. Le bundle .app final (avec Info.plist / LSUIElement) sera
// produit par le projet Xcode branché ultérieurement (Phase 1).
let package = Package(
    name: "ClawdNotch",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ClawdNotch",
            path: "ClawdNotch"
        )
    ]
)
