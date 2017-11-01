//
//  SplashViewController.swift
//  dataconnect
//
//  Created by hienng on 9/20/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    open var pulsing: Bool = false
    
    var tileGridView: TileGridView!
    
    public init(tileViewFileName: String){
        super.init(nibName: nil, bundle: nil)
        tileGridView = TileGridView(TileFileName: tileViewFileName)
        view.addSubview(tileGridView)
        tileGridView.frame = view.bounds
        tileGridView.startAnimating()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }

}
