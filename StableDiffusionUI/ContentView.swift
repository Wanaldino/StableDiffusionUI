//
//  ContentView.swift
//  StableDiffusionUI
//
//  Created by Carlos Martinez Medina on 14/12/22.
//

import SwiftUI
import CoreData
import CoreML
import StableDiffusion

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ImageDAO.timestamp, ascending: false)], animation: .default)
    private var items: FetchedResults<ImageDAO>
    var newImage: Image?

    let pipeline: StableDiffusionPipeline?
    init() {
        let url = Bundle.main.resourceURL!
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine
        pipeline = try? StableDiffusionPipeline(resourcesAt: url, configuration: configuration, disableSafety: true)
    }

    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    Text2Image(pipeline: pipeline, save: handleCreation)
                } label: {
                    Text("Text 2 Image")
                }

                Section("History") {
                    ForEach(items) { item in
                        NavigationLink {
                            Text2Image(pipeline: pipeline, image: item)
                                .disabled(true)
                        } label: {
                            ListItem(image: item)
                        }
                    }
                }
            }
        }
    }

    func handleCreation(prompt: String, seed: String, steps: Int16, guidanceScale: Float, url: URL, id: UUID) {
        let image = ImageDAO(
            seed: seed,
            prompt: prompt,
            steps: steps,
            guidanceScale: guidanceScale,
            url: url,
            id: id,
            context: viewContext
        )
        viewContext.insert(image)
        guard viewContext.hasChanges else { return }
        try? viewContext.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
