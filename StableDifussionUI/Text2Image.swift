//
//  Text2Image.swift
//  StableDifussionUI
//
//  Created by Carlos Martinez Medina on 4/12/22.
//

import SwiftUI
import StableDiffusion
import CoreML

struct Text2Image: View {
    let pipe: StableDiffusionPipeline

    init() {
        let url = Bundle.main.resourceURL!
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine
        pipe = try! StableDiffusionPipeline(resourcesAt: url, configuration: configuration, disableSafety: true)
    }

    @State var image: CGImage?
    @State var prompt = ""

    var body: some View {
        VStack {
            if let image {
                Image(decorative: image, scale: 1)
            }
            HStack {
                TextField(text: $prompt) {
                    Text("asdasd")
                }
                Button("Generate") {
                    let seed = UInt32.random(in: (UInt32.min ... UInt32.max))
                    let intSeed = Int(seed)
                    image = try! pipe.generateImages(
                        prompt: prompt,
                        stepCount: 4,
                        seed: intSeed,
                        progressHandler: { progress in
                            print("\(progress.step) / \(progress.stepCount)")
                            return true
                        }
                    ).first!
                }
            }
        }
    }
}
