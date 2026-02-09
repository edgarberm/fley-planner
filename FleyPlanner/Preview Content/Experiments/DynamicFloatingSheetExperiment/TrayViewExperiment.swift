//
//  TrayViewExperiment.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 9/2/26.
//

import SwiftUI

enum CurrentView {
    case stepOne
    case stepTwo
}

struct TrayViewExperiment: View {
    @State private var show: Bool = false
    @State private var currentView: CurrentView = .stepOne
    
    var body: some View {
        Button("Tray") {
            show.toggle()
        }
        .systemTrayView($show) {
            VStack(spacing: 20) {
                ZStack {
                    switch currentView {
                        case .stepOne:
                            ViewOne()
                                .transition(.blurReplace)
                        case .stepTwo:
                            ViewTwo()
                                .transition(.blurReplace)
                    }
                }
                .compositingGroup()
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    func ViewOne() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Step 1")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    show = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
                }
            }
            
            Text("Some text too long goes here to test if the sheet height changes properly")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.bottom, 20)

            
            /// Next
            Button {
                withAnimation(.bouncy) {
                    currentView = .stepTwo
                }
            } label: {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(.black, in: .capsule)
            }
        }
    }
    
    @ViewBuilder
    func ViewTwo() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Step 2")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    show = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
                }
            }
            
            Text("Some text too long goes here to test if the sheet height changes properly")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.bottom, 20)
            
            Text("Some text too long goes here to test if the sheet height changes properly")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.bottom, 20)
            
            Text("Some text too long goes here to test if the sheet height changes properly")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.bottom, 20)
            
            Button {
                withAnimation(.bouncy) {
                    currentView = .stepOne
                }
            } label: {
                Text("Prev")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(.black, in: .capsule)
            }
        }
    }
}

#Preview {
    TrayViewExperiment()
}
