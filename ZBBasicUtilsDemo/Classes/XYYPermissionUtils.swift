//
//  XYYPermissionUtils.swift
//  BasicUtils
//
//  Created by FW on 2020/3/17.
//

import UIKit
import CoreLocation
import AVFoundation
import Photos

open class XYYPermissionUtils: NSObject {
    
    private static let share: XYYPermissionUtils = XYYPermissionUtils()
    private var isShowLocationTips: Bool = false
    
    @objc public static func locationPermissionCheck(_ handler: @escaping (_ authed: Bool) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied, .restricted:
            handler(false)
            /// 没有开启定位权限
            if (!XYYPermissionUtils.share.isShowLocationTips) {
                let alert = UIAlertController(title: "提示", message: "定位权限未开启，是否开启？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                    /// 打开对应设置页面
                    if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
                
                XYYPermissionUtils.share.isShowLocationTips = true
            }
        default:
            XYYPermissionUtils.share.isShowLocationTips = false
            handler(true)
        }
    }
    
    @objc public static func videoPermissionCheck(_ handler: @escaping (_ authed: Bool) -> Void) {
        if let _ = AVCaptureDevice.default(for: .video) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .denied, .restricted: // 没有开启相机权限
                // 回调
                handler(false)
                // 弹窗
                let alert = UIAlertController(title: "提示", message: "相机权限未开启，是否开启？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                    // 打开设置
                    if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
            case .notDetermined:
                // 还未选择
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    DispatchQueue.main.async {
                        if granted {
                            handler(true)
                        } else {
                            handler(false)
                        }
                    }
                }
            default:
                // 有权限
                handler(true)
            }
        } else {
            handler(false)
            print("此设备没有摄像头")
        }
    }
    
    @objc public static func photoLibraryPermissionCheck(_ handler: @escaping (_ authed: Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .denied, .restricted:
                handler(false)
                // 弹窗
                let alert = UIAlertController(title: "提示", message: "相册权限未开启，是否开启？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                    // 打开设置
                    if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
            default:
                handler(true)
            }
        }
    }
    
}
