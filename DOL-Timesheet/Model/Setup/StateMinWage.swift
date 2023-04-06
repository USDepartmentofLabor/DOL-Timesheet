//
//  StateMinWage.swift
//  MSHA-Miners
//
//  Created by Greg Gruse on 4/20/22.
//

import Foundation
import SwiftUI

public class StateMinWage {
    
    var data: [StateItem]
    
    init() {
        self.data = StateMinWage.readData(fileName: "StateMinimumWages").states
    }
    
    static func readData(fileName: String) -> States {
        let fileName = Bundle.main.path(forResource: fileName, ofType: "json")
        
        let jsonString = try! String(contentsOfFile: fileName ?? "Error")//read data
        
        let jsonData = Data(jsonString.utf8)
        
        let decoder = JSONDecoder()

        do {
            let stateData = try decoder.decode(StateDataDetails.self, from: jsonData)
            var stateItems: [StateItem] = []
            stateData.stateMinimumWages.forEach { state in
                stateItems.append(
                    StateItem(
                        state: state.state,
                        minimumWage: state.minimumWage,
                        altMinimumWage: state.altMinimumWage
                    )
                )
            }
            return States(states: stateItems)
        } catch {
            return States(states: [])
        }
    }
    
    public struct States: Codable {
        var states: [StateItem]
    }
    
    public struct StateItem: Codable {
        var state = "Title"
        var minimumWage:Double? = 8.75
        var altMinimumWage:Double? = 8.75
    }
    
    public struct StateDataDetails: Codable {
        var stateMinimumWages: [StateDetail]
    }
    
    public struct StateDetail: Codable {
        var state = "state"
        var minimumWage:Double? = 8.75
        var altMinimumWage:Double? = 8.75
    }
}
