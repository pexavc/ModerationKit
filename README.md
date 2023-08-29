# ModerationKit

Collection of tooling to create a safe experience browsing content. With a focus on offline solutions that use on-device resources to compute useful observations.

## Guide

```swift
public enum Detection {
    public struct Result { // (Internal), can export if exact data is required
        var label: String //"NSFW" or "SFW"
        var confidence: Float
    }
}

public func check(_ image: ModerationImage, for kind: Moderation.Kind) async -> Bool {
```

## Credits

- Yahoo's detection for [OpenNSFW](https://github.com/yahoo/open_nsfw) 
- bhky's keras version https://github.com/bhky/opennsfw2
