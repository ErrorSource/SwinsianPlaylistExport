//
//  ViewControl.swift
//  Playlist Export
//
//  Created by Georg Kemser on 19.11.21.
//

import Foundation
import SwiftUI

// *** textfield ***
func clearOutput() {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        output.progressText = [""]
    }
}

func clearProgressBar() {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        objects.fldToProcess = 0.0
        objects.plsToProcess = 1.0 // !
        objects.plsProcessed = 0.0
        
        folderToProcess(newVal: objects.fldToProcess)
        filesProcessed(newVal: objects.plsProcessed)
        fileToProcess(newVal: objects.plsToProcess)
    }
}

func appendOutput(text: String) {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    DispatchQueue.main.async() {
        output.progressText.append(text + "\n")
    }
}

func appendError(errormsg: String) {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        output.progressText.append("*** Fehler: \(errormsg)\n")
    }
}

// *** progress bar ***
func folderToProcess(newVal: Double) {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        output.fldToProcess = newVal
    }
}

func fileToProcess(newVal: Double) {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        output.plsToProcess = newVal
    }
}

func filesProcessed(newVal: Double) {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        output.plsProcessed = newVal
    }
}

func isProcessing(state: Bool) {
    // reference to textfield-reference
    @ObservedObject var output = Output.sharedInstance
    
    DispatchQueue.main.async() {
        output.isProcessing = state
    }
}
