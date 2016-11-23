import PackageDescription

let package = Package(
	name: "PerlCoro",
	targets: [
		Target(name: "CPerlCoro"),
		Target(name: "PerlCoro", dependencies: [.Target(name: "CPerlCoro")]),
	],
	dependencies: [
		.Package(url: "https://github.com/my-mail-ru/swiftperl.git", majorVersion: 0),
	]
)
