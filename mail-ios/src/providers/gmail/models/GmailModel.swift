//
// Created by Omar Estrella on 12/28/15.
// Copyright (c) 2015 bitcreative. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class GmailModel: Object {
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self, update: true)
            }
        } catch {
            log.error("Could not save GmailModel")
        }
    }
}
