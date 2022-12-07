//
//  Text2Image.swift
//  StableDifussionUI
//
//  Created by Carlos Martinez Medina on 4/12/22.
//

import SwiftUI
import StableDiffusion

typealias Save = (_ prompt: String, _ seed: String, _ steps: Int16, _ guidanceScale: Float, _ url: URL, _ id: UUID) -> Void

struct Text2Image: View {
    let pipeline: StableDiffusionPipeline?

    //Generated image
    @State var imageUI: SwiftUI.Image

    //Image promp
    @State var prompt: String

    @State var imageCount: Double = 1
    let imageCountMin = 1.0
    let imageCountMax = 10.0

    //Seed for generated image
    @State var seed: String

    //Steps used into generation
    @State var currentStep = 0
    @State var steps: Double
    let stepsMin = 1.0
    let stepsMax = 50.0

    @State var guidanceScale: Float
    let guidanceScaleMin: Float = 0.0
    let guidanceScaleMax: Float = 20.0

    @State var progress = 0.0
    @State var isInProgress = false

    let save: Save

    init(pipeline: StableDiffusionPipeline?, save: @escaping Save) {
        self.pipeline = pipeline
        self.save = save

        self.prompt = ""
        self.seed = ""
        self.guidanceScale = 7.5
        self.steps = 18
        self.imageUI = .init("")
    }

    init(pipeline: StableDiffusionPipeline?, image: Image) {
        self.pipeline = pipeline
        self.save = { _, _, _, _, _, _ in }

        if let prompt = image.prompt {
            self.prompt = prompt
        } else {
            self.prompt = "Unable to restore prompt"
        }
        self.seed = image.seed ?? ""
        self.guidanceScale = image.guidanceScale
        self.steps = Double(image.steps)

        let context = CIContext(options: [.useSoftwareRenderer: true])
        if let url = image.url,
           let ciImage = CIImage(contentsOf: url),
           let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        {
            self.imageUI = SwiftUI.Image(decorative: cgImage, scale: 1)
        } else {
            self.imageUI = .init("")
        }
    }

    var body: some View {
        VStack {
//            if let image {
//                SwiftUI.Image(decorative: image, scale: 1)
//            }
            imageUI

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

            if isInProgress {
                ProgressView(value: progress) {
                    let progress = progress * 100
                    Text(String(format: "Progress %i/%.0f - %.2f%", currentStep, steps, progress))
                }
            }
        }.padding(.all, 16)
    }

    func generate() {
        guard !prompt.isEmpty else { return }

        let seed: UInt32
        if let intSeed = UInt32(self.seed) {
            seed = intSeed
        } else {
            seed = UInt32.random(in: (UInt32.min ... UInt32.max))
        }

        DispatchQueue.global().async {
            isInProgress = true
            let image = try? pipeline?.generateImages(
                prompt: prompt,
                imageCount: Int(imageCount),
                stepCount: Int(steps),
                seed: seed,
                guidanceScale: guidanceScale,
                progressHandler: handleProgress
            ).first
            isInProgress = false
            currentStep = 0

            guard let image, let image, let colorSpace = image.colorSpace else { return }
            let ciImage = CIImage(cgImage: image)
            let ciContext = CIContext()
            guard let data = ciContext.jpegRepresentation(of: ciImage, colorSpace: colorSpace) else { return }
            guard let directoryURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first?.appending(path: "Stable Diffusion Results") else { return }
            let id = UUID()
            let url = directoryURL.appending(path: id.description).appendingPathExtension("jpeg")
            if !FileManager.default.fileExists(atPath: directoryURL.absoluteString) {
                try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
            try? data.write(to: url)

            save(prompt, seed.description, Int16(steps), guidanceScale, url, id)
        }
    }

    func handleProgress(progress: StableDiffusionPipeline.Progress) -> Bool {
        currentStep = progress.step
        self.progress = Double(progress.step) / Double(progress.stepCount)
        guard let currentImage = progress.currentImages.compactMap({ $0 }).first else { fatalError() }
        imageUI = SwiftUI.Image(decorative: currentImage, scale: 1)
        return true
    }
}
