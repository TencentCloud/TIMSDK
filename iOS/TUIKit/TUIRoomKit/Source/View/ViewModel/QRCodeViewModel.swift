//
//  QRCodeViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import PhotosUI

class QRCodeViewModel {
    let urlString: String
    var store: RoomStore {
        EngineManager.shared.store
    }
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func copyAction(sender: UIButton, text: String) {
        UIPasteboard.general.string = text
    }
    
    func saveIntoAlbumAction(sender: UIButton, image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func backAction() {
        RoomRouter.shared.dismissPopupViewController()
    }
    
    func createQRCodeImageView(url: String, imageView: UIImageView) {
        if url.count == 0 { return }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {return}
        filter.setDefaults()
        // Set filter input data
        let data = url.data(using: String.Encoding.utf8)
        filter.setValue(data, forKey: "inputMessage")
        // Set the error correction rate of QR code
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard var image = filter.outputImage else { return }
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image.transformed(by: transform)
        let resultImage = UIImage(ciImage: image)
        guard let center = UIImage(named: "AppIcon.png") else { return }
        guard let resultImage = getClearImage(sourceImage: resultImage, center: center) else { return }
        imageView.image = resultImage
    }
    
    private func getClearImage(sourceImage: UIImage, center: UIImage) -> UIImage? {
        let size = sourceImage.size
        UIGraphicsBeginImageContext(size)
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let width: CGFloat = 80
        let height: CGFloat = 80
        let x: CGFloat = (size.width - width) * 0.5
        let y: CGFloat = (size.height - height) * 0.5
        center.draw(in: CGRect(x: x, y: y, width: width, height: height))
        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
