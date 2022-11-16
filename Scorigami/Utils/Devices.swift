//
//  Devices.swift
//  Scorigami
//
//  Created by Paul Kelaita on 11/16/22.
//

import SwiftUI

let iPhoneCellHeight: CGFloat = 8.0
let iPhoneCellWidth: CGFloat = 4.5
let iPhoneScreenWidth: CGFloat = 333

private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

class Devices {
  
  static func getFrameWidth() -> CGFloat {
    if idiom == .pad {
      return iPhoneCellWidth * 2.5
    } else {
      return iPhoneCellWidth
    }
  }
  
  static func getFrameHeight() -> CGFloat {
    if idiom == .pad {
      return iPhoneCellHeight * 2.0
    } else {
      return iPhoneCellHeight
    }
  }
  
  static func getDisplayWidth() -> CGFloat {
    if idiom == .pad {
      return iPhoneScreenWidth * 2.22
    } else {
      return iPhoneScreenWidth
    }
  }
}
