//
//  XYYLocationManager.swift
//  BasicUtils
//
//  Created by FW on 2020/3/17.
//

import UIKit
import CoreLocation
import BMKLocationKit
import BaiduMapAPI_Base
import BaiduMapAPI_Search

public typealias LocationChange = (_ location: XYYLocationModel) -> Void

public class XYYLocationAddressComponent: NSObject {
    /// 国家
    @objc public var country: String?
    /// 省份名称
    @objc public var province: String?
    /// 城市名称
    @objc public var city: String?
    /// 区县名称
    @objc public var district: String?
    /// 乡镇
    @objc public var town: String?
    /// 街道名称
    @objc public var streetName: String?
    /// 街道号码
    @objc public var streetNumber: String?
    /// 行政区域代码
    @objc public var adCode: String?
    
    @objc public var poiList: [BMKPoiInfo]?
}

public class XYYLocationModel: NSObject {
    public var location: CLLocationCoordinate2D?
    @objc public var address: String?
    @objc public var error: Error?
    
    @objc public var addressComponet: XYYLocationAddressComponent?
    
    @objc public var latitude: String {
        get {
            if let latitude = self.location?.latitude {
                return "\(latitude)"
            }
            return ""
        }
    }
    
    @objc public var longitude: String {
        get {
            if let longitude = self.location?.longitude {
                return "\(longitude)"
            }
            return ""
        }
    }
    
    convenience init(_ location: CLLocationCoordinate2D?, _ address: String?, _ error: Error?) {
        self.init()
        self.location = location
        self.address = address
        self.error = error
    }
}

open class XYYLocationManager: NSObject {
    
    /// 初始化定位管理器
    /// - Parameter key: 百度地图申请的key
    @objc public static func start(with key: String) {
        BMKMapManager.setAgreePrivacy(true)
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: key, authDelegate: XYYLocationManager.share)
    }
    
    /// 单例类
    @objc public static let share: XYYLocationManager = XYYLocationManager()
    
    private var locationChangeNotification: [LocationChange?] = []
    
    private var locationAddressNotification: [LocationChange?] = []
    
    private var isRequestLocation: Bool = false;
    
    private lazy var locationManager: BMKLocationManager = {
        
        BMKLocationAuth.sharedInstance().setAgreePrivacy(true)
        
        let locationManager = BMKLocationManager()
        locationManager.delegate = self;
        //设置返回位置的坐标系类型
        locationManager.coordinateType = BMKLocationCoordinateType.BMK09LL;
        //设置距离过滤参数
        locationManager.distanceFilter = kCLDistanceFilterNone;
        //设置预期精度参数
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置应用位置类型
        locationManager.activityType = CLActivityType.automotiveNavigation;
        //设置是否自动停止位置更新
        locationManager.pausesLocationUpdatesAutomatically = true;
        //设置位置获取超时时间
        locationManager.locationTimeout = 10;
        //设置获取地址信息超时时间
        locationManager.reGeocodeTimeout = 10;
        return locationManager
    }()
    
    private lazy var geoSearch: XYYLocationReverseGeo = {
        let geoSearch = XYYLocationReverseGeo()
        return geoSearch
    }()
    
    
    /// 请求单次定位
    /// - Parameters:
    ///   - haxDetailAddress: 是否需要详细地址信息
    ///   - completionBlock: 单次定位完成后的Block
    @objc public func requestSingleLocation(_ haxDetailAddress: Bool = false, with completionBlock: @escaping LocationChange) {
        self.requestCutomerSingleLocation(false, with: haxDetailAddress, with: completionBlock)
    }
    
    /// 请求单次精确定位
    /// 此处会先判断是否有精确定位权限
    @objc public func requestFullAccuracySingleLocation(_ haxDetailAddress: Bool = false, with completionBlock: @escaping LocationChange) {
        if self.locationManager.accuracyAuthorization == BMKLAccuracyAuthorization.reducedAccuracy {    // 降级定位
            if #available(iOS 14.0, *) {
                self.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "TempRequestFullLocAccuracy") { (error) in
                    if error != nil {
                        completionBlock(XYYLocationModel(nil, nil, error))
                    } else {
                        self.requestSingleLocationWithFullAccuracy(haxDetailAddress, with: completionBlock)
                    }
                }
            } else {
                self.requestSingleLocationWithFullAccuracy(haxDetailAddress, with: completionBlock)
            }
        } else {
            self.requestSingleLocationWithFullAccuracy(haxDetailAddress, with: completionBlock)
        }
    }
    
    /// 请求单次精确定位
    private func requestSingleLocationWithFullAccuracy(_ haxDetailAddress: Bool = false, with completionBlock: @escaping LocationChange) {
        if self.locationManager.accuracyAuthorization == BMKLAccuracyAuthorization.fullAccuracy {
            self.requestCutomerSingleLocation(true, with: haxDetailAddress, with: completionBlock)
        } else {
            completionBlock(XYYLocationModel(nil, nil, nil))
        }
    }
    
    /// 单次定位具体实现
    private func requestCutomerSingleLocation(_ needFullAccuracy: Bool = false, with haxDetailAddress: Bool = false, with completionBlock: @escaping LocationChange){
        XYYPermissionUtils.locationPermissionCheck { (authed) in
            guard authed == true else {
                let error = NSError(domain: "暂无定位权限", code: -1, userInfo: nil) as Error
                let locationModel = XYYLocationModel(nil, nil, error)
                completionBlock(locationModel)
                return
            }
            if (haxDetailAddress) {
                self.locationAddressNotification.append(completionBlock)
            } else {
                self.locationChangeNotification.append(completionBlock)
            }
            guard self.isRequestLocation == false else { return }
            self.isRequestLocation = true;
            
            self.locationManager.requestLocation(withReGeocode: haxDetailAddress, withNetworkState: false) { [] (location, state, error) in
                // 需要精确定位 && 没有精确定位权限
                if needFullAccuracy, self.locationManager.accuracyAuthorization == BMKLAccuracyAuthorization.reducedAccuracy {
                    completionBlock(XYYLocationModel(nil, nil, nil))
                    return
                }
                
                if let error = error {
                    self.locationChangeNotification.forEach { (completionBlock) in
                        completionBlock?(XYYLocationModel(nil, nil, error))
                    }
                    self.locationChangeNotification.removeAll()

                    self.locationAddressNotification.forEach { (completionBlock) in
                        completionBlock?(XYYLocationModel(nil, nil, error))
                    }
                    self.locationAddressNotification.removeAll()
                    
                }
                if let location = location {
                    let locationModel = XYYLocationModel(location.location?.coordinate, nil, nil)
                    let addressModel = XYYLocationAddressComponent()
                    addressModel.country = location.rgcData?.country
                    addressModel.province = location.rgcData?.province
                    addressModel.city = location.rgcData?.city
                    addressModel.district = location.rgcData?.district
                    addressModel.town = location.rgcData?.town
                    addressModel.streetName = location.rgcData?.street
                    addressModel.streetNumber = location.rgcData?.streetNumber
                    addressModel.adCode = location.rgcData?.adCode
                    locationModel.addressComponet = addressModel
                    self.locationChangeNotification.forEach { (completionBlock) in
                        completionBlock?(locationModel)
                    }
                    if let coordinate = location.location?.coordinate {
                        self.reverseGeocode(coordinate)
                    }
                }
                self.isRequestLocation = false;
                self.locationChangeNotification.removeAll()
            }
        }
    }
    
    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        self.geoSearch.reverseGeocode(coordinate) { [weak self] (locationModel) in
            self?.locationAddressNotification.forEach { (completionBlock) in
                completionBlock?(locationModel)
            }
            self?.locationAddressNotification.removeAll()
        }
    }
}

