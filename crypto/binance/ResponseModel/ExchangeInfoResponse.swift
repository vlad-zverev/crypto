import Foundation

struct ExchangeInfoResponse: Codable {
    let timezone: String
    let serverTime: Int64
    let rateLimits: [RateLimit]
    let exchangeFilters: [String]
    let symbols: [Symbol]
}

struct RateLimit: Codable {
    let rateLimitType: String
    let interval: String
    let intervalNum: Int
    let limit: Int
}

struct Symbol: Codable {
    let symbol: String
    let status: String
    let baseAsset: String
    let baseAssetPrecision: Int
    let quoteAsset: String
    let quotePrecision: Int
    let quoteAssetPrecision: Int
    let baseCommissionPrecision: Int
    let quoteCommissionPrecision: Int
    let orderTypes: [String]
    let icebergAllowed: Bool
    let ocoAllowed: Bool
    let quoteOrderQtyMarketAllowed: Bool
    let allowTrailingStop: Bool
    let cancelReplaceAllowed: Bool
    let isSpotTradingAllowed: Bool
    let isMarginTradingAllowed: Bool
    let filters: [Filter]
    let permissions: [String]
    let defaultSelfTradePreventionMode: String
    let allowedSelfTradePreventionModes: [String]
}

struct Filter: Codable {
    let filterType: String
    
    let minPrice: String?
    let maxPrice: String?
    let tickSize: String?
    
    let minQty: String?
    let maxQty: String?
    let stepSize: String?
    
    let limit: Int?
    
    let minTrailingAboveDelta: Int?
    let maxTrailingAboveDelta: Int?
    let minTrailingBelowDelta: Int?
    let maxTrailingBelowDelta: Int?
    
    let bidMultiplierUp: String?
    let bidMultiplierDown: String?
    let askMultiplierUp: String?
    let askMultiplierDown: String?
    let avgPriceMins: Int?
    
    let minNotional: String?
    let applyMinToMarket: Bool?
    let maxNotional: String?
    let applyMaxToMarket: Bool?
    
    let maxNumOrders: Int?
    
    let maxNumAlgoOrders: Int?
}
