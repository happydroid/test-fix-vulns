//
//  MageUserDefaultKeys.swift
//  MAGE
//
//  Created by Daniel Barela on 9/29/20.
//  Copyright © 2020 National Geospatial Intelligence Agency. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let StartStraightLineNavigation = Notification.Name("StartStraightLineNavigation")
    public static let MAGEEventsFetched = Notification.Name("MAGEEventsFetched")
    public static let MAGEFormFetched = Notification.Name(Form.MAGEFormFetched)
    public static let GeoPackageDownloaded = Notification.Name(Layer.GeoPackageDownloaded)
    public static let StaticLayerLoaded = Notification.Name(StaticLayer.StaticLayerLoaded)
    public static let MAGETokenExpiredNotification = Notification.Name("mil.nga.giat.mage.token.expired");
}

@objc public enum LocationDisplay : Int {
    case latlng
    case mgrs
    case dms
}

@objc extension UserDefaults {
    
    @objc func color(forKey key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            do {
                try color = NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
            } catch {}
        }
        return color
    }
    
    @objc func set(_ value: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = value {
            do {
                try colorData = NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            } catch {}
        }
        set(colorData, forKey: key)
    }
    
    @objc func mkcoordinateregion(forKey key: String) -> MKCoordinateRegion {
        if let regionData = array(forKey: key) as? [Double] {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionData[0], longitude: regionData[1]), latitudinalMeters: regionData[2], longitudinalMeters: regionData[3]);
        }
        return MKCoordinateRegion(center: kCLLocationCoordinate2DInvalid, span: MKCoordinateSpan(latitudeDelta: -1, longitudeDelta: -1));
    }
    
    func setRegion(_ value: MKCoordinateRegion, forKey key: String) {
        let span = value.span
        let center = value.center
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        
        let regionData: [Double] = [value.center.latitude, value.center.longitude, metersInLatitude, metersInLongitude];
        setValue(regionData, forKey: key);
    }
    
    var showHeadingSet: Bool {
        get {
            return value(forKey: #keyPath(UserDefaults.showHeading)) != nil;
        }
    }
    
    var showHeading: Bool {
        get {
            return bool(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var bearingTargetColor: UIColor {
        get {
            return color(forKey: #function) ?? .systemGreen
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var headingColor: UIColor {
        get {
            return color(forKey: #function) ?? .systemRed
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var mapType: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var mapRegion: MKCoordinateRegion {
        get {
            return mkcoordinateregion(forKey: #function)
        }
        set {
            setRegion(newValue, forKey: #function)
        }
    }
    
    var mapShowTraffic: Bool {
        get {
            return bool(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var selectedStaticLayers: [String: [NSNumber]]? {
        get {
            return dictionary(forKey: #function) as? [String: [NSNumber]];
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var selectedOnlineLayers: [String: [NSNumber]]? {
        get {
            return dictionary(forKey: #function) as? [String: [NSNumber]];
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var serverMajorVersion: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var serverMinorVersion: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var themeOverride: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var currentUserId: String? {
        get {
            return string(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var currentEventId: Any? {
        get {
            return object(forKey: #function);
        }
        set {
            if newValue == nil {
                removeObject(forKey: #function)
            } else {
                set(newValue, forKey: #function);
            }
        }
    }
    
    var loginType: String? {
        get {
            return string(forKey: #function);
        }
        set {
            if newValue == nil {
                removeObject(forKey: #function)
            } else {
                set(newValue, forKey: #function);
            }
        }
    }
    
    var baseServerUrl: String? {
        get {
            return string(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var locationDisplay: LocationDisplay {
        get {
            // use the key showMGRS which used to be stored as a bool, but using integer(forKey will coerce it to an int and leave
            // the legacy value meaning intact
            return LocationDisplay.init(rawValue: integer(forKey: "showMGRS")) ?? LocationDisplay.latlng
        }
        set {
            set(newValue.rawValue, forKey: "showMGRS");
        }
    }
    
    var deviceRegistered: Bool {
        get {
            return bool(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var imageUploadSizes: [String: Any]? {
        get {
            return dictionary(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var videoUploadQualities: [String: Any]? {
        get {
            return dictionary(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var loginParameters: [String: Any]? {
        get {
            return dictionary(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var authenticationStrategies: [String: [AnyHashable: Any]]? {
        get {
            return dictionary(forKey: #function) as? [String: [AnyHashable : Any]];
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var serverAuthenticationStrategies: [String: [AnyHashable: Any]]? {
        get {
            return dictionary(forKey: #function) as? [String: [AnyHashable : Any]]
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var observationTimeFilter: TimeFilterType {
        get {
            return TimeFilterType.init(rawValue: UInt(integer(forKey: "timeFilterKey"))) ?? TimeFilterType.all;
        }
        set {
            set(newValue.rawValue, forKey: "timeFilterKey");
        }
    }
    
    var observationPushFrequency: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var observationFetchFrequency: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var userFetchFrequency: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var contactInfoEmail: String? {
        get {
            return string(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var contactInfoPhone: String? {
        get {
            return string(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var showDisclaimer: Bool {
        get {
            return bool(forKey: #function);
        }
        set {
            set(newValue, forKey: #function);
        }
    }
    
    var disclaimerText: String? {
        get {
            return string(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var disclaimerTitle: String? {
        get {
            return string(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var serverCompatibilities: [[String: Int]]? {
        get {
            return array(forKey: #function) as? [[String: Int]]
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var observationPushNetworkOption: NetworkAllowType {
        get {
            return NetworkAllowType(rawValue: integer(forKey: #function)) ?? NetworkAllowType.all
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var observationFetchNetworkOption: NetworkAllowType {
        get {
            return NetworkAllowType(rawValue: integer(forKey: #function)) ?? NetworkAllowType.all
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var locationPushNetworkOption: NetworkAllowType {
        get {
            return NetworkAllowType(rawValue: integer(forKey: #function)) ?? NetworkAllowType.all
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var locationFetchNetworkOption: NetworkAllowType {
        get {
            return NetworkAllowType(rawValue: integer(forKey: #function)) ?? NetworkAllowType.all
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var attachmentPushNetworkOption: NetworkAllowType {
        get {
            return NetworkAllowType(rawValue: integer(forKey: #function)) ?? NetworkAllowType.all
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var attachmentFetchNetworkOption: NetworkAllowType {
        get {
            return NetworkAllowType(rawValue: integer(forKey: #function)) ?? NetworkAllowType.all
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var wifiNetworkRestrictionType: WIFIRestrictionType {
        get {
            return WIFIRestrictionType(rawValue: integer(forKey: #function)) ?? WIFIRestrictionType.NoRestrictions
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
    var wifiWhitelist: [String] {
        get {
            return array(forKey: #function) as? [String] ?? []
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var wifiBlacklist: [String] {
        get {
            return array(forKey: #function) as? [String] ?? []
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    // MARK: GeoPackage keys
    var geoPackageFeatureTilesMaxPointsPerTile: Int {
        get {
            return integer(forKey: "geopackage_feature_tiles_max_points_per_tile");
        }
        set {
            set(newValue, forKey: "geopackage_feature_tiles_max_points_per_tile");
        }
    }
    
    var geoPackageFeatureTilesMaxFeaturesPerTile: Int {
        get {
            return integer(forKey: "geopackage_feature_tiles_max_features_per_tile");
        }
        set {
            set(newValue, forKey: "geopackage_feature_tiles_max_features_per_tile");
        }
    }
    
    var geoPackageFeaturesMaxPointsPerTable: Int {
        get {
            return integer(forKey: "geopackage_features_max_points_per_table");
        }
        set {
            set(newValue, forKey: "geopackage_features_max_points_per_table");
        }
    }
    
    var geoPackageFeaturesMaxFeaturesPerTable: Int {
        get {
            return integer(forKey: "geopackage_features_max_features_per_table");
        }
        set {
            set(newValue, forKey: "geopackage_features_max_features_per_table");
        }
    }
}
