# ModerationKit

Collection of tooling to create a safe experience browsing content. With a focus on offline solutions that use on-device resources to compute useful observations.

## Guide

```swift
public enum Detection {
    public struct Result {
        var label: String //"NSFW" or "SFW"
        var confidence: Float
    }
}


//Returns confidence level that an image is NSFW
await ModerationKit.current.check(image, for: .nsfw) -> Detection.Result?
```

## Credits

- Yahoo's detection for [OpenNSFW](https://github.com/yahoo/open_nsfw) 
