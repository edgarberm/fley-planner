//
//  Widgets.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

// MARK: - Today widget
struct TodayWidgetView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(user.name)
                .font(.title.bold())
            
            HStack {
                Image(systemName: user.accountType == .adult ? "person.fill" : "person.crop.circle")
                Text(user.accountType == .adult ? "Adult Account" : "Teen Account")
                
                if user.isPremium {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Premium")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// MARK: - Events widget
struct EventsWidgetView: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if events.isEmpty {
                Text("No upcoming events")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(events.prefix(2)) { event in
                    EventRow(event: event)
                }
            }
        }
        .padding()
    }
}

struct EventRow: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: event.type.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline.bold())
                
                HStack {
                    Text(event.startDate, style: .date)
                    Text("at")
                    Text(event.startDate, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if let location = event.location {
                    Label(location, systemImage: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(event.type.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
}

// MARK: - Balance widget
struct BalanceWidgetView: View {
    let balance: UserBalance
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Balance")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("You owe")
                    Text(balance.owed.formatted(.currency(code: "EUR")))
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading) {
                    Text("Owed to you")
                    Text(balance.owedTo.formatted(.currency(code: "EUR")))
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
    }
}

// MARK: - Expenses widget
struct ExpensesWidgetView: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if expenses.isEmpty {
                Text("All expenses settled!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(expenses) { expense in
                    ExpenseRow(expense: expense)
                }
            }
        }
        .padding()
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: categoryIcon)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.subheadline.bold())
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(expense.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formatAmount(expense.totalAmount))
                    .font(.headline)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private var categoryIcon: String {
        switch expense.category {
            case .medical: return "cross.case.fill"
            case .education: return "book.fill"
            case .clothing: return "tshirt.fill"
            case .extracurricular: return "sportscourt.fill"
            case .food: return "fork.knife"
            case .other: return "tag.fill"
        }
    }
    
    private var statusText: String {
        switch expense.status {
            case .pending: return "Pending"
            case .partiallySettled: return "Partial"
            case .settled: return "Settled"
        }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "€0.00"
    }
}

// MARK: - Children widget

struct ChildrenWidgetView: View {
    let children: [DashboardContext.ChildSummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Children")
                .font(.headline)
            
            ForEach(children, id: \.child.id) { summary in
                ChildCard(summary: summary)
            }
        }
    }
}

struct ChildCard: View {
    let summary: DashboardContext.ChildSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading) {
                    Text(summary.child.name)
                        .font(.title3.bold())
                    
                    Text(ageText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                if summary.isWithCurrentUser {
                    Label("With you", systemImage: "house.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                } else if let caregiver = summary.currentCaregiver {
                    Label("With \(caregiver.name)", systemImage: "person.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
            
            // Next event
            if let event = summary.nextEvent {
                Divider()
                
                HStack {
                    Image(systemName: event.type.icon)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.subheadline)
                        Text(event.startDate, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if let location = event.location {
                        Label(location, systemImage: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            // Balance for this child
            if summary.balance.net != 0 {
                Divider()
                
                HStack {
                    Image(systemName: summary.balance.net > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundStyle(summary.balance.net > 0 ? .green : .red)
                    
                    Text(summary.balance.net > 0 ? "Owed to you" : "You owe")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(summary.balance.formattedNet)
                        .font(.subheadline.bold())
                        .foregroundStyle(summary.balance.net > 0 ? .green : .red)
                }
            }
            
            // Unreviewed expenses
            if summary.unreviewedExpenses > 0 {
                Label("\(summary.unreviewedExpenses) pending expense\(summary.unreviewedExpenses > 1 ? "s" : "")",
                      systemImage: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .padding()
    }
    
    private var ageText: String {
        if summary.child.birthDate == nil {
            return "Birth date is not defined"
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: summary.child.birthDate!, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years) year\(years > 1 ? "s" : "") old"
        } else if let months = components.month {
            return "\(months) month\(months > 1 ? "s" : "") old"
        }
        return "Newborn"
    }
}
