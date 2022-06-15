# DoNilDisturb Swift Plugin

Use Xcode 14+ to make use of this amazing and novel Swift plugin in your package.

The plugin stops you from working on your 9-5 project outside of 9-5 hours:

![Project failing to compile with a message that do not disturb is on](etc/dnd.png)

Add this to your dependencies in your Package.swift:

```swift
.package(url: "https://github.com/icanzilb/DoNilDisturbPlugin.git", from: "0.0.1"),
```

**And then**, add the plugin in your target definition(still in Package.swift:

```swift
.target(
  name: "MyTarget",
  plugins: [
    .plugin(name: "DoNilDisturbPlugin")
  ]
)
```

That's all. Your target will fail to build outside of working hours.

Enjoy your time off work.

## License

MIT, of course.