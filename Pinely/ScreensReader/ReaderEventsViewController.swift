//
//  ReaderEventsViewController.swift
//  Pinely
//

import UIKit
import SwipeView

class ReaderEventsViewController: ViewController {
    @IBOutlet weak var svContent: SwipeView!

    @IBOutlet weak var btnActive: UIButton!
    @IBOutlet weak var btnPast: UIButton!
    @IBOutlet weak var vActive: UIView!
    @IBOutlet weak var vPast: UIView!

    var selectedTabIndex: Int = 0
    var loaded = false

    var activeEvents: [Event] = []
    var pastEvents: [Event] = []
    var activeEventsFiltered: [Event] = []
    var pastEventsFiltered: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        localize()
    }

    private func localize() {
        guard let translation = AppDelegate.translation else {
            return
        }

        lblSearch?.text = translation.getStringOrKey("reader_event_screen_placeholder")
        btnActive.setTitle(translation.getStringOrKey("reader_event_title1"), for: .normal)
        btnPast.setTitle(translation.getStringOrKey("reader_event_title2"), for: .normal)
    }

    private func loadData() {
        let town = Town(dict: [
            "id": 3,
            "id_city": 2,
            "name": "Coín"
        ])
        API.shared.getRoom(cityOrTown: town) { (_, events, _) in
            self.activeEvents = events.filter { $0.finishEvent != nil && $0.finishEvent!.timeIntervalSinceNow >= 0 }
            self.pastEvents = events.filter { $0.finishEvent != nil && $0.finishEvent!.timeIntervalSinceNow < 0 }
            self.filter()
        }
    }

    @IBAction func showActive() {
        showActiveTab()
        svContent.scrollToItem(at: 0, duration: 0.3)
    }

    private func showActiveTab() {
        btnActive.setTitleColor(UIColor(named: "LocationBarText"), for: .normal)
        btnPast.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        vActive.isHidden = false
        vPast.isHidden = true
    }

    @IBAction func showPast() {
        showPastTab()
        svContent.scrollToItem(at: 1, duration: 0.3)
    }

    private func showPastTab() {
        btnActive.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnPast.setTitleColor(UIColor(named: "LocationBarText"), for: .normal)
        vActive.isHidden = true
        vPast.isHidden = false
    }

    func filter(request: String? = nil) {
        let query = (request ?? tfSearch?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            activeEventsFiltered = activeEvents
            pastEventsFiltered = pastEvents
        } else {
            let queryPrepared = query.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            activeEventsFiltered = activeEvents.filter {
                $0.name.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(queryPrepared)
            }
            pastEventsFiltered = pastEvents.filter {
                $0.name.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(queryPrepared)
            }
        }
        svContent.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ReaderClientsViewController,
            let event = sender as? Event {
            viewController.event = event
        }
    }
}

extension ReaderEventsViewController: CellEventDelegate {
    func eventSelected(event: Event?) {
        if let event = event {
            UIDevice.vibrate()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.performSegue(withIdentifier: "ReaderClients", sender: event)
            }
        }
    }
}

extension ReaderEventsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIDevice.vibrate()
        hideSearchBarPlaceholder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            showSearchBarPlaceholder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.filter(request: updatedText)
        }
        return true
    }
}

extension ReaderEventsViewController: SwipeViewDelegate, SwipeViewDataSource {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        2
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let events = (index == 0) ? activeEventsFiltered : pastEventsFiltered
        let readerEventsTabView = (view as? ReaderEventsTabView) ?? ReaderEventsTabView(frame: swipeView.bounds)
        readerEventsTabView.backgroundColor = .clear
        readerEventsTabView.prepare(events: events, delegate: self)
        return readerEventsTabView
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        switch swipeView.currentItemIndex {
        case 0: showActiveTab()
        case 1: showPastTab()
        default: break
        }
    }
}
