//
//  UIViewController+Extension.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 05.02.2024.
//

import UIKit

extension UIViewController {
     func showAlert(with errorDescription: String) {
         var description = errorDescription
         if description == "Too many results." {
             description.append(" Please enter more specified search details!")
         }
        let errorAlert = UIAlertController(title: description, message: "", preferredStyle: .alert)
        present(errorAlert, animated: true)
        let vibrate = UINotificationFeedbackGenerator()
        vibrate.notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.4){
            errorAlert.dismiss(animated: true)
        }
    }
}
