# ModerationKit

MarqueKit is a series of tools for creative encryption methods. Hiding data within various media types. Opening methods of sharing other than standards like QR Codes.

## Stego (Least Significant Bit)

```swift
//Returns confidence level that an image is NSFW
await ModerationKit.current.check(image, for: .nsfw) -> Float?
```

## Credits

- Stego LSB is based on [ISStego](https://github.com/isena/ISStego) by [@isena](https://github.com/isena)
