//
//  StaffCreateEditEventBaseViewController+UITextViewDelegate.swift
//  Pinely
//

import UIKit

extension StaffCreateEditEventBaseViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        lblDescriptionHint.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text ?? "").isEmpty {
            lblDescriptionHint.isHidden = false
        } else {
            lblDescriptionHint.isHidden = true
        }

        showHideButton()
    }

    func textViewDidChange(_ textView: UITextView) {
        showHideButton()
    }
}
