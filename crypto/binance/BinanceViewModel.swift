import Foundation

enum SortOrder {
    case ascending
    case descending
    case none
}

enum SortBy {
    case symbol
    case baseAsset
    case quoteAsset
    case averagePrice
}

class BinanceViewModel: ObservableObject {
    @Published var symbols: [Symbol] = []
    @Published var currentPage: Int = 0
    @Published var errorMessage: String? = nil
    @Published var fetching: Bool = false
    @Published var averagePrices: [String: Double] = [:]
    
    var sortOrder: SortOrder = .none
    var sortBy: SortBy = .symbol
    
    let symbolsPerPage: Int = 25

    @Published var searchTerm: String = "" {
        didSet {
            currentPage = 0
        }
    }

    var filteredSymbols: [Symbol] {
        if searchTerm.isEmpty {
            return symbols
        } else {
            return symbols.filter {
                $0.symbol.lowercased().contains(searchTerm.lowercased())
            }
        }
    }

    func sortSymbols(by criteria: SortBy) {
        let comparator: (Symbol, Symbol) -> Bool
        switch criteria {
        case .symbol:
            comparator = { $0.symbol < $1.symbol }
        case .baseAsset:
            comparator = { $0.baseAsset < $1.baseAsset }
        case .quoteAsset:
            comparator = { $0.quoteAsset < $1.quoteAsset }
        case .averagePrice:
            comparator = { (a, b) in
                let priceA = self.averagePrices[a.symbol] ?? 0
                let priceB = self.averagePrices[b.symbol] ?? 0
                return priceA < priceB
            }
        }

        if sortOrder == .ascending || sortBy != criteria {
            symbols.sort(by: comparator)
            sortOrder = .descending
        } else {
            symbols.sort(by: { !comparator($0, $1) })
            sortOrder = .ascending
        }
        sortBy = criteria
    }

    var paginatedSymbols: [Symbol] {
        guard !filteredSymbols.isEmpty else {
            return []
        }
        let start = max(0, currentPage * symbolsPerPage)
        let end = min(start + symbolsPerPage, filteredSymbols.count)
        if start < end {
            return Array(filteredSymbols[start..<end])
        } else {
            return []
        }
    }


    func fetchExchangeInfo() async {
        do {
            DispatchQueue.main.async {
                self.fetching = true
            }
            
            let info = try await BinanceService.shared.fetchExchangeInfo()
            
            DispatchQueue.main.async {
                self.symbols = info.symbols
                self.fetching = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                self.fetching = false
            }
        }
    }
    
    func fetchAveragePrice(symbol: String) async {
        do {
            let avgPrice = try await BinanceService.shared.fetchAveragePrice(symbol: symbol)
            DispatchQueue.main.async {
                self.averagePrices[symbol] = Double(avgPrice.price)
            }
        } catch {
            print("Failed to fetch average price for \(symbol): \(error)")
        }
    }

    func nextPage() {
        if currentPage < (symbols.count / symbolsPerPage) {
            currentPage += 1
        }
    }

    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}
