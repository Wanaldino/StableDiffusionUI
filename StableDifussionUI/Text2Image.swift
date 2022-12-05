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
    let pipe: StableDiffusionPipeline?

    //Generated image
    @State var image: CGImage?

    //Image promp
    @State var prompt = ""

    @State var imageCount: Double = 1.0
    let imageCountMin = 1.0
    let imageCountMax = 10.0

    //Seed for generated image
    @State var seed: String = ""

    //Steps used into generation
    @State var steps: Double = 18.0
    let stepsMin = 1.0
    let stepsMax = 50.0

    init() {
        let url = Bundle.main.resourceURL!
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine
        pipe = try? StableDiffusionPipeline(resourcesAt: url, configuration: configuration, disableSafety: true)
    }

    var body: some View {
        VStack {
            if let image {
                Image(decorative: image, scale: 1)
            }
            HStack {
                TextField(text: $prompt) {
                    Text("Prompt: a high quality photo of an astronaut riding a dragon in space")
                }.onSubmit {
                    generate()
                }
                Button("Generate") {
                    generate()
                }
            }
            Slider(value: $imageCount, in: (imageCountMin ... imageCountMax), step: 1.0) {
                Text(String(format: "Image count (%.0f)", imageCount)).padding(.all, 8)
            } minimumValueLabel: {
                Text(String(format: "%.0f", imageCountMin)).padding(.all, 8)
            } maximumValueLabel: {
                Text(String(format: "%.0f", imageCountMax)).padding(.all, 8)
            }
            Slider(value: $steps, in: (stepsMin ... stepsMax), step: 1.0) {
                Text(String(format: "Steps (%.0f)", steps)).padding(.all, 8)
            } minimumValueLabel: {
                Text(String(format: "%.0f", stepsMin)).padding(.all, 8)
            } maximumValueLabel: {
                Text(String(format: "%.0f", stepsMax)).padding(.all, 8)
            }
            TextField("Seed", text: $seed)
        }
    }

    func generate() {
        guard !prompt.isEmpty else { return }

        let seed: Int
        if let intSeed = Int(self.seed) {
            seed = intSeed
        } else {
            let randomSeed = UInt32.random(in: (UInt32.min ... UInt32.max))
            seed = Int(randomSeed)
        }

        image = try? pipe?.generateImages(
            prompt: prompt,
            imageCount: Int(imageCount),
            stepCount: Int(steps),
            seed: seed,
            progressHandler: handleProgress
        ).first!
    }

    func handleProgress(progress: StableDiffusionPipeline.Progress) -> Bool {
        print("\(progress.step) / \(progress.stepCount)")
        return true
    }
}
