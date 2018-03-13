//    MIT License
//
//    Copyright (c) 2018 Mark Bridges
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Cocoa

protocol OtherAppsViewControllerDelegate: class {
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didSelectApp app: App)
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didCloseWithState dismissState: OtherAppsViewController.DismissState)
}

class OtherAppsViewController: NSViewController {
    
    enum DismissState {
        case dontShowAgain
        case canShowAgain
    }

    @IBOutlet private var titleTextField: NSTextField?
    @IBOutlet private var descriptionTextField: NSTextField?
    @IBOutlet private var showMeAgainButton: NSButton!
    @IBOutlet private var collectionView: NSCollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    var appName: String?
    var apps = [App]()
    weak var delegate: OtherAppsViewControllerDelegate?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField?.stringValue = "Thanks for using " + (appName ?? "")
        view.window?.delegate = self
    }
    
}

// MARK: NSCollectionViewDataSource

extension OtherAppsViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return apps.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AppCellItem"), for: indexPath) as? AppCellItem else {
            fatalError("Wrong item returned")
        }
        item.delegate = self
        (item.view as! ImageCellView).viewController?.delegate = self
        
        // TODO: Investigate this crash
        guard imageCellViewModels.count > indexPath.item else {
            return item
        }
        
        let cellViewModel = imageCellViewModels[indexPath.item]
        
        item.image = cellViewModel.image
        switch cellViewModel.matchState {
        case .exactMatch:
            item.selectedStateImageView?.image = #imageLiteral(resourceName: "Selected Exact Match")
            
        case .closeMatch:
            item.selectedStateImageView?.image = #imageLiteral(resourceName: "Selected Close Match")
            
        case .notMatched:
            item.selectedStateImageView?.image = nil
            
        }
        
        
        return item
    }
}


// MARK: NSCollectionViewDelegate

extension OtherAppsViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
    }
    
}

// MARK: NSCollectionViewDelegateFlowLayout

extension OtherAppsViewController: NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let totalGap = (EditorControlsViewController.collectionViewInset * 2) + (EditorControlsViewController.collectionViewInset * (EditorControlsViewController.collectionViewItemsPerRow - 1))
        
        let itemWidth = (collectionView.frame.size.width - totalGap) / EditorControlsViewController.collectionViewItemsPerRow
        
        return NSSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        
        return NSEdgeInsets(top: EditorControlsViewController.collectionViewInset,
                            left: EditorControlsViewController.collectionViewInset,
                            bottom: EditorControlsViewController.collectionViewInset,
                            right: EditorControlsViewController.collectionViewInset)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return EditorControlsViewController.collectionViewInset
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return EditorControlsViewController.collectionViewInset
    }
    
}

// MARK: NSWindowDelegate

extension OtherAppsViewController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        let suppressed = (showMeAgainButton?.state == .off)
        delegate?.otherAppsViewController(otherAppsViewController: self, didCloseWithState: suppressed ? .canShowAgain : .dontShowAgain )
    }
}
