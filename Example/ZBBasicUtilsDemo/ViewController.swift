//
//  ViewController.swift
//  ZBBasicUtilsDemo
//
//  Created by biyuhuaping on 05/10/2023.
//  Copyright (c) 2023 biyuhuaping. All rights reserved.
//

import UIKit
import ZBBasicUtilsDemo
import BaiduMapAPI_Map

class ViewController: UIViewController {
    
    lazy var searchGeo = XYYLocationReverseGeo()
    @IBOutlet weak var myLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func btn1Action(_ sender: Any) {
        /*
        XYYLocationManager.share.requestSingleLocation(true) { (locationModel) in
            print("定位经纬度 ", locationModel.location as Any)
            print("详细位置信息", locationModel.address as Any)
            print("错误信息", locationModel.error as Any)
        }
        */
        XYYLocationManager.share.requestFullAccuracySingleLocation { (locationModel) in
            let str1 = locationModel.location as Any
            let str2 = (locationModel.address ?? "") as String
            let str3 = locationModel.error as Any
            self.myLab.text = "定位经纬度:\(str1)\n详细位置信息:\(str2)\n错误信息:\(str3)"
        }
    }
    
    @IBAction func btn2Action(_ sender: Any) {
        self.searchGeo.reverseGeocode(CLLocationCoordinate2DMake(40.00179, 116.487017)) { (locationModel) in
            let str1 = locationModel.location as Any
            let str2 = (locationModel.address ?? "") as String
            let str3 = locationModel.error as Any
            let str4 = locationModel.addressComponet?.poiList as Any

            self.myLab.text = "1---\n定位经纬度:\(str1)\n详细位置信息:\(str2)\n错误信息:\(str3)\nPOI信息:\(str4)"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let viewController = LocationViewController()
        self.present(viewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

