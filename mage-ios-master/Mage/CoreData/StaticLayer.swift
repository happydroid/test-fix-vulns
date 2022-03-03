//
//  StaticLayer.m
//  mage-ios-sdk
//
//  Created by William Newman on 4/13/16.
//  Copyright © 2016 National Geospatial-Intelligence Agency. All rights reserved.
//

import Foundation
import CoreData

@objc public class StaticLayer : Layer {
    
    @objc public static let StaticLayerLoaded = "mil.nga.giat.mage.static.layer.loaded";
    
    @objc public static func operationToFetchStaticLayerData(layer: StaticLayer, success: ((URLSessionDataTask,Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        guard let manager = MageSessionManager.shared(), let layerId = layer.remoteId, let eventId = layer.eventId, let baseURL = MageServer.baseURL() else {
            return nil;
        }
        
        let url = baseURL.appendingPathComponent("/api/events/\(eventId)/layers/\(layerId)/features")
        let task = manager.get_TASK(url.absoluteString, parameters: nil, progress: nil) { task, responseObject in
            MagicalRecord.save { context in
                guard var dictionaryResponse = responseObject as? [AnyHashable : Any],
                      let localLayer = StaticLayer.mr_findFirst(with: NSPredicate(format: "\(LayerKey.remoteId.key) == %@ AND \(LayerKey.eventId.key) == %@", layerId, eventId), in: context),
                      let localLayerId = localLayer.remoteId
                else {
                    return;
                }
                NSLog("fetched static features for \(localLayer.name ?? "unkonwn")");
                
                if var features = dictionaryResponse[LayerKey.features.key] as? [[AnyHashable : Any]] {
                    for i in features.indices {
                        var feature = features[i];
                        if var featureProperties = feature[StaticLayerKey.properties.key] as? [AnyHashable : Any],
                           var style = featureProperties[StaticLayerKey.style.key] as? [AnyHashable : Any],
                           var iconStyle = style[StaticLayerKey.iconStyle.key] as? [AnyHashable : Any],
                           var icon = iconStyle[StaticLayerKey.icon.key] as? [AnyHashable : Any],
                           var href = icon[StaticLayerKey.href.key] as? String,
                           href.hasPrefix("https"),
                           let iconUrl = URL(string: href),
                           let featureId = feature[StaticLayerKey.id.key]
                        {
                            let documentsDirectory = getDocumentsDirectory()
                            let featureIconRelativePath = "featureIcons/\(localLayerId)/\(featureId)"
                            let featureIconPath = "\(documentsDirectory)/\(featureIconRelativePath)"
                            do {
                                let imageData = try Data(contentsOf: iconUrl)
                                if !FileManager.default.fileExists(atPath: featureIconPath) {
                                    let featureDirectory = URL(fileURLWithPath: featureIconPath).deletingLastPathComponent()
                                    try FileManager.default.createDirectory(at: featureDirectory, withIntermediateDirectories: true, attributes: nil);
                                    try imageData.write(to: URL(fileURLWithPath: featureIconPath), options: .atomic)
                                }
                                href = featureIconRelativePath
                                icon[StaticLayerKey.href.key] = href
                                iconStyle[StaticLayerKey.icon.key] = icon;
                                style[StaticLayerKey.iconStyle.key] = iconStyle;
                                featureProperties[StaticLayerKey.style.key] = style;
                                feature[StaticLayerKey.properties.key] = featureProperties;
                                features[i] = feature;
                            } catch { }
                        }
                    }
                    
                    dictionaryResponse[LayerKey.features.key] = features;
                }
                localLayer.data = dictionaryResponse;
                localLayer.loaded = NSNumber(floatLiteral: OFFLINE_LAYER_LOADED)
                localLayer.downloading = false;
                
            } completion: { contextDidSave, error in
                if contextDidSave {
                    if let localLayer = layer.mr_(in: NSManagedObjectContext.mr_default()) {
                        NotificationCenter.default.post(name: .StaticLayerLoaded, object: localLayer);
                    }
                }
            }
        } failure: { task, error in
            NSLog("error \(error)")
        }

        
        MagicalRecord.save { context in
            let localLayer = layer.mr_(in: context);
            localLayer?.downloading = true;
        } completion: { contextDidSave, error in
            
        }
        return task;
    }
    
    @objc public static func createOrUpdate(json: [AnyHashable : Any], eventId: NSNumber, context: NSManagedObjectContext) {
        guard let remoteLayerId = Layer.layerId(json: json) else {
            return;
        }
        
        var l = StaticLayer.mr_findFirst(with: NSPredicate(format:"(\(LayerKey.remoteId.key) == %@ AND \(LayerKey.eventId.key) == %@)", remoteLayerId, eventId), in: context);
        if l == nil {
            l = StaticLayer.mr_createEntity(in: context);
            l?.populate(json, eventId: eventId);
            l?.loaded = NSNumber(floatLiteral: OFFLINE_LAYER_NOT_DOWNLOADED);
            NSLog("Inserting layer with id: \(l?.remoteId ?? -1) into event \(eventId)")
        } else {
            NSLog("Updating layer with id: \(l?.remoteId ?? -1) into event \(eventId)")
            l?.populate(json, eventId: eventId);
        }
        guard let l = l else {
            return;
        }
        NSLog("layer loaded \(l.name ?? "unkonwn")? \(l.loaded ?? -1.0)")
        if l.loaded == NSNumber(floatLiteral: OFFLINE_LAYER_NOT_DOWNLOADED) {
            StaticLayer.fetchStaticLayerData(eventId: eventId, staticLayer: l);
        }
    }
    
    @objc public static func fetchStaticLayerData(eventId: NSNumber, staticLayer: StaticLayer) {
        guard let manager = MageSessionManager.shared() else {
            return;
        }
        let fetchFeaturesTask = StaticLayer.operationToFetchStaticLayerData(layer: staticLayer, success: nil, failure: nil);
        manager.addTask(fetchFeaturesTask);
    }
    
    @objc public func removeStaticLayerData() {
        MagicalRecord.save { [weak self] context in
            guard let localLayer = self?.mr_(in: context) else {
                return;
            }
            localLayer.loaded = NSNumber(floatLiteral: Layer.OFFLINE_LAYER_NOT_DOWNLOADED);
            localLayer.data = nil
        } completion: { contextDidSave, error in
        }
    }
}
