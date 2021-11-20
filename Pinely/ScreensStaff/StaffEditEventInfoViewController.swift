//
//  StaffEditEventInfoViewController.swift
//  Pinely
//

import UIKit

class StaffEditEventInfoViewController: StaffCreateEditEventBaseViewController {
    var event: Event!
    var eventInfo: EventInfo?
    var eventRules: EventRules?

    override func viewDidLoad() {
        super.viewDidLoad()

        tfName.text = event.name
        if let start = eventInfo?.startEvent ?? event.startEvent {
            tfStart.text = dateFormatter.string(from: start)
        }
        if let finishEvent = event.finishEvent {
            tfEnd.text = dateFormatter.string(from: finishEvent)
        }
        if let ageMin = eventRules?.ageMin {
            tfAge.text = "\(ageMin)"
        }
        tfClothing.text = eventRules?.clothesRuleText ?? ""
        tfSlogan.text = event.subTitle ?? ""
        tvDescription.text = event.description ?? ""
        lblDescriptionHint.isHidden = tvDescription.text.count > 0
    }

    override func apply(name: String, slogan: String, descr: String) {
        // TODO: Save changes
    }
}
