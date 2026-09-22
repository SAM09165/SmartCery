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
    @State private var isScrolled = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Input Row
                HStack(spacing: 10) {
                    TextField("Add item (e.g., Organic Milk, Oats)...", text: $newItem)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                        )
                        .submitLabel(.done)
                        .onSubmit(addItem)

                    Button(action: addItem) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppTheme.elevatedSurface)
                            .frame(width: 42, height: 42)
                            .background(AppTheme.primary, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add grocery item")
                    .disabled(newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.sm)

                if store.groceryList.isEmpty {
                    VStack(spacing: 14) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(AppTheme.surface)
                                .frame(width: 64, height: 64)

                            Image(systemName: "checklist")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(AppTheme.primary)
                        }

                        Text("Your Grocery List is Empty")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Add items manually above or tap 'Add to List' from recipes and pantry.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(store.groceryList) { item in
                            HStack(spacing: 12) {
                                Button {
                                    HapticManager.impact(.light)
                                    store.toggleGroceryItem(item.id)
                                } label: {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(item.isChecked ? Color.green : AppTheme.warmAccent)
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .strikethrough(item.isChecked)
                                        .foregroundStyle(item.isChecked ? AppTheme.textSecondary : AppTheme.textPrimary)

                                    if !item.quantity.isEmpty {
                                        Text(item.quantity)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(AppTheme.elevatedSurface)
                            .swipeActions {
                                Button(role: .destructive) {
                                    HapticManager.impact(.medium)
                                    store.removeGroceryItem(item.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Grocery List",
                    subtitle: "\(store.groceryList.count) items listed",
                    trailingIcon: "trash",
                    onTrailingTap: {
                        HapticManager.impact(.medium)
                        for item in store.groceryList.filter({ $0.isChecked }) {
                            store.removeGroceryItem(item.id)
                        }
                    },
                    isScrolled: isScrolled
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        HapticManager.impact(.light)
        store.addGroceryItem(name: trimmed)
        newItem = ""
    }
}

#Preview {
    GroceryListView()
        .environmentObject(AppStore())
}
