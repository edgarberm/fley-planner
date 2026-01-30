//
//  Widgets.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 4/8/25.
//

import SwiftUI

enum CardType {
    case visa
    case mastercard
}

struct ExpirationDate {
    let month: Int  // 1...12
    let year: Int   // año en formato 2 dígitos o 4 dígitos

    // Añadir validaciones, e.g. mes válido y año razonable.
}

extension String {
    func formattedCardNumber(for size: WidgetSize) -> String {
        let last4 = String(suffix(4))
        let bullet = "•" // Puedes probar con "⬤", "●", "◉", etc.
        
        switch size {
        case .medium:
            return "\(bullet)\(bullet)\(bullet)\(bullet) \(last4)"
        case .wide:
            return "\(bullet)\(bullet)\(bullet)\(bullet) \(bullet)\(bullet)\(bullet)\(bullet) \(bullet)\(bullet)\(bullet)\(bullet) \(last4)"
        }
    }
}

extension String {
    func chunked(by length: Int) -> [String] {
        stride(from: 0, to: count, by: length).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
}


struct ExampleWidgetView: View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Widget title here")
                    .font(.headline)
                Text("Subtitle here")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
        }
        .foregroundColor(Color.primary)
        .padding()
        .cornerRadius(RADIUS)
        .clipped()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white) // TODO: widget color
    }
}

//struct CardWidgetView: View {
//    let size: WidgetSize
//    let type: CardType
//    let name: String
//    let bank: String
//    let number: String
//    let expiration: ExpirationDate
//    var color: Color?
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                IridescentChipView(baseColor: color ?? .gray)
//                
//                Spacer()
//                
//                Image("\(type)-gray")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: type == .mastercard ? 20 : 16)
//            }
//            
//            Spacer()
//            
//            VStack(alignment: .leading) {
//                Text(name)
//                    .font(.headline)
//                Text(bank)
//                    .font(.subheadline)
//                    .foregroundColor(Color.secondary)
//                
//                HStack {
//                    Text(number.formattedCardNumber(for: size))
//                        .font(.system(.body, design: .monospaced))
//                        .padding(.top, 2)
//                    
//                    if size == .wide {
//                        Spacer()
//                        
//                        Text("\(expiration.month)/\(expiration.year)")
//                            .font(.body)
//                            .foregroundColor(Color.secondary)
//                    }
//                }
//            }
//        }
//        .padding(18)
//        .cornerRadius(RADIUS)
//        .clipped()
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        .background(Color.white) // TODO: widget color
//    }
//}

//struct IridescentChipView: View {
//    let baseColor: Color
//    
//    private let width: CGFloat = 31
//    private let height: CGFloat = 25
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8, style: .continuous)
//                .fill(baseColor)
//                .frame(width: width, height: height)
////                .blendMode(.screen)
//            
//            RoundedRectangle(cornerRadius: 8, style: .continuous)
//                .fill(
//                    AngularGradient(
//                        gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
//                        center: .center,
//                        angle: .degrees(20)
//                    )
//                )
//                .blur(radius: 0.6)
//                .opacity(0.6)
//                .blendMode(.screen)
//                .frame(width: width, height: height)
//
//            Image("card-chip")
//                .resizable()
//                .scaledToFit()
//                .frame(width: width + 2, height: height + 2)
//                .foregroundColor(.white)
//        }
//        .frame(width: width, height: height)
//    }
//}


//struct CreateLockWidgetView: View {
//    var body: some View {
//        VStack(alignment: .center) {
//            Text("Create Lock")
//                    .font(.headline)
//            
//            Spacer()
//            
//            HStack(alignment: .center) {
//                Button(action: {
//                    
//                }) {
//                    Image("plus")
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.white)
//                        .frame(width: 24, height: 24)
//                }
//                .frame(width: 50, height: 50)
//                .background(.black)
//                .clipShape(Circle())
//                
//                Button(action: {
//                    
//                }) {
//                    Image("plus")
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.white)
//                        .frame(width: 24, height: 24)
//                }
//                .frame(width: 50, height: 50)
//                .background(.black)
//                .clipShape(Circle())
//                
//                Button(action: {
//                    
//                }) {
//                    Image("plus")
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.white)
//                        .frame(width: 24, height: 24)
//                }
//                .frame(width: 50, height: 50)
//                .background(.black)
//                .clipShape(Circle())
//                
//                Button(action: {
//                    
//                }) {
//                    Image("plus")
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.white)
//                        .frame(width: 24, height: 24)
//                }
//                .frame(width: 50, height: 50)
//                .background(.black)
//                .clipShape(Circle())
//                
//                Button(action: {
//                    
//                }) {
//                    Image("plus")
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.white)
//                        .frame(width: 24, height: 24)
//                }
//                .frame(width: 50, height: 50)
//                .background(.black)
//                .clipShape(Circle())
//            }
//            .frame(maxWidth: .infinity, alignment: .center)
//            .padding(.horizontal, 0)
//        }
//        .foregroundColor(Color.primary)
//        .padding()
//        .cornerRadius(RADIUS)
//        .clipped()
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        .background(Color.white) // TODO: widget color
//    }
//}
