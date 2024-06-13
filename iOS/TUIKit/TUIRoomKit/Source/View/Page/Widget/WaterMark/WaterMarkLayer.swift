//
//  WaterMarkLayer.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/4/3.
//

import Foundation

class WaterMarkLayer: CALayer {
    var text: String = ""
    var textColor: UIColor = UIColor(0x99A2B2).withAlphaComponent(0.3)
    var lineStyle: WaterMarkLineStyle = .multiLine
    private var portraitImage: UIImage?
    private var landscapeImage: UIImage?
    private let multiLineTextFontSize = 14.0
    private let sigleLineTextFontSize = 36.0
    private let singleLineWaterMarkWidth = 303.scale375()
    private let multiLineWaterMarkWidth = 118.scale375()
    private let offset = 39.scale375()
    private var numberOfOneRow: Int {
        isLandscape ? 4 : 3
    }
    private var numberOfOneColumn: Int {
        isLandscape ? 3 : 4
    }
    private var textMinOffset: CGFloat {
        return lineStyle == .multiLine ? 2 : 4
    }
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        let rect:CGRect = .init(origin: .zero, size: CGSize(width: ctx.width, height: ctx.height))
        ctx.translateBy(x: rect.origin.x, y: rect.origin.y)
        ctx.translateBy(x: 0, y: rect.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        let waterMarkFullSize = CGSize(width: CGFloat(ctx.width) + offset * 2, height: CGFloat(ctx.height) + offset * 2)
        guard let image = getWaterMarkImage(isLandScape: isLandscape, andFullSize: waterMarkFullSize)?.cgImage
        else { return }
        ctx.draw(image, in: CGRect(origin: CGPoint(x: -offset, y: -offset), size: waterMarkFullSize))
    }
    
    private func getWaterMarkImage(isLandScape: Bool, andFullSize fsize: CGSize) -> UIImage? {
        var image: UIImage?
        if isLandscape {
            image = landscapeImage != nil ? landscapeImage : createWatermarkImage(Text: text, andFullSize: fsize)
            landscapeImage = image
        } else {
            image = portraitImage != nil ? portraitImage : createWatermarkImage(Text: text, andFullSize: fsize)
            portraitImage = image
        }
        return image
    }
    
    private func createWatermarkImage(Text strTxt:String, andFullSize fsize:CGSize) -> UIImage {
        let attributedString = getTextAttributeString(text: text)
        let _size = getTextWaterMarkSize()
        if UIScreen.main.scale > 1.5 {
            UIGraphicsBeginImageContextWithOptions(_size,false,0)
        }
        else{
            UIGraphicsBeginImageContext(_size)
        }
        //Picture tilt
        var context = UIGraphicsGetCurrentContext()
        context?.concatenate(.init(translationX: _size.width * 0.8, y: _size.height * 0.4))
        context?.concatenate(.init(rotationAngle: -0.25 * .pi))
        context?.concatenate(.init(translationX: -_size.width * 0.8, y: -_size.height * 0.4))
        let point = getTextWaterMarkPoint(attributedString: attributedString, size: _size)
        attributedString.draw(in: .init(origin: point, size: attributedString.size()))
        let _waterImg = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage.init()
        if UIScreen.main.scale > 1.5 {
            UIGraphicsBeginImageContextWithOptions(fsize,false,0)
        }
        else{
            UIGraphicsBeginImageContext(fsize)
        }
        context = UIGraphicsGetCurrentContext()
        if lineStyle == .singleLine {
            let _rect:CGRect = .init(origin: .init(x: (fsize.width - _size.width) / 2.0,
                                                   y: (fsize.height - _size.height) / 2.0),
                                     size: _waterImg.size)
            _waterImg.draw(in: _rect)
        } else {
            var _tempC = fsize.width / _waterImg.size.width
            var _maxColumn:Int = _tempC.isNaN || !_tempC.isFinite ? 1 : Int(_tempC)
            if fsize.width.truncatingRemainder(dividingBy: _waterImg.size.width) != 0 {
                _maxColumn += 1
            }
            _tempC = fsize.height / _waterImg.size.height
            var _maxRows:Int = _tempC.isNaN || !_tempC.isFinite ? 1 : Int(_tempC)
            if fsize.height.truncatingRemainder(dividingBy: _waterImg.size.height) != 0 {
                _maxRows += 1
            }
            let spaceX = (fsize.width - multiLineWaterMarkWidth * CGFloat(numberOfOneRow)) / CGFloat(numberOfOneRow - 1)
            let spaceY = (fsize.height - multiLineWaterMarkWidth * CGFloat(numberOfOneColumn)) / CGFloat(numberOfOneColumn - 1)
            for r in 0..<_maxRows {
                for c in 0..<_maxColumn {
                    let _rect:CGRect = .init(origin: .init(x: CGFloat(c) * CGFloat(_waterImg.size.width + spaceX),
                                                           y: CGFloat(r) * CGFloat(_waterImg.size.height + spaceY)),
                                             size: _waterImg.size)
                    _waterImg.draw(in: _rect)
                }
            }
        }
        context?.clip()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(.init(origin: .zero, size: fsize))
        let _canvasImg = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage.init()
        UIGraphicsEndImageContext()
        return _canvasImg
    }
    
    private func getTextAttributeString(text: String) -> NSMutableAttributedString {
        let textFont: CGFloat = lineStyle == .multiLine ? multiLineTextFontSize : sigleLineTextFontSize
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        var textAttributes:[NSAttributedString.Key:Any] = [
            .font : UIFont.systemFont(ofSize: textFont, weight: .regular),
            .foregroundColor:textColor,
            .paragraphStyle: paragraphStyle,
            .kern:1.0,
        ]
        if #available(iOS 14.0, *) {
            textAttributes[.tracking] = 1.0
        }
        let attributedString:NSMutableAttributedString = NSMutableAttributedString.init(string: text)
        let stringRange = NSMakeRange(0, attributedString.string.utf16.count)
        attributedString.addAttributes(textAttributes,range: stringRange)
        let viewSize = getTextWaterMarkSize()
        let maxLength = getViewHypotenuseLength(viewSize: viewSize) - textMinOffset * 2
        if attributedString.size().width > maxLength, let range = text.range(of: "(") {
            var wartMarkText = text
            let location = wartMarkText.distance(from: wartMarkText.startIndex, to: range.lowerBound)
            let index = wartMarkText.index(wartMarkText.startIndex, offsetBy: location)
            wartMarkText.insert(contentsOf: "\n", at: index)
            attributedString.replaceCharacters(in: stringRange, with: wartMarkText)
        }
        return attributedString
    }
    
    private func getTextWaterMarkSize() -> CGSize {
        switch lineStyle {
        case .singleLine:
            return CGSize(width: singleLineWaterMarkWidth, height: singleLineWaterMarkWidth)
        case .multiLine:
            return CGSize(width: multiLineWaterMarkWidth, height: multiLineWaterMarkWidth)
        }
    }
    
    private func getTextWaterMarkPoint(attributedString: NSMutableAttributedString, size: CGSize) -> CGPoint {
        let viewHypotenuseLength = getViewHypotenuseLength(viewSize: size)
        var value = (viewHypotenuseLength - attributedString.size().width) / 2.0
        value = max(value, textMinOffset)
        return CGPoint(x: value, y: value)
    }
    
    private func getViewHypotenuseLength(viewSize: CGSize) -> CGFloat {
        let square = viewSize.width * viewSize.width + viewSize.height + viewSize.height
        return sqrt(square)
    }
}
