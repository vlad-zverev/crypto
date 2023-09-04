import SwiftUI
import Foundation


@available(iOS 15.0, *)
struct ContentView: View {
    @StateObject private var viewModel = BinanceViewModel()

    var body: some View {
        VStack {
            if !viewModel.symbols.isEmpty && !viewModel.fetching {
                SymbolsListView(viewModel: viewModel)
            } else if viewModel.fetching {
                Text("Updating...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
            }
            
            BinanceButtonView(viewModel: viewModel)
        }
        .padding()
    }
}

struct SymbolsListView: View {
    let width: CGFloat? = 200
    @ObservedObject var viewModel: BinanceViewModel
    @State private var currentPrice: Double = 0.0

    var body: some View {
        VStack {
            searchField
            header
            symbolsList
            PaginationView(viewModel: viewModel)
            symbolsCount
        }
        .padding()
    }
    
    private var searchField: some View {
        TextField("Search Symbols...", text: $viewModel.searchTerm)
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.bottom, 10)
    }

    private var header: some View {
        HStack {
            sortingButton(for: .symbol, title: "Symbol")
                .frame(width: width, alignment: .leading)
            sortingButton(for: .baseAsset, title: "Base Asset")
                .frame(width: width, alignment: .leading)
            sortingButton(for: .quoteAsset, title: "Quote Asset")
                .frame(width: width, alignment: .leading)
            sortingButton(for: .averagePrice, title: "Average Price")
                .frame(width: width, alignment: .leading)
            Spacer().frame(width: width)
        }
        .padding(.vertical, 5)
    }

    private func sortingButton(for criteria: SortBy, title: String) -> some View {
        Button(action: {
            viewModel.sortSymbols(by: criteria)
        }) {
            HStack {
                Text(title).bold()
                sortingIndicator(for: criteria)
            }
        }
    }

    private func sortingIndicator(for criteria: SortBy) -> some View {
        Group {
            if viewModel.sortBy == criteria {
                switch viewModel.sortOrder {
                case .ascending:
                    Image(systemName: "arrow.up")
                case .descending:
                    Image(systemName: "arrow.down")
                case .none:
                    Image(systemName: "arrow.up.arrow.down")
                }
            } else {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }

    private var symbolsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.paginatedSymbols, id: \.symbol) { symbol in
                    HStack {
                        Text(symbol.symbol)
                            .frame(width: width, alignment: .leading)
                        Text(symbol.baseAsset)
                            .frame(width: width, alignment: .leading)
                        Text(symbol.quoteAsset)
                            .frame(width: width, alignment: .leading)
                        Text(String(viewModel.averagePrices[symbol.symbol] ?? 0))
                            .frame(width: width, alignment: .leading)
                        fetchPriceButton(for: symbol.symbol)
                    }
                    Divider()
                }
            }
        }
    }
    
    private func fetchPriceButton(for symbol: String) -> some View {
        Button("Fetch price") {
            Task {
                await viewModel.fetchAveragePrice(symbol: symbol)
            }
        }
        .frame(minWidth: 0, maxWidth: width, alignment: .leading)
        .padding(.leading)
    }
    
    private var symbolsCount: some View {
        HStack {
            Spacer()
            Text("Symbols: \(viewModel.filteredSymbols.count)")
                .padding(.bottom, 5)
                .padding(.trailing, 5)
                .foregroundColor(.gray)
        }
    }
}

struct PaginationView: View {
    @ObservedObject var viewModel: BinanceViewModel

    var body: some View {
        HStack {
            Button(action: viewModel.previousPage) {
                Image(systemName: "arrow.left")
            }
            .disabled(viewModel.currentPage == 0)
            
            Text("\(viewModel.currentPage + 1)")
            
            Button(action: viewModel.nextPage) {
                Image(systemName: "arrow.right")
            }
            .disabled(viewModel.paginatedSymbols.count < viewModel.symbolsPerPage)
        }
        .padding()
    }
}

struct BinanceButtonView: View {
    @ObservedObject var viewModel: BinanceViewModel

    var body: some View {
        VStack {
            Button("Binance") {
                Task {
                    await viewModel.fetchExchangeInfo()
                }
            }
            .padding(.top)
            
            Image(systemName: viewModel.symbols.isEmpty ? "cursor.rays" : "repeat")
                .imageScale(.large)
                .foregroundColor(.accentColor)
        }
    }
}
