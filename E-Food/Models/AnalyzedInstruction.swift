//
//  AnalyzedInstruction.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

struct AnalyzedInstruction: Decodable, Identifiable {
    let name: String
    let steps: [InstructionStep]
    
    // Use the name for Identifiable conformance, as it's often unique per instruction set
    var id: String { name }
}
