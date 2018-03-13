//
//  AppCellItem.swift
//  OtherAppsPrompter
//
//  Created by mark bridges on 13/03/2018.
//

import Cocoa

protocol AppCellItemDelegate: class {
    func appCellItemDidPressButton(appCellItem: AppCellItem)
}

class AppCellItem: NSCollectionViewItem {
    
    let appCellView = AppCellView(frame: .zero)
    
    var app: App? {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        self.view = appCellView
    }
    

}
