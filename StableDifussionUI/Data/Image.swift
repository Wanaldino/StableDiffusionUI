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
        seed: String,
        prompt: String,
        steps: Int16,
        guidanceScale: Float,
        url: URL?,
        id: UUID,
        timestamp: Date = Date(),
        isFinished: Bool = true,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.id = id
        self.url = url
        self.timestamp = timestamp
        self.seed = seed
        self.prompt = prompt
        self.steps = steps
        self.guidanceScale = guidanceScale
        self.isFinished = isFinished
    }
}
