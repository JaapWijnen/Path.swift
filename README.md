# Path.swift ![badge-platforms] ![badge-languages][] [![Build Status](https://travis-ci.com/mxcl/Path.swift.svg)](https://travis-ci.com/mxcl/Path.swift)

A file-system pathing library focused on developer experience and robust end
results.

```swift
import Path

// convenient static members
let home = Path.home

// pleasant joining syntax
let docs = Path.home/"Documents"

// paths are *always* absolute thus avoiding common bugs
let path = Path(userInput) ?? Path.cwd/userInput

// elegant, chainable syntax
try Path.home.join("foo").mkdir().join("bar").touch().chmod(0o555)

// sensible considerations
try Path.home.join("bar").mkdir()
try Path.home.join("bar").mkdir()  // doesn’t throw ∵ we already have the desired result

// easy file-management
let bar = try Path.root.join("foo").copy(to: Path.root/"bar")
print(bar)         // => /bar
print(bar.isFile)  // => true

// careful API considerations so as to avoid common bugs
let foo = try Path.root.join("foo").copy(into: Path.root.join("bar").mkdir())
print(foo)         // => /bar/foo
print(foo.isFile)  // => true

// we support dynamic members (_use_sparingly_):
let prefs = Path.home.Library.Preferences

// a practical example: installing a helper executable
try Bundle.resources.join("helper").copy(into: Path.home.join(".local/bin").mkdir(.p)).chmod(0o500)
```

We emphasize safety and correctness, just like Swift, and also (again like
Swift), we provide a thoughtful and comprehensive (yet concise) API.

# Support mxcl

Hi, I’m Max Howell and I have written a lot of open source software, and
probably you already use some of it (Homebrew anyone?). I work full-time on
open source and it’s hard; currently I earn *less* than minimum wage. Please
help me continue my work, I appreciate it x

<a href="https://www.patreon.com/mxcl">
	<img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>

[Other donation/tipping options](http://mxcl.github.io/donate/)

# Handbook

Our [online API documentation] is automatically updated for new releases.

## Codable

We support `Codable` as you would expect:

```swift
try JSONEncoder().encode([Path.home, Path.home/"foo"])
```

```json
[
    "/Users/mxcl",
    "/Users/mxcl/foo",
]
```

However, often you want to encode relative paths:

```swift
let encoder = JSONEncoder()
encoder.userInfo[.relativePath] = Path.home
encoder.encode([Path.home, Path.home/"foo"])
```

```json
[
    "",
    "foo",
]
```

**Note** make sure you decode with this key set *also*, otherwise we `fatal`
(unless the paths are absolute obv.)

```swift
let decoder = JSONDecoder()
decoder.userInfo[.relativePath] = Path.home
decoder.decode(from: data)
```

## Dynamic members

We support `@dynamicMemberLookup`:

```swift
let ls = Path.root.usr.bin.ls  // => /usr/bin/ls
```

This is less commonly useful than you would think, hence our documentation
does not use it. Usually you are joining variables or other `String` arguments.
However when you need it, it’s *lovely*.

## Initializing from user-input

The `Path` initializer returns `nil` unless fed an absolute path; thus to
initialize from user-input that may contain a relative path use this form:

```swift
let path = Path(userInput) ?? Path.cwd/userInput
```

This is explicit, not hiding anything that code-review may miss and preventing
common bugs like accidentally creating `Path` objects from strings you did not
expect to be relative.

Our initializer is nameless to be consistent with the equivalent operation for
converting strings to `Int`, `Float` etc. in the standard library.

## Extensions

We have some extensions to Apple APIs:

```swift
let bashProfile = try String(contentsOf: Path.home/".bash_profile")
let history = try Data(contentsOf: Path.home/".history")

bashProfile += "\n\nfoo"

try bashProfile.write(to: Path.home/".bash_profile")

try Bundle.main.resources.join("foo").copy(to: .home)
```

## Directory listings

We provide `ls()`, called because it behaves like the Terminal `ls` function,
the name thus implies its behavior, ie. that it is not recursive.

```swift
for entry in Path.home.ls() {
    print(entry.path)
    print(entry.kind)  // .directory or .file
}

for entry in Path.home.ls() where entry.kind == .file {
    //…
}

for entry in Path.home.ls() where entry.path.mtime > yesterday {
    //…
}

let dirs = Path.home.ls().directories().filter {
    //…
}

let swiftFiles = Path.home.ls().files(withExtension: "swift")
```

# Rules & Caveats

Paths are just string representations, there *might not* be a real file there.

```swift
Path.home/"b"      // => /Users/mxcl/b

// joining multiple strings works as you’d expect
Path.home/"b"/"c"  // => /Users/mxcl/b/c

// joining multiple parts at a time is fine
Path.home/"b/c"    // => /Users/mxcl/b/c

// joining with absolute paths omits prefixed slash
Path.home/"/b"     // => /Users/mxcl/b

// of course, feel free to join variables:
let b = "b"
let c = "c"
Path.home/b/c      // => /Users/mxcl/b/c

// tilde is not special here
Path.root/"~b"     // => /~b
Path.root/"~/b"    // => /~/b

// but is here
Path("~/foo")!     // => /Users/mxcl/foo

// this does not work though
Path("~foo")       // => nil
```

*Path.swift* has the general policty that if the desired end result preexists,
then it’s a noop:

* If you try to delete a file, but the file doesn't exist, we do nothing.
* If you try to make a directory and it already exists, we do nothing.

However notably if you try to copy or move a file with specifying `overwrite`
and the file already exists at the destination and is identical, we don’t check
for that as the check was deemed too expensive to be worthwhile.

# Installation

SwiftPM:

```swift
package.append(.package(url: "https://github.com/mxcl/Path.swift", from: "0.5.0"))
```

CocoaPods:

```ruby
pod 'Path.swift' ~> '0.5.0'
```

Carthage:

> Waiting on: [@Carthage#1945](https://github.com/Carthage/Carthage/pull/1945).

## Please note

We are pre 1.0, thus we can change the API as we like, and we will (to the
pursuit of getting it *right*)! We will tag 1.0 as soon as possible.

### Get push notifications for new releases

https://codebasesaga.com/canopy/

# Alternatives

* [PathKit](https://github.com/kylef/PathKit) by Kyle Fuller
* [Files](https://github.com/JohnSundell/Files) by John Sundell
* [Utility](https://github.com/apple/swift-package-manager) by Apple


[badge-platforms]: https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg
[badge-languages]: https://img.shields.io/badge/swift-4.2%20%7C%205.0-orange.svg
[online API documentation]: https://mxcl.github.io/Path.swift/Structs/Path.html