extension XYYLocationManager: BMKLocationManagerDelegate {
    public func bmkLocationManager(_ manager: BMKLocationManager, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func bmkLocationManager(_ manager: BMKLocationManager, didFailWithError error: Error?) {
        self.locationChangeNotification.forEach { (completionBlock) in
            completionBlock?(XYYLocationModel(nil, nil, error))
        }
        self.locationChangeNotification.removeAll()
        
        self.locationAddressNotification.forEach { (completionBlock) in
            completionBlock?(XYYLocationModel(nil, nil, error))
        }
        self.locationAddressNotification.removeAll()
        
        self.isRequestLocation = false
    }

    public func bmkLocationManagerDidChangeAuthorization(_ manager: BMKLocationManager) {
        
    }
}
extension XYYLocationManager: BMKLocationAuthDelegate { }


public class XYYLocationReverseGeo: NSObject, BMKGeoCodeSearchDelegate {
    
    private lazy var geoSearch: BMKGeoCodeSearch = {
        let geocodesearch = BMKGeoCodeSearch()
        return geocodesearch
    }()
    
    private var completionBlock: LocationChange?
    
    @objc public func reverseGeocode(_ coordinate: CLLocationCoordinate2D, with completionBlock: @escaping LocationChange) {
        self.geoSearch.delegate = self
        self.completionBlock = completionBlock
        /// 直接执行检索的话 设置的代理不会生效，可能与百度地图sdk 内部处理有关系，故延迟了0.5秒处理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let searchOption = BMKReverseGeoCodeSearchOption()
            searchOption.location = coordinate
            let flag = self.geoSearch.reverseGeoCode(searchOption)
            if !flag {
                let error = NSError(domain: "地理编码解析错误", code: -1, userInfo: nil)
                completionBlock(XYYLocationModel(coordinate, nil, error as Error))
                self.completionBlock = nil
            }
        }
    }
    
    public func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if Int(error.rawValue) == 0 {
            let locationModel = XYYLocationModel(result.location, result.address, nil)
            let addressModel = XYYLocationAddressComponent()
            addressModel.country = result.addressDetail.country
            addressModel.province = result.addressDetail.province
            addressModel.city = result.addressDetail.city
            addressModel.district = result.addressDetail.district
            addressModel.town = result.addressDetail.town
            addressModel.streetName = result.addressDetail.streetName
            addressModel.streetNumber = result.addressDetail.streetNumber
            addressModel.adCode = result.addressDetail.adCode
            addressModel.poiList = result.poiList
            locationModel.addressComponet = addressModel
            self.completionBlock?(locationModel)
        } else {
            let error = NSError(domain: "地理编码解析错误", code: -1, userInfo: nil)
            let locationModel = XYYLocationModel(nil, nil, error as Error)
            self.completionBlock?(locationModel)
        }
        self.completionBlock = nil
        self.geoSearch.delegate = nil
    }
    
}
