//
//  DataService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation

protocol DataService {
    func getUser(id: UUID) async -> User
    func getAllUsers() async -> [User]
    func getChildren(for userId: UUID) async -> [Child]
    func getChildBonds(for userId: UUID) async -> [ChildBond]
    func getEvents(for userId: UUID) async -> [CalendarEvent]
    func getExpenses(for userId: UUID) async -> [Expense]
    func getCareItems(for userId: UUID) async -> [CareItem]
}
