/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import Foundation

extension Event {
    /// Reads an array`TargetPrefetch` from the event data
    var prefetchObjectArray: [TargetPrefetch]? {
        return TargetPrefetch.from(dictionaries: data?[TargetConstants.EventDataKeys.PREFETCH_REQUESTS] as? [[String: Any]])
    }

    /// Reads the `TargetParameters` from the event data
    var targetParameters: TargetParameters? {
        return TargetParameters.from(dictionary: data?[TargetConstants.EventDataKeys.TARGET_PARAMETERS] as? [String: Any])
    }

    /// Returns true if this event is a prefetch request event
    var isPrefetchEvent: Bool {
        return data?[TargetConstants.EventDataKeys.PREFETCH_REQUESTS] != nil
    }

    /// Returns true if this event is a load request event
    var isLoadRequest: Bool {
        return data?[TargetConstants.EventDataKeys.LOAD_REQUESTS] != nil
    }

    /// Reads an array`TargetRequest` from the event data
    var targetRequests: [TargetRequest]? {
        return TargetRequest.from(dictionaries: data?[TargetConstants.EventDataKeys.LOAD_REQUESTS] as? [[String: Any]])
    }

    /// Returns true if the event is location display request event
    var isLocationsDisplayedEvent: Bool {
        return data?[TargetConstants.EventDataKeys.IS_LOCATION_DISPLAYED] as? Bool ?? false
    }

    /// Returns true if the event is location clicked request event
    var isLocationClickedEvent: Bool {
        return data?[TargetConstants.EventDataKeys.IS_LOCATION_CLICKED] as? Bool ?? false
    }

    /// Returns true if this event is a reset experience request event
    var isResetExperienceEvent: Bool {
        return data?[TargetConstants.EventDataKeys.RESET_EXPERIENCE] as? Bool ?? false
    }

    /// Returns true if this event is a clear prefetch request event
    var isClearPrefetchCache: Bool {
        return data?[TargetConstants.EventDataKeys.CLEAR_PREFETCH_CACHE] as? Bool ?? false
    }
}
