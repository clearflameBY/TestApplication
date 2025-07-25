//
//  UIImageView+Extension.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(from urlString: String) {
        self.image = nil // Clear previous image

        // Check cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to load image from URL: \(error.localizedDescription)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else { return }

            // Cache the image
            imageCache.setObject(image, forKey: urlString as NSString)

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
