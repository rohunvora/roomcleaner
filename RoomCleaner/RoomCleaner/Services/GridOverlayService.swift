import UIKit
import CoreGraphics

/// Service to add grid overlays to images for better spatial detection with GPT-4 Vision
class GridOverlayService {
    
    struct GridConfig {
        let rows: Int
        let columns: Int
        let lineWidth: CGFloat
        let lineColor: UIColor
        let labelColor: UIColor
        let labelFontSize: CGFloat
        let overlayOpacity: CGFloat
        
        static let `default` = GridConfig(
            rows: 5,
            columns: 5,
            lineWidth: 2.0,
            lineColor: .systemBlue,
            labelColor: .systemBlue,
            labelFontSize: 20.0,
            overlayOpacity: 0.6
        )
    }
    
    /// Add a numbered grid overlay to an image
    static func addGridOverlay(to image: UIImage, config: GridConfig = .default) -> UIImage? {
        let imageSize = image.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("GridOverlayService: Failed to create graphics context")
            return nil
        }
        
        // Draw the original image
        image.draw(at: .zero)
        
        // Calculate cell dimensions
        let cellWidth = imageSize.width / CGFloat(config.columns)
        let cellHeight = imageSize.height / CGFloat(config.rows)
        
        // Set up drawing attributes
        context.setLineWidth(config.lineWidth)
        context.setStrokeColor(config.lineColor.withAlphaComponent(config.overlayOpacity).cgColor)
        
        // Draw vertical lines
        for i in 0...config.columns {
            let x = CGFloat(i) * cellWidth
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: imageSize.height))
        }
        
        // Draw horizontal lines
        for i in 0...config.rows {
            let y = CGFloat(i) * cellHeight
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: imageSize.width, y: y))
        }
        
        context.strokePath()
        
        // Add cell labels
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: config.labelFontSize),
            .foregroundColor: config.labelColor.withAlphaComponent(config.overlayOpacity),
            .paragraphStyle: paragraphStyle
        ]
        
        for row in 0..<config.rows {
            for col in 0..<config.columns {
                let cellID = getCellID(row: row, col: col)
                let cellRect = CGRect(
                    x: CGFloat(col) * cellWidth,
                    y: CGFloat(row) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                
                // Draw label in center of cell
                let labelRect = CGRect(
                    x: cellRect.midX - 20,
                    y: cellRect.midY - 10,
                    width: 40,
                    height: 20
                )
                
                cellID.draw(in: labelRect, withAttributes: attributes)
            }
        }
        
        let gridImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gridImage
    }
    
    /// Convert row/column to cell ID (e.g., A1, B2, C3)
    static func getCellID(row: Int, col: Int) -> String {
        let letter = String(Character(UnicodeScalar(65 + col)!)) // A, B, C...
        let number = row + 1
        return "\(letter)\(number)"
    }
    
    /// Convert cell ID back to coordinates
    static func getCellCoordinates(cellID: String, imageSize: CGSize, gridConfig: GridConfig = .default) -> CGRect? {
        guard cellID.count >= 2 else {
            print("GridOverlayService: Invalid cell ID format: \(cellID)")
            return nil
        }
        
        let letter = cellID.prefix(1)
        let numberString = cellID.dropFirst()
        
        guard let firstChar = letter.first,
              let col = Int(firstChar.asciiValue! - 65),
              let row = Int(numberString)?.advanced(by: -1),
              col >= 0 && col < gridConfig.columns,
              row >= 0 && row < gridConfig.rows else {
            print("GridOverlayService: Failed to parse cell ID: \(cellID)")
            return nil
        }
        
        let cellWidth = imageSize.width / CGFloat(gridConfig.columns)
        let cellHeight = imageSize.height / CGFloat(gridConfig.rows)
        
        return CGRect(
            x: CGFloat(col) * cellWidth,
            y: CGFloat(row) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
    }
    
    /// Extract multiple cell IDs from a range (e.g., "B2-C3")
    static func parseCellRange(_ range: String, imageSize: CGSize, gridConfig: GridConfig = .default) -> [CGRect] {
        let components = range.split(separator: "-").map(String.init)
        
        if components.count == 1 {
            // Single cell
            if let rect = getCellCoordinates(cellID: components[0], imageSize: imageSize, gridConfig: gridConfig) {
                return [rect]
            }
        } else if components.count == 2 {
            // Range of cells
            guard let startRect = getCellCoordinates(cellID: components[0], imageSize: imageSize, gridConfig: gridConfig),
                  let endRect = getCellCoordinates(cellID: components[1], imageSize: imageSize, gridConfig: gridConfig) else {
                print("GridOverlayService: Invalid cell range: \(range)")
                return []
            }
            
            // Calculate the bounding box that includes both cells
            let minX = min(startRect.minX, endRect.minX)
            let minY = min(startRect.minY, endRect.minY)
            let maxX = max(startRect.maxX, endRect.maxX)
            let maxY = max(startRect.maxY, endRect.maxY)
            
            return [CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)]
        }
        
        print("GridOverlayService: Unrecognized cell range format: \(range)")
        return []
    }
} 