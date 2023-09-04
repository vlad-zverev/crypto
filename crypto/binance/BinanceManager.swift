import Foundation

class BinanceService {
    let baseUrl: String = "https://api.binance.com/api/"
    let url: String
    let decoder: JSONDecoder = JSONDecoder()

    init(version: String = "v3") {
        url = "\(baseUrl)\(version)/"
    }

    static let shared = BinanceService()
    
    func fetch<T: Codable>(endpoint: String, model: T.Type) async throws -> T {
        let url = URL(string: "\(url)\(endpoint)")!

        let (data, _) = try await URLSession.shared.data(from: url)

        return try decoder.decode(model, from: data)
    }

    func fetchExchangeInfo() async throws -> ExchangeInfoResponse {
        return try await fetch(endpoint: "exchangeInfo", model: ExchangeInfoResponse.self)
    }

    func fetchAveragePrice(symbol: String) async throws -> AveragePriceResponse {
        return try await fetch(endpoint: "avgPrice?symbol=\(symbol)", model: AveragePriceResponse.self)
    }
}
