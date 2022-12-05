//
//  Item.swift
//  StableDifussionUI
//
//  Created by Carlos Martinez Medina on 5/12/22.
//

import Foundation
import CoreData

extension Image {
    convenience init(
        seed: Int16,
        prompt: String,
        steps: Int16,
        guidanceScale: Float,
        id: UUID = UUID(),
        timestamp: Date = Date(),
        isFinished: Bool = false,
        image: Data? = nil,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.id = id
        self.image = image
        self.timestamp = timestamp
        self.seed = seed
        self.prompt = prompt
        self.steps = steps
        self.guidanceScale = guidanceScale
        self.isFinished = isFinished

    }
}
