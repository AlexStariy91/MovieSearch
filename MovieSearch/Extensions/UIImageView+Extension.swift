//
//  UIImageView+Extension.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 03.02.2024.
//

import UIKit
import Kingfisher

extension UIImageView {
    func installPoster(from URLString: String?) {
         let noPosterImage = UIImage(named: "noPosterImage")
         if let posterURLString = URLString , URLString != "N/A" {
             guard let posterURL = URL(string: posterURLString) else {
                 self.image = noPosterImage
                 return
             }
             self.kf.indicatorType = .activity
             let kfOptions: KingfisherOptionsInfo = [.onFailureImage(noPosterImage)]
             self.kf.setImage(with: posterURL, options: kfOptions)
         } else {
             self.image = noPosterImage
         }
     }
}
