//
//  AppCellItem.swift
//  OtherAppsPrompter
//
//  Created by mark bridges on 13/03/2018.
//

import Cocoa

class AppCellItem: NSCollectionViewItem {
    
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "AppCellItem")
    
    let appCellView = AppCellView(frame: .zero)
    
    var app: App? {
        didSet {
            guard let app = app else { return }
            appCellView.titleLabel.stringValue = app.appName
            appCellView.descriptionLabel.stringValue = app.description
            appCellView.iconImageView.kf.setImage(with: app.imageUrl)
        }
    }
    
    override func loadView() {
        self.view = appCellView
    }

}
