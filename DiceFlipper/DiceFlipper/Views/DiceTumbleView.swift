import SwiftUI
import SceneKit

struct DiceTumbleView: UIViewRepresentable {
    let sides: Int
    let isRolling: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false

        let scene = SCNScene()
        scnView.scene = scene

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4.5)
        scene.rootNode.addChildNode(cameraNode)

        // Ambient fill
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 350
        scene.rootNode.addChildNode(ambient)

        // Key light — upper-left
        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .omni
        key.light?.intensity = 1000
        key.position = SCNVector3(-2, 3, 5)
        scene.rootNode.addChildNode(key)

        // Rim light — back-right for depth
        let rim = SCNNode()
        rim.light = SCNLight()
        rim.light?.type = .omni
        rim.light?.intensity = 300
        rim.position = SCNVector3(3, -2, -4)
        scene.rootNode.addChildNode(rim)

        // Dice node — geometry assigned in updateUIView
        let diceNode = SCNNode()
        scene.rootNode.addChildNode(diceNode)
        context.coordinator.diceNode = diceNode
        context.coordinator.currentSides = -1   // force first geometry build

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // Rebuild geometry when die type changes
        if sides != context.coordinator.currentSides {
            context.coordinator.currentSides = sides
            context.coordinator.diceNode?.geometry = makeGeometry(sides: sides)
        }

        // Only fire animation on the rising edge of isRolling
        let wasRolling = context.coordinator.wasRolling
        context.coordinator.wasRolling = isRolling
        guard isRolling, !wasRolling else { return }
        guard let node = context.coordinator.diceNode else { return }

        node.removeAllActions()

        // Phase 1: fast tumble (easeIn)
        let phase1 = SCNAction.rotateBy(
            x: CGFloat.pi * 3.5,
            y: CGFloat.pi * 5.0,
            z: 0,
            duration: 0.35
        )
        phase1.timingMode = .easeIn

        // Phase 2: settle (easeOut)
        let phase2 = SCNAction.rotateBy(
            x: CGFloat.pi * 0.2,
            y: CGFloat.pi * 0.2,
            z: 0,
            duration: 0.35
        )
        phase2.timingMode = .easeOut

        node.runAction(SCNAction.sequence([phase1, phase2]))
    }

    // MARK: - Geometry

    private func makeGeometry(sides: Int) -> SCNGeometry {
        let geo: SCNGeometry
        switch sides {
        case 4:  geo = tetrahedron()
        case 6:  geo = SCNBox(width: 1.8, height: 1.8, length: 1.8, chamferRadius: 0.18)
        case 8:  geo = octahedron()
        case 20: geo = icosahedron()
        default: geo = SCNSphere(radius: 1.2)
        }

        let mat = SCNMaterial()
        mat.diffuse.contents = diceColor(sides: sides)
        mat.specular.contents = UIColor.white.withAlphaComponent(0.9)
        mat.shininess = 30
        mat.lightingModel = .blinn
        geo.materials = [mat]
        return geo
    }

    private func diceColor(sides: Int) -> UIColor {
        switch sides {
        case 4:  return UIColor(red: 0.98, green: 0.45, blue: 0.09, alpha: 1)  // orange
        case 6:  return UIColor(red: 0.31, green: 0.27, blue: 0.90, alpha: 1)  // purple
        case 8:  return UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)  // blue
        case 10: return UIColor(red: 0.08, green: 0.72, blue: 0.65, alpha: 1)  // teal
        case 12: return UIColor(red: 0.13, green: 0.77, blue: 0.37, alpha: 1)  // green
        case 20: return UIColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1)  // indigo
        default: return UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1)  // gray
        }
    }

    // MARK: - Polyhedron helpers

    // Tetrahedron — 4 vertices, 4 triangular faces
    // Vertices at (±1, ±1, ±1) with even number of sign flips; circumradius = √3 → scaled to ≈1.3
    private func tetrahedron() -> SCNGeometry {
        let s: Float = 0.75
        let verts: [SCNVector3] = [
            SCNVector3( s,  s,  s),
            SCNVector3(-s, -s,  s),
            SCNVector3(-s,  s, -s),
            SCNVector3( s, -s, -s),
        ]
        let idx: [Int32] = [
            0, 1, 2,
            0, 2, 3,
            0, 3, 1,
            1, 3, 2,
        ]
        return buildGeometry(vertices: verts, indices: idx)
    }

    // Octahedron — 6 vertices, 8 triangular faces; circumradius = 1.0 → scaled to 1.3
    private func octahedron() -> SCNGeometry {
        let s: Float = 1.3
        let verts: [SCNVector3] = [
            SCNVector3( s, 0, 0), SCNVector3(-s, 0, 0),
            SCNVector3(0,  s, 0), SCNVector3(0, -s, 0),
            SCNVector3(0, 0,  s), SCNVector3(0, 0, -s),
        ]
        let idx: [Int32] = [
            0, 2, 4,  2, 1, 4,  1, 3, 4,  3, 0, 4,
            2, 0, 5,  1, 2, 5,  3, 1, 5,  0, 3, 5,
        ]
        return buildGeometry(vertices: verts, indices: idx)
    }

    // Icosahedron — 12 vertices, 20 triangular faces; circumradius ≈ 1.90 → scaled to ≈1.3
    private func icosahedron() -> SCNGeometry {
        let phi: Float = (1 + sqrt(5)) / 2
        let s: Float = 0.684   // = 1.3 / circumradius
        let verts: [SCNVector3] = [
            SCNVector3(-s,  phi*s, 0), SCNVector3( s,  phi*s, 0),
            SCNVector3(-s, -phi*s, 0), SCNVector3( s, -phi*s, 0),
            SCNVector3(0, -s,  phi*s), SCNVector3(0,  s,  phi*s),
            SCNVector3(0, -s, -phi*s), SCNVector3(0,  s, -phi*s),
            SCNVector3( phi*s, 0, -s), SCNVector3( phi*s, 0,  s),
            SCNVector3(-phi*s, 0, -s), SCNVector3(-phi*s, 0,  s),
        ]
        let idx: [Int32] = [
             0, 11,  5,   0,  5,  1,   0,  1,  7,   0,  7, 10,   0, 10, 11,
             1,  5,  9,   5, 11,  4,  11, 10,  2,  10,  7,  6,   7,  1,  8,
             3,  9,  4,   3,  4,  2,   3,  2,  6,   3,  6,  8,   3,  8,  9,
             4,  9,  5,   2,  4, 11,   6,  2, 10,   8,  6,  7,   9,  8,  1,
        ]
        return buildGeometry(vertices: verts, indices: idx)
    }

    private func buildGeometry(vertices: [SCNVector3], indices: [Int32]) -> SCNGeometry {
        let src = SCNGeometrySource(vertices: vertices)
        let elem = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [src], elements: [elem])
    }

    // MARK: - Coordinator

    class Coordinator {
        var diceNode: SCNNode?
        var wasRolling = false
        var currentSides = 0
    }
}
