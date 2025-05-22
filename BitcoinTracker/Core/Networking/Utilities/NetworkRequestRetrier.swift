import Foundation

/// A utility class that implements exponential backoff retry logic for network requests.
/// The retrier will attempt to retry failed network requests with increasing delays between attempts.
final class NetworkRequestRetrier: Sendable {
    /// The maximum number of retry attempts before giving up
    private let maxRetries: Int
    /// The base delay (in seconds) between retry attempts
    private let baseDelay: TimeInterval
    /// The maximum delay (in seconds) between retry attempts
    private let maxDelay: TimeInterval
    
    /// Initialize a new NetworkRequestRetrier
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts (default: 3)
    ///   - baseDelay: Initial delay between retries in seconds (default: 1)
    ///   - maxDelay: Maximum delay between retries in seconds (default: 10)
    init(maxRetries: Int = 3, baseDelay: TimeInterval = 1, maxDelay: TimeInterval = 10) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
    }
    
    /// Executes a network request with retry logic
    /// - Parameter operation: The async operation to retry
    /// - Returns: The result of the operation if successful
    /// - Throws: The last error encountered if all retries fail
    func execute<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        var currentDelay = baseDelay
        
        for attempt in 0...maxRetries {
            do {
                // If this isn't our first attempt, wait before retrying
                if attempt > 0 {
                    try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                }
                
                return try await operation()
            } catch let error as NetworkError {
                // Don't retry for certain types of errors
                switch error {
                case .invalidURL:
                    throw error
                case .serverError(let statusCode, _) where statusCode >= 400 && statusCode < 500:
                    // Don't retry client errors (4xx)
                    throw error
                default:
                    lastError = error
                }
            } catch {
                lastError = error
            }
            
            // Exponential backoff: double the delay for next attempt
            currentDelay = min(currentDelay * 2, maxDelay)
        }
        
        throw lastError!
    }
}
