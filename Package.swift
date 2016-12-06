import PackageDescription
import Glibc

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

let me = CommandLine.arguments[0]
var parts = me.characters.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
parts[parts.endIndex - 1] = "Sources/CPerlCoro/include/module.modulemap"
let filename = parts.joined(separator: "/")

let lines = [
	"module CPerlCoro [system] {",
	"\theader \"shim.h\"",
	"\theader \"$Config{installvendorarch}/Coro/CoroAPI.h\"",
	"\tuse SwiftGlibc",
	"\tuse CPerl",
	"\texport *",
	"}",
].map { "\($0)\n" }

let command = "perl -MConfig -we 'print qq#\(lines.joined())#' > \(filename)"
guard system(command) == 0 else {
	fatalError("failed to execute \(command)")
}
