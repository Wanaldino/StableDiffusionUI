//
//  ContentView.swift
//  StableDifussionUI
//
//  Created by Carlos Martinez Medina on 4/12/22.
//

import SwiftUI
import StableDiffusion
import CoreML
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Image.timestamp, ascending: true)], animation: .default)
    private var items: FetchedResults<Image>

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
                    Text2Image(pipeline: pipeline)
                } label: {
                    Text("Text 2 Image")
                }

                Section("History") {
                    ForEach(items) { item in
                        NavigationLink {
                            Text2Image(pipeline: pipeline, image: item)
                        } label: {
                            Text(item.timestamp!.description)
                        }
                    }
                }
            }

            Text("Select an item")
        }
    }

    func handleCreation() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
