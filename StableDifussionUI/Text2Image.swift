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

    @State var guidanceScale: Float = 7.5
    let guidanceScaleMin: Float = 0.0
    let guidanceScaleMax: Float = 20.0

    @State var progress = 0.0
    @State var isInProgress = false

    init(image: Image? = nil) {
        let url = Bundle.main.resourceURL!
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine
        pipe = try? StableDiffusionPipeline(resourcesAt: url, configuration: configuration, disableSafety: true)
        if let image {
            setInfo(from: image)
        }
    }

    func setInfo(from image: Image) {
        if let prompt = image.prompt {
            self.prompt = prompt
        }
        self.seed = String(image.seed)
        self.guidanceScale = image.guidanceScale
        self.steps = Double(image.steps)
    }

    var body: some View {
        VStack {
            if let image {
                SwiftUI.Image(decorative: image, scale: 1)
            }

            HStack {
                TextField(text: $prompt) {
                    Text("Prompt: a high quality photo of an astronaut riding a dragon in space")
                }.onSubmit {
                    guard !isInProgress else { return }
                    generate()
                }
                Button("Generate") {
                    generate()
                }.disabled(isInProgress)
            }

            Slider(value: $imageCount, in: (imageCountMin ... imageCountMax)) {
                Text(String(format: "Image count (%.0f)", imageCount)).padding(.all, 8)
            } minimumValueLabel: {
                Text(String(format: "%.0f", imageCountMin)).padding(.all, 8)
            } maximumValueLabel: {
                Text(String(format: "%.0f", imageCountMax)).padding(.all, 8)
            }.disabled(true)

            Slider(value: $steps, in: (stepsMin ... stepsMax)) {
                Text(String(format: "Steps (%.0f)", steps)).padding(.all, 8)
            } minimumValueLabel: {
                Text(String(format: "%.0f", stepsMin)).padding(.all, 8)
            } maximumValueLabel: {
                Text(String(format: "%.0f", stepsMax)).padding(.all, 8)
            }

            Slider(value: $guidanceScale, in: (guidanceScaleMin ... guidanceScaleMax), step: 0.5) {
                Text(String(format: "Guidance scale (%.1f)", guidanceScale)).padding(.all, 8)
            } minimumValueLabel: {
                Text(String(format: "%.1f", guidanceScaleMin)).padding(.all, 8)
            } maximumValueLabel: {
                Text(String(format: "%.1f", guidanceScaleMax)).padding(.all, 8)
            }

            TextField("Seed", text: $seed)

            ProgressView(value: progress) {
                let progress = progress * 100
                Text(String(format: "Progress %.2f%", progress))
            }
        }.padding(.all, 16)
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

        DispatchQueue.global().async {
            _ = try? pipe?.generateImages(
                prompt: prompt,
                imageCount: Int(imageCount),
                stepCount: Int(steps),
                seed: seed,
                guidanceScale: guidanceScale,
                progressHandler: handleProgress
            ).first!
        }
    }

    func handleProgress(progress: StableDiffusionPipeline.Progress) -> Bool {
        print("\(progress.step) / \(progress.stepCount)")
        isInProgress = progress.step != progress.stepCount
        self.progress = Double(progress.step) / Double(progress.stepCount)
        self.image = progress.currentImages.compactMap({ $0 }).last
        return true
    }
}
