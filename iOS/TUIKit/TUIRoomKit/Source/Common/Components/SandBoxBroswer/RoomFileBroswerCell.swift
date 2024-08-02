//
//  RoomFileBroswerCell.swift
//  DemoApp
//
//  Created by CY zhao on 2023/7/4.
//

import Foundation
import UIKit

public let RoomFileBroswerCellHeight = 40.0

class RoomFileBroswerCell: UITableViewCell {
    lazy var titlelabel: UILabel = {
        let tLabel = UILabel()
        tLabel.font = .systemFont(ofSize: 16)
        tLabel.textColor = UIColor.tui_color(withHex: "333333")
        return tLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.contentView.addSubview(titlelabel)
        titlelabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(5)
            $0.top.equalToSuperview().offset(5)
            $0.right.equalToSuperview().offset(-20)
        }
    }
    
    func updateUI(model: RoomFileBroswerModel) {
        self.titlelabel.text = model.title
    }

}
