//
//  Nano33BLESenseBarometricPressureSensor.swift
//  ScienceJournal
//
//  Created by Sebastian Romero on 1/09/2020.
//  Copyright © 2020 Arduino. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import CoreBluetooth

struct Nano33BLESenseBarometricPressureSensor: BLEArduinoSensor {
  static var uuid: CBUUID { CBUUID(string: "555a0002-0015-467a-9538-01f0652c74e8") }

  var name: String { String.barometer }

  var iconName: String { "ic_sensor_barometer" }
  
  var filledIconName: String { "ic_sensor_barometer_filled" }

  var animatingIconName: String { "sensor_barometer" }

  var unitDescription: String? { String.barometerUnits }

  var textDescription: String { String.sensorDescShortBarometer }

  var learnMoreInformation: Sensor.LearnMore {
    Sensor.LearnMore(firstParagraph: String.sensorDescFirstParagraphBarometer,
                     secondParagraph: String.sensorDescSecondParagraphBarometer,
                     imageName: "learn_more_barometer")
  }

  var config: BLEArduinoSensorConfig?

  func point(for data: Data) -> Double {
    guard data.count == 4 else { return 0 }
    let pressure = data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: Float.self) }
    //For converstion to atm: pressure / 101.325
    return Double(pressure * 10.0 )
  }
}
