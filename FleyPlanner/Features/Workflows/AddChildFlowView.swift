//
//  AddChildFlowView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import SwiftUI

struct AddChildFlowView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedRelationship: RelationshipType = .father
    @State private var customRelationship = ""
    @State private var showCustomField = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Add your first child")
                    .font(.title2.bold())
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray, .gray.opacity(0.2))
                }
            }
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Child's name")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .disabled(isLoading)
                }
                
                // Relationship selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your relationship")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Picker("Relationship", selection: $selectedRelationship) {
                        ForEach(RelationshipType.allPredefined, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                        
                        HStack {
                            Image(systemName: "person.circle")
                            Text("Other")
                        }
                        .tag(RelationshipType.other(""))
                    }
                    .pickerStyle(.menu)
                    .disabled(isLoading)
                    .onChange(of: selectedRelationship) { _, newValue in
                        if case .other = newValue {
                            showCustomField = true
                        } else {
                            showCustomField = false
                            customRelationship = ""
                        }
                    }
                    
                    // Custom relationship field
                    if showCustomField {
                        TextField("Specify relationship", text: $customRelationship)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.words)
                            .disabled(isLoading)
                    }
                }
            }
            
            // Error message
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Submit button
            Button {
                Task { await createChild() }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Create child")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(canSubmit ? Color.blue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .disabled(!canSubmit || isLoading)
        }
        .padding(24)
    }
    
    private var canSubmit: Bool {
        !name.isEmpty && (!showCustomField || !customRelationship.isEmpty)
    }
    
    private var finalRelationship: RelationshipType {
        if showCustomField && !customRelationship.isEmpty {
            return .other(customRelationship)
        }
        return selectedRelationship
    }
    
    private func createChild() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await appState.createFirstChild(
                name: name,
                relationship: finalRelationship
            )
            
            dismiss()
            
        } catch let appErr as AppError {
            errorMessage = appErr.localizedDescription
            print(errorMessage as Any)
        } catch {
            errorMessage = "Failed to create child: \(error.localizedDescription)"
            print(errorMessage as Any)
        }
        
        isLoading = false
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    
    AddChildFlowView()
        .environment(appState)
}
