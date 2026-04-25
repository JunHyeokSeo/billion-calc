#!/usr/bin/env swift
import AppKit
import Foundation

// Generates a 1024x1024 App Icon PNG with "1억" text on gold gradient.
// Usage: swift Scripts/GenerateIcon.swift

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

// Background: gold gradient (top bright → bottom darker)
let rect = NSRect(origin: .zero, size: size)
let gradient = NSGradient(colorsAndLocations:
    (NSColor(red: 1.00, green: 0.85, blue: 0.32, alpha: 1.0), 0.0),
    (NSColor(red: 0.93, green: 0.67, blue: 0.10, alpha: 1.0), 1.0)
)!
gradient.draw(in: rect, angle: -90)

// Inner highlight ring
let ringPath = NSBezierPath(roundedRect: rect.insetBy(dx: 80, dy: 80), xRadius: 180, yRadius: 180)
NSColor.white.withAlphaComponent(0.12).setStroke()
ringPath.lineWidth = 14
ringPath.stroke()

// Text: "1억"
let font = NSFont.systemFont(ofSize: 440, weight: .black)
let shadow = NSShadow()
shadow.shadowOffset = NSSize(width: 0, height: -8)
shadow.shadowBlurRadius = 24
shadow.shadowColor = NSColor.black.withAlphaComponent(0.25)

let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.black.withAlphaComponent(0.90),
    .shadow: shadow
]
let text = NSAttributedString(string: "1억", attributes: attrs)
let textSize = text.size()
let textOrigin = NSPoint(
    x: (size.width - textSize.width) / 2,
    y: (size.height - textSize.height) / 2 - 40
)
text.draw(at: textOrigin)

// Subtle top highlight overlay (glassy feel)
let topRect = NSRect(x: 0, y: size.height * 0.55, width: size.width, height: size.height * 0.45)
let topGradient = NSGradient(colorsAndLocations:
    (NSColor.white.withAlphaComponent(0.15), 0.0),
    (NSColor.white.withAlphaComponent(0.0), 1.0)
)!
topGradient.draw(in: topRect, angle: -90)

image.unlockFocus()

// Export PNG
guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("Failed to generate PNG data\n".data(using: .utf8)!)
    exit(1)
}

// Resolve path relative to script invocation directory
let fm = FileManager.default
let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let projectRoot = scriptDir.deletingLastPathComponent()
let outputDir = projectRoot.appendingPathComponent("App/Resources/Assets.xcassets/AppIcon.appiconset")
let outputURL = outputDir.appendingPathComponent("AppIcon-1024.png")

do {
    try fm.createDirectory(at: outputDir, withIntermediateDirectories: true)
    try png.write(to: outputURL)
    print("✓ Generated: \(outputURL.path)")
    print("  Size: 1024×1024, \(png.count) bytes")
} catch {
    FileHandle.standardError.write("Failed to write: \(error)\n".data(using: .utf8)!)
    exit(1)
}
