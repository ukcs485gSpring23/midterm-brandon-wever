//
//  CustomFeaturedContentView.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import UIKit
import CareKit
import CareKitUI

/// A simple subclass to take control of what CareKit already gives us.
class CustomFeaturedContentView: OCKFeaturedContentView {
    var url: URL?

    // Need to override so we can become delegate when the user taps on card
    override init(imageOverlayStyle: UIUserInterfaceStyle = .unspecified) {
        // See that this always calls the super
        super.init(imageOverlayStyle: imageOverlayStyle)

        // TODOxxx: 1 - Need to become a "delegate" so we know when view is tapped.
        self.delegate = self
    }

    /*
     TODOxxx: 4 - Modify this init to take: UIImage, a text string , and text color.
     The initialize should set all of the respective properties.
     */
    // A convenience initializer to make it easier to use our custom featured content
    // swiftlint:disable:next line_length
    convenience init(url: String, imageOverlayStyle: UIUserInterfaceStyle = .unspecified, image: UIImage?, tipTitle: String, color: UIColor) {
        self.init(imageOverlayStyle: imageOverlayStyle)
        // TODOxxx: 2 - Need to call the designated initializer

        // TODOxxx: 3 - Need to turn the url string into a real URL using URL(string: String)
        self.url = URL(string: url)
        self.imageView.image = image
        self.label.text = tipTitle
        self.label.textColor = color

    }
}

/// Need to conform to delegate in order to be delegated to.
extension CustomFeaturedContentView: OCKFeaturedContentViewDelegate {

    func didTapView(_ view: OCKFeaturedContentView) {
        // When tapped open a URL.
        guard let url = url else {
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
}
