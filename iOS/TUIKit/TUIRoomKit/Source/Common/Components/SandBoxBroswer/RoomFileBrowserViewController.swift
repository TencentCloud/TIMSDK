//
//  RoomFileBrowserViewController.swift
//  DemoApp
//
//  Created by CY zhao on 2023/7/4.
//

import Foundation
import UIKit

@objcMembers public class RoomFileBrowserViewController: UITableViewController {
    var modelArray: [RoomFileBroswerModel] = []
    var documentController: UIDocumentInteractionController? = nil
    var bathPath: String
    
    public init(bathPath: String) {
        self.bathPath = bathPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.loadData()
    }
    
    func initUI() {
        self.tableView.rowHeight = RoomFileBroswerCellHeight
        self.tableView.register(RoomFileBroswerCell.self, forCellReuseIdentifier: "RoomFileBroswerCell")
        
        self.navigationItem.title = self.bathPath
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let backBtnItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBtnItem
    }
    
    func loadData() {
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: self.bathPath) else {
            return
        }
        let sortedList = fileList.sorted { file1, file2 in
            return file1.localizedStandardCompare(file2) == .orderedAscending
        }
        for fileName in sortedList {
            let path = URL(fileURLWithPath: self.bathPath).appendingPathComponent(fileName).path
            let model = RoomFileBroswerModel(title: fileName, path: path )
            self.modelArray.append(model)
        }
    }
    
// MARK: Table view data source
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modelArray.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.modelArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomFileBroswerCell") as! RoomFileBroswerCell
        cell.updateUI(model: model)
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.modelArray[indexPath.row]
        
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: model.path, isDirectory: &isDirectory)
        if isDirectory.boolValue {
            let vc = RoomFileBrowserViewController(bathPath: self.bathPath)
            vc.bathPath = model.path
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.handleFile(model: model)
        }
    }
    
    func handleFile(model: RoomFileBroswerModel) {
        self.documentController = UIDocumentInteractionController(url: URL(fileURLWithPath: model.path))
        self.documentController?.presentOpenInMenu(from: CGRectZero, in: self.view, animated: true)
    }
}


