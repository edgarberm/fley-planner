//
//  ContentView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct ContentView: View {
//    @Environment(AppState.self) private var appState
//    @State private var viewModel: DashboardViewModel?
    
    @State private var model = WidgetGridModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WidgetGrid()
        }
        .environment(model)
        
//        NavigationStack {
//            Group {
//                if let viewModel, let context = viewModel.context {
//                    DashboardContentView(context: context)
//                } else if viewModel?.isLoading == true {
//                    ProgressView("Loading...")
//                } else if let user = appState.currentUser {
//                    ProgressView("Initializing...")
//                        .task {
//                            await loadDashboard(for: user)
//                        }
//                } else {
//                    Text("Not authenticated")
//                }
//            }
//            .navigationTitle("Dashboard")
//        }
    }
    
//    private func loadDashboard(for user: User) async {
//        let vm = DashboardViewModel(
//            dataService: appState.dataService,
//            currentUserId: user.id
//        )
//        viewModel = vm
//        await vm.load()
//    }
}

// MARK: - Dashboard Content

struct DashboardContentView: View {
    let context: DashboardContext
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // User Info
                UserSection(user: context.currentUser)
                
                // Balance
                BalanceSection(balance: context.totalBalance)
                
                // Children
                ChildrenSection(children: context.activeChildren)
                
                // Upcoming Events
                EventsSection(events: context.upcomingEvents)
                
                // Pending Expenses
                ExpensesSection(expenses: context.pendingExpenses)
            }
            .padding()
        }
    }
}

// MARK: - User Section

struct UserSection: View {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

// MARK: - Balance Section

struct BalanceSection: View {
    let balance: UserBalance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Balance")
                .font(.headline)
            
            HStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("You owe")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatAmount(balance.owed))
                        .font(.title2.bold())
                        .foregroundStyle(.red)
                }
                
                VStack(alignment: .leading) {
                    Text("Owed to you")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatAmount(balance.owedTo))
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                }
            }
            
            Divider()
            
            HStack {
                Text("Net Balance")
                    .font(.subheadline)
                Spacer()
                Text(balance.formattedNet)
                    .font(.title3.bold())
                    .foregroundStyle(balance.net >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "€0.00"
    }
}

// MARK: - Children Section

struct ChildrenSection: View {
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
        VStack(alignment: .leading, spacing: 8) {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    private var ageText: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: summary.child.birthDate, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years) year\(years > 1 ? "s" : "") old"
        } else if let months = components.month {
            return "\(months) month\(months > 1 ? "s" : "") old"
        }
        return "Newborn"
    }
}

// MARK: - Events Section

struct EventsSection: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.headline)
            
            if events.isEmpty {
                Text("No upcoming events")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(events) { event in
                    EventRow(event: event)
                }
            }
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.type.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

// MARK: - Expenses Section

struct ExpensesSection: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pending Expenses")
                .font(.headline)
            
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
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
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

// MARK: - Preview

#Preview {
    @Previewable @State var appState = AppState(dataService: MockDataService.shared)
    
    ContentView()
        .environment(appState)
        .task {
            await appState.signIn(userId: MockData.shared.edgar.id)
        }
}
