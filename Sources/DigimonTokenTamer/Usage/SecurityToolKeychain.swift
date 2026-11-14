import Foundation
import Security

/// Reads a generic password through Apple's `/usr/bin/security` tool.
///
/// Fallback for the user-initiated limits refresh only. On some machines `SecItemCopyMatching`
/// answers errSecAuthFailed (-25293) right away, without offering the keychain password dialog —
/// seen with this app while DigiMonTokenBar, asking moments earlier, did get the dialog. Claude
/// Code itself writes its credentials with `security`, so the tool is usually on the item's
/// access list; when it is not, macOS shows its standard "enter the keychain password" dialog
/// for it. The secret travels only through the pipe and is never logged.
enum SecurityToolKeychain {
    static let toolPath = "/usr/bin/security"

    /// The item's data, or nil when the tool fails, is cancelled or times out.
    /// Blocks the calling thread (the keychain prompt can wait for the user); call off the main actor.
    static func readGenericPassword(service: String, account: String? = nil, timeout: TimeInterval = 90) -> Data? {
        guard FileManager.default.isExecutableFile(atPath: toolPath) else { return nil }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        var arguments = ["find-generic-password", "-s", service]
        if let account { arguments += ["-a", account] }
        arguments.append("-w")
        process.arguments = arguments
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        let done = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in done.signal() }
        do { try process.run() } catch {
            AppLog.write("security tool keychain read could not start: \(error)")
            return nil
        }
        // Read while waiting so a large item cannot fill the pipe and stall the tool.
        let data = output.fileHandleForReading.readDataToEndOfFile()
        if done.wait(timeout: .now() + timeout) == .timedOut {
            process.terminate()
            AppLog.write("security tool keychain read timed out")
            return nil
        }
        guard process.terminationStatus == 0 else {
            AppLog.write("security tool keychain read failed: exit \(process.terminationStatus)")
            return nil
        }
        var trimmed = data
        while let last = trimmed.last, last == 0x0a || last == 0x0d { trimmed.removeLast() }
        return trimmed.isEmpty ? nil : trimmed
    }
}
