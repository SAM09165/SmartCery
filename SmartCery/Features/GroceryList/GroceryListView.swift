//
//  GroceryListView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct GroceryListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var newItem = ""

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    TextField("Add an item", text: $newItem)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(addItem)
                    Button(action: addItem) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(AppTheme.cream)
                            .frame(width: 42, height: 42)
                            .background(AppTheme.basilGreen, in: Circle())
                    }
                    .accessibilityLabel("Add grocery item")
                }
                .padding(20)

                if store.groceryList.isEmpty {
                    ContentUnavailableView("Your list is empty", systemImage: "checklist", description: Text("Add what you need for the week."))
                    Spacer()
                } else {
                    List {
                        ForEach(store.groceryList) { item in
                            HStack(spacing: 12) {
                                Button { store.toggleGroceryItem(item.id) } label: {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(item.isChecked ? AppTheme.basilGreen : AppTheme.zestOrange)
                                }
                                .buttonStyle(.plain)
                                VStack(alignment: .leading) {
                                    Text(item.name).strikethrough(item.isChecked).foregroundStyle(AppTheme.basilGreen)
                                    Text(item.quantity).font(.caption).foregroundStyle(AppTheme.basilGreen.opacity(0.6))
                                }
                            }
                            .swipeActions { Button(role: .destructive) { store.removeGroceryItem(item.id) } label: { Label("Delete", systemImage: "trash") } }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Grocery list")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addItem() { store.addGroceryItem(name: newItem); newItem = "" }
}

#Preview {
    GroceryListView()
        .environmentObject(AppStore())
}
