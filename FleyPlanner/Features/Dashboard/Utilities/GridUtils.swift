//
//  Utils.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 3/8/25.
//

import SwiftUI

func calculateAbsolutePositions(in geometry: GeometryProxy, widgets: [Widget]) -> [UUID: CGRect] {
    let totalWidth = geometry.size.width - (SPACING * 2) - (PADDING * 2)
    let fullWidth = totalWidth
    let mediumWidth = (totalWidth - SPACING) / 2
    let widgetHeight: CGFloat = mediumWidth
    
    var positions: [UUID: CGRect] = [:]
    var currentY: CGFloat = SPACING
    var i = 0
    
    while i < widgets.count {
        let widget = widgets[i]
        
        if widget.size == .wide {
            let rect = CGRect(
                x: SPACING,
                y: currentY,
                width: fullWidth,
                height: widgetHeight
            )
            positions[widget.id] = rect
            currentY += widgetHeight + SPACING
            i += 1
        } else {
            // Medium widget (izquierda)
            let leftRect = CGRect(
                x: SPACING,
                y: currentY,
                width: mediumWidth,
                height: widgetHeight
            )
            positions[widget.id] = leftRect
            
            // Verificar si hay un segundo widget medium
            if i + 1 < widgets.count && widgets[i + 1].size == .small {
                let rightWidget = widgets[i + 1]
                let rightRect = CGRect(
                    x: SPACING + mediumWidth + SPACING,
                    y: currentY,
                    width: mediumWidth,
                    height: widgetHeight
                )
                positions[rightWidget.id] = rightRect
                i += 2
            } else {
                i += 1
            }
            
            currentY += widgetHeight + SPACING
        }
    }
    
    return positions
}

// MARK: - Reorder Logic
func reorderedWidgetsIfNeeded(
    dragLocation: CGPoint,
    geometry: GeometryProxy,
    positions: [UUID: CGRect],
    widgets: [Widget],
    selectedWidget: Widget,
    scrollOffset: CGFloat,
    widgetTargetForGrouping: UUID?
) -> (widgetList: [Widget]?, groupingTarget: UUID?) {
    let localPoint = CGPoint(
        x: dragLocation.x - geometry.frame(in: .named("scroll")).origin.x,
        y: dragLocation.y + scrollOffset
    )
    
    var possibleGroupingTarget: UUID? = nil
    
    if selectedWidget.size != .wide {
        // Frame del widget arrastrado (ajustado por su desplazamiento actual)
        let draggedFrame = positions[selectedWidget.id] ?? .zero
        let offset = CGPoint(x: localPoint.x - draggedFrame.midX, y: localPoint.y - draggedFrame.midY)
        let movedFrame = draggedFrame.offsetBy(dx: offset.x, dy: offset.y)
        
        // Encontrar el widget con mayor solapamiento significativo
        var bestOverlap: CGFloat = 0.0
        for (id, frame) in positions where id != selectedWidget.id {
            let intersection = movedFrame.intersection(frame)
            if !intersection.isNull {
                let overlapArea = intersection.width * intersection.height
                let draggedArea = movedFrame.width * movedFrame.height
                let overlapRatio = overlapArea / draggedArea
                
                if overlapRatio > 0.15 && overlapRatio > bestOverlap {
                    bestOverlap = overlapRatio
                    possibleGroupingTarget = id
                }
            }
        }
    }
    
    guard
        let currentIndex = widgets.firstIndex(where: { $0.id == selectedWidget.id }),
        let fallingEntry = positions.first(where: { $0.value.contains(localPoint) }),
        fallingEntry.key != selectedWidget.id
    else {
        return (nil, possibleGroupingTarget)
    }
    
    let targetID = fallingEntry.key
    guard let targetIndex = widgets.firstIndex(where: { $0.id == targetID }) else {
        return (nil, possibleGroupingTarget)
    }
    
    var tempWidgets = widgets
    let dragged = tempWidgets[currentIndex]
    let target = tempWidgets[targetIndex]
    
    let rows = groupWidgetsIntoRows(tempWidgets)
    guard
        let fromRowIndex = findRowIndex(containing: dragged.id, in: rows),
        let toRowIndex = findRowIndex(containing: target.id, in: rows)
    else {
        return (nil, possibleGroupingTarget)
    }
    
    // 🔁 medium vs medium
    if dragged.size == .small && target.size == .small {
        tempWidgets.swapAt(currentIndex, targetIndex)
        let repacked = compactWidgets(tempWidgets)
        return (repacked.map(\.id) != widgets.map(\.id) ? repacked : nil, possibleGroupingTarget)
    }
    
    // 🔁 resto — intercambio de filas
    if fromRowIndex != toRowIndex {
        var newRows = rows
        let fromRow = newRows.remove(at: fromRowIndex)
        newRows.insert(fromRow, at: toRowIndex)
        let newFlat = newRows.flatMap { $0 }
        return (newFlat.map(\.id) != widgets.map(\.id) ? newFlat : nil, possibleGroupingTarget)
    }
    
    return (nil, possibleGroupingTarget)
}


// MARK: - Packing Algorithm
func compactWidgets(_ widgets: [Widget]) -> [Widget] {
    var result: [Widget] = []
    var queue: [Widget] = widgets
    
    while !queue.isEmpty {
        let first = queue.removeFirst()
        
        if first.size == .wide {
            result.append(first)
        } else {
            if let secondIndex = queue.firstIndex(where: { $0.size == .small }) {
                let second = queue.remove(at: secondIndex)
                result.append(first)
                result.append(second)
            } else {
                result.append(first)
            }
        }
    }
    
    return result
}

func groupWidgetsIntoRows(_ widgets: [Widget]) -> [[Widget]] {
    var rows: [[Widget]] = []
    var queue = widgets
    
    while !queue.isEmpty {
        let first = queue.removeFirst()
        if first.size == .wide {
            rows.append([first])
        } else {
            if let secondIndex = queue.firstIndex(where: { $0.size == .small }) {
                let second = queue.remove(at: secondIndex)
                rows.append([first, second])
            } else {
                rows.append([first])
            }
        }
    }
    return rows
}

func findRowIndex(containing id: UUID, in rows: [[Widget]]) -> Int? {
    return rows.firstIndex(where: { row in
        row.contains(where: { $0.id == id })
    })
}

// MARK: - Detección de solapamiento entre widgets
//func isOverlappingEnough(_ rect1: CGRect, _ rect2: CGRect, threshold: CGFloat = groupingThreshold) -> Bool {
//    let intersection = rect1.intersection(rect2)
//    return intersection.width >= threshold && intersection.height >= threshold
//}

// MARK: shadow animation

func shadowSyncAnimation(for scale: CGFloat, maxRadius: CGFloat) -> CGFloat {
    // Asumimos un rango razonable de escala
    let minScale: CGFloat = 1.0
    // Es lo que se usa habitualmente en gestos de "lift",
    // como cuando arrastras una carta, un botón, o haces un hover.
    // Es sutil pero perceptible, sin romper la jerarquía visual.
    // Visualmente acompaña bien con sombras de radio entre 10–20pts.
    let maxScale: CGFloat = 1.05
    
    // Normalizamos la escala a un rango de 0 a 1
    let progress = max(0, min(1, (scale - minScale) / (maxScale - minScale)))
    
    // Interpolamos el radio de la sombra
    return progress * maxRadius
}
