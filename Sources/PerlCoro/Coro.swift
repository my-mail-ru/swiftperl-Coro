import CPerlCoro
import Perl

// TODO generic on function argument
public final class Coro : PerlObject, PerlNamedClass {
	public static let perlClassName = "Coro"

	public enum CoroError : Error {
		case coroApiNotFound
		case coroApiVersionMismatch(used: (ver: Int32, rev: Int32), compiled: (ver: Int32, rev: Int32))
	}

	static var coroApi: UnsafeMutablePointer<CoroAPI> = try! getCoroApi()
	static var perl: UnsafeInterpreterPointer = UnsafeInterpreter.current

	public static func initialize(perl: UnsafeInterpreterPointer = UnsafeInterpreter.current) throws {
		self.perl = perl
		coroApi = try getCoroApi()
	}

	static var loadModuleOnce: Void = loadModule(perl: perl)

	private static func getCoroApi() throws -> UnsafeMutablePointer<CoroAPI> {
		_ = loadModuleOnce
		guard let sv = perl.pointee.getSV("Coro::API") else {
			throw Coro.CoroError.coroApiNotFound
		}
		let coroApi = UnsafeMutablePointer<CoroAPI>(bitPattern: Int(unchecked: sv))!
		guard coroApi.pointee.ver == CORO_API_VERSION && coroApi.pointee.rev >= CORO_API_REVISION else {
			throw Coro.CoroError.coroApiVersionMismatch(
				used: (ver: coroApi.pointee.ver, rev: coroApi.pointee.rev),
				compiled: (ver: CORO_API_VERSION, rev: CORO_API_REVISION)
			)
		}
		return coroApi
	}

	public static var main: Coro = {
		_ = loadModuleOnce
		let sv = perl.pointee.getSV("Coro::main")!
		return Coro(incUnchecked: sv, perl: Coro.perl)
	}()

	public static func schedule() {
		coroApi.pointee.schedule(perl)
	}

	@discardableResult
	public static func cede(notSelf: Bool = false) -> Bool {
		let f = notSelf ? coroApi.pointee.cede_notself : coroApi.pointee.cede
		return f!(perl) != 0
	}

	public static var nReady: Int32 {
		return coroApi.pointee.nready
	}

	public static var current: Coro {
		return Coro(incUnchecked: coroApi.pointee.current, perl: Coro.perl)
	}

	public static var readyhook: @convention(c) () -> () {
		get { return coroApi.pointee.readyhook }
		set { coroApi.pointee.readyhook = newValue }
	}

	@discardableResult
	public static func async(_ body: @escaping () -> ()) -> Coro {
		let coro = Coro(body)
		coro.ready()
		return coro
	}

	public convenience init(_ body: @escaping () -> ()) {
		self.init(PerlSub(body: body))
	}

	public convenience init(_ cv: PerlSub, args: PerlSvConvertible?...) {
		_ = Coro.loadModuleOnce
		var args = args
		args.insert(cv, at: 0)
		try! self.init(method: "new", args: args)
	}

	@discardableResult
	public func ready() -> Bool {
		return withUnsafeSvPointer { sv, perl in Coro.coroApi.pointee.ready!(perl, sv) != 0 }
	}

	public func suspend() { return try! call(method: "suspend") }
	public func resume() { return try! call(method: "resume") }

	public var isNew: Bool { return try! call(method: "is_new") }
	public var isZombie: Bool { return try! call(method: "is_zombie") }

	public var isReady: Bool {
		return withUnsafeSvPointer { sv, perl in Coro.coroApi.pointee.is_ready!(perl, sv) != 0 }
	}

	public var isRunning: Bool { return try! call(method: "is_running") }
	public var isSuspended: Bool { return try! call(method: "is_suspended") }

	// func cancel
	// func safeCancel
	
	// func scheduleTo
	// func cedeTo

	// func throw
	
	public func join<R : PerlSvConvertible>() -> R? { return try! call(method: "join") }

	// func onDestroy
	
	public enum Prio : Int {
		case max    = 3
		case high2  = 2
		case high   = 1
		case normal = 0
		case low    = -1
		case low2   = -2
		case idle   = -3
		case min    = -4
	}

	public var prio: Prio {
		get { return Prio(rawValue: try! call(method: "prio"))! }
		set { return try! call(method: "prio", newValue.rawValue) }
	}

	public func nice(_ change: Int) -> Prio { return Prio(rawValue: try! call(method: "nice", change))! }

	public func desc(_ desc: String) -> String { return try! call(method: "desc", desc) }
}
