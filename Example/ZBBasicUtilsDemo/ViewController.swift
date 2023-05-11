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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let button1 = UIButton()
        button1.setTitle("单次精确定位", for: .normal)
        button1.backgroundColor = UIColor.gray
        button1.frame = CGRect(x: 80, y: 260, width: 220, height: 40)
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        self.view.addSubview(button1)
        
        let button2 = UIButton()
        button2.setTitle("根据地理坐标获取地址信息", for: .normal)
        button2.backgroundColor = UIColor.gray
        button2.frame = CGRect(x: 80, y: 340, width: 240, height: 40)
        button2.addTarget(self, action: #selector(button2Action), for: .touchUpInside)
        self.view.addSubview(button2)
    }
    
    @objc private func button1Action() {
        /*
        XYYLocationManager.share.requestSingleLocation(true) { (locationModel) in
            print("定位经纬度 ", locationModel.location as Any)
            print("详细位置信息", locationModel.address as Any)
            print("错误信息", locationModel.error as Any)
        }
        */
        XYYLocationManager.share.requestFullAccuracySingleLocation { (locationModel) in
            print("定位经纬度 ", locationModel.location as Any)
            print("详细位置信息", locationModel.address as Any)
            print("错误信息", locationModel.error as Any)
        }
    }
    
    @objc private func button2Action() {
        self.searchGeo.reverseGeocode(CLLocationCoordinate2DMake(40.00179, 116.487017)) { (locationModel) in
            print("1定位经纬度 ", locationModel.location as Any)
            print("1详细位置信息", locationModel.address as Any)
            print("1错误信息", locationModel.error as Any)
            print("1POI信息", locationModel.addressComponet?.poiList as Any)
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

