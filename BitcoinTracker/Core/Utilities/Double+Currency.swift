import Foundation

enum Currency {
    case eur
    case usd
    case gbp
    
    var code: String {
        switch self {
        case .eur: return "EUR"
        case .usd: return "USD"
        case .gbp: return "GBP"
        }
    }
}

extension Double {
    func formatAsCurrency(_ currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        guard let formatted = formatter.string(from: Decimal(self) as NSDecimalNumber) else {
            assertionFailure("Failed to format price: \(self)")
            return "Error"
        }
        return formatted
    }
}
