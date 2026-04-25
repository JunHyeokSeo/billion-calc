import Foundation

extension String {
    /// Removes emoji scalars while preserving digits, Korean/CJK, and ASCII text.
    /// Intentionally avoids `scalar.properties.isEmoji` — that property reports `true`
    /// for ASCII digits 0–9 (they can form keycap emoji like 0️⃣), which would otherwise
    /// strip all numbers out of rendered motivation templates.
    public func strippingEmoji() -> String {
        self.unicodeScalars
            .filter { scalar in
                let v = scalar.value
                if v == 0x200D { return false }                      // ZWJ
                if (0xFE00...0xFE0F).contains(v) { return false }    // Variation selectors
                if (0x2300...0x23FF).contains(v) { return false }    // Misc Technical (⏰⏳⌚)
                if (0x2500...0x25FF).contains(v) { return false }    // Geometric shapes
                if (0x2600...0x27BF).contains(v) { return false }    // Misc symbols, Dingbats
                if (0x2B00...0x2BFF).contains(v) { return false }    // Misc symbols & arrows
                if (0x1F000...0x1FFFF).contains(v) { return false }  // Supplementary emoji plane
                return true
            }
            .reduce("", { $0 + String($1) })
            .trimmingCharacters(in: .whitespaces)
    }
}
