//
//  ContentView.swift
//  Playlist Export
//
//  Created by Georg Kemser on 18.11.21.
//

import SwiftUI

final class Output: ObservableObject {
    static let sharedInstance = Output()
    
    @Published var progressText: [String] = []
    
    @Published var fldToProcess: Double = 0.0
    @Published var plsToProcess: Double = 1.0
    @Published var plsProcessed: Double = 0.0
    
    @Published var isProcessing: Bool = false
}

struct ContentView: View {
    @ObservedObject var output: Output = Output.sharedInstance
    
    @State var deviceSelection: String = targetDev.id.rawValue
    @State var deleteExistingFiles: Bool = true
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack() {
                    HStack() {
                        HStack() {
                            Text("Ordner: ")
                                .font(.system(size: 13))
                            
                            Text((output.fldToProcess != 0.0) ? String(Int(output.fldToProcess)) : "-")
                                .font(.system(size: 13))
                            
                            Text(" | ")
                            
                            Text("Playlists: ")
                                .font(.system(size: 13))
                            
                            Text((output.plsToProcess != 1.0) ? String(Int(output.plsToProcess)) : "-")
                                .font(.system(size: 13))
                            
                            Text(" | ")
                            
                            Text("Bearbeitet: ")
                                .font(.system(size: 13))
                            
                            Text((output.plsProcessed != 0.0) ? String(Int(output.plsProcessed)) : "-")
                                .font(.system(size: 13))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            Toggle("Dateien vorher löschen", isOn: $deleteExistingFiles)
                                   .padding()
                        }
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: 200, alignment: .trailing)
                        .frame(height: 16)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            Picker("Zielplattform:", selection: self.$deviceSelection) {
                                ForEach(Config.allCases, content: { device in
                                    Text(device.devLabel).tag(device.rawValue)
                                })
                            }
                        }
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: 200, alignment: .trailing)
                    }
                }
                
                Spacer()
                    .frame(height: 10)
                
                VStack {
                    ProgressView("Fortschritt: ", value: output.plsProcessed, total: output.plsToProcess)
                }
                
                Spacer()
                    .frame(height: 10)
                
                VStack() {
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader{ reader in
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(output.progressText.indices, id:\.self) {
                                    Text(output.progressText[$0])
                                        .id($0)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .padding(0)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .background(Color.white)
                            .padding(10)
                            .onChange(of: output.progressText.count) { count in
                                withAnimation {
                                    reader.scrollTo(count - 1) // scroll to text-view with id
                                }
                            }
                        }
                    }
                    .lineLimit(nil)
                }
                .frame(height: 640)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(Color.white)
                .border(Color.gray, width: 1)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 20)
            
            HStack {
                Button(action: {
                    export(deviceSelection: self.deviceSelection, deleteExistingFiles: self.deleteExistingFiles)
                }) {
                    Text("Export")
                        .frame(maxWidth: 100, maxHeight: 28)
                }
                .buttonStyle(BlueButtonStyle())
                .disabled(output.isProcessing == true)
                
                Button(action: {
                    exit(0)
                }) {
                    Text("Beenden")
                        .frame(maxWidth: 100, maxHeight: 28)
                }
                .buttonStyle(BlueButtonStyle())
                .disabled(output.isProcessing == true)
            }
        }
        .padding(10)
    }
    
    var buttonColor: Color {
        return (output.isProcessing) ? .accentColor : .gray
    }
}

struct BlueButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(!isEnabled ? Color.gray : (configuration.isPressed ? Color.blue : Color.white))
            .background(!isEnabled ? Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 0.4) : (configuration.isPressed ? Color.white : Color.blue))
            .blur(radius: !isEnabled ? 1 : 0)
            .cornerRadius(8.0)
            .padding(0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
