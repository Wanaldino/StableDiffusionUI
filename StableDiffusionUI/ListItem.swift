//
//  ListItem.swift
//  StableDiffusionUI
//
//  Created by Carlos Martinez Medina on 6/12/22.
//

import SwiftUI

struct ListItem: View {
    @State var image: Image
    @State var name: String

    init(image: ImageDAO) {
        self.name = image.prompt ?? ""

        let context = CIContext(options: [.useSoftwareRenderer: true])
        if let url = image.url,
           let ciImage = CIImage(contentsOf: url),
           let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        {
            self.image = Image(decorative: cgImage, scale: 1)
        } else {
            self.image = .init("")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            image.resizable().frame(width: 20, height: 20)
            Text(name)
                .lineLimit(3)
        }
    }
}
