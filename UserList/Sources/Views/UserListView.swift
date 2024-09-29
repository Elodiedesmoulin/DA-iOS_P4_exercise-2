import SwiftUI

struct UserListView: View {
    @StateObject var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if let error = viewModel.error {
                    ErrorView(error: error, retryAction: {
                        viewModel.fetchUsers()
                    })
                } else if !viewModel.isGridView {
                    ListView(users: viewModel.users, loadMore: shouldLoadMoreData, fetchUsers: viewModel.fetchUsers)
                } else {
                    GridView(users: viewModel.users, loadMore: shouldLoadMoreData, fetchUsers: viewModel.fetchUsers)
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker(selection: $viewModel.isGridView, label: Text("Display")) {
                        Image(systemName: "rectangle.grid.1x2.fill")
                            .tag(true)
                            .accessibilityLabel(Text("Grid view"))
                        Image(systemName: "list.bullet")
                            .tag(false)
                            .accessibilityLabel(Text("List view"))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.reloadUsers()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.large)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
        
        .alert(isPresented: .constant(viewModel.error != nil && viewModel.error?.errorDescription == "An unexpected error occurred")) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.error?.localizedDescription ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    viewModel.error = nil
                }
            )
        }
    }
    
    private func shouldLoadMoreData(currentItem item: User) -> Bool {
        guard let lastItem = viewModel.users.last else { return false }
        return !viewModel.isLoading && item.id == lastItem.id
    }
}

#Preview {
    UserListView()
}
