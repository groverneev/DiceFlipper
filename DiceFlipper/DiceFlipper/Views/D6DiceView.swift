import SwiftUI
import SceneKit

/// A SceneKit-backed d6 that shows a real 3D cube at rest and animates
/// a fall-onto-surface roll when `isRolling` transitions to true.
struct D6DiceView: UIViewRepresentable {
    let result: Int
    let isRolling: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false

        let scene = SCNScene()
        scnView.scene = scene

        // Camera — above and in front so top + front faces are both visible
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 50
        camera.position = SCNVector3(0, 3, 4.5)
        camera.eulerAngles = SCNVector3(-0.58, 0, 0)   // ≈ -33° tilt down
        scene.rootNode.addChildNode(camera)

        // Soft ambient fill
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 280
        scene.rootNode.addChildNode(ambient)

        // Key light — upper-left-front
        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .omni
        key.light?.intensity = 1100
        key.light?.color = UIColor.white
        key.position = SCNVector3(-3, 5, 6)
        scene.rootNode.addChildNode(key)

        // Rim light — back-right for edge definition
        let rim = SCNNode()
        rim.light = SCNLight()
        rim.light?.type = .omni
        rim.light?.intensity = 320
        rim.light?.color = UIColor(white: 0.7, alpha: 1)
        rim.position = SCNVector3(4, -1, -5)
        scene.rootNode.addChildNode(rim)

        // Cube — chamfered for realism
        // SCNBox material order: front(+Z), right(+X), back(-Z), left(-X), top(+Y), bottom(-Y)
        // Standard Western dice: 1 opposite 6, 2 opposite 5, 3 opposite 4
        let box = SCNBox(width: 1.8, height: 1.8, length: 1.8, chamferRadius: 0.22)
        box.materials = [2, 3, 5, 4, 1, 6].map { makeFaceMaterial(value: $0) }

        let diceNode = SCNNode(geometry: box)
        scene.rootNode.addChildNode(diceNode)
        context.coordinator.diceNode = diceNode

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        let wasRolling = context.coordinator.wasRolling
        context.coordinator.wasRolling = isRolling

        if isRolling, !wasRolling {
            startRoll(node: context.coordinator.diceNode!)
        } else if !isRolling, wasRolling {
            settleToFace(node: context.coordinator.diceNode!, value: result)
        }
    }

    // MARK: - Animation

    private func startRoll(node: SCNNode) {
        node.removeAllActions()
        node.position = SCNVector3(0, 5, 0)   // start above the frame

        // Phase 1 (0.45s easeIn): fall + tumble
        let fall = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.45)
        fall.timingMode = .easeIn
        let spin = SCNAction.rotateBy(
            x: CGFloat.pi * 4.5,
            y: CGFloat.pi * 6.0,
            z: CGFloat.pi * 0.4,
            duration: 0.45)
        spin.timingMode = .easeIn

        // Phase 2a (0.14s easeOut): small bounce up after landing
        let bounceUp = SCNAction.move(to: SCNVector3(0, 0.45, 0), duration: 0.14)
        bounceUp.timingMode = .easeOut

        // Phase 2b (0.21s easeIn): fall back down with a slight roll
        let bounceDown = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.21)
        bounceDown.timingMode = .easeIn
        let roll = SCNAction.rotateBy(
            x: CGFloat.pi * 0.25,
            y: CGFloat.pi * 0.35,
            z: 0, duration: 0.21)
        roll.timingMode = .easeIn

        let land = SCNAction.group([fall, spin])
        let bounce = SCNAction.sequence([bounceUp, SCNAction.group([bounceDown, roll])])
        node.runAction(SCNAction.sequence([land, bounce]))
    }

    private func settleToFace(node: SCNNode, value: Int) {
        node.removeAllActions()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.35
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        node.simdOrientation = faceUpQuaternion(for: value)
        node.position = SCNVector3(0, 0, 0)
        SCNTransaction.commit()
    }

    // MARK: - Face orientations
    //
    // Material slots: front(+Z)=2, right(+X)=3, back(-Z)=5, left(-X)=4, top(+Y)=1, bottom(-Y)=6
    // Rotation needed to bring each face's outward normal to world +Y:

    private func faceUpQuaternion(for value: Int) -> simd_quatf {
        switch value {
        case 1: return simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)                           // top(+Y) → already up
        case 2: return simd_quatf(angle: -.pi / 2, axis: simd_float3(1, 0, 0))         // front(+Z) → up
        case 3: return simd_quatf(angle:  .pi / 2, axis: simd_float3(0, 0, 1))         // right(+X) → up
        case 4: return simd_quatf(angle: -.pi / 2, axis: simd_float3(0, 0, 1))         // left(-X)  → up
        case 5: return simd_quatf(angle:  .pi / 2, axis: simd_float3(1, 0, 0))         // back(-Z)  → up
        case 6: return simd_quatf(angle:  .pi,     axis: simd_float3(1, 0, 0))         // bottom(-Y)→ up
        default: return simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        }
    }

    // MARK: - Texture generation

    private func makeFaceMaterial(value: Int) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = makeFaceTexture(value: value)
        mat.specular.contents = UIColor.white.withAlphaComponent(0.55)
        mat.shininess = 18
        mat.lightingModel = .blinn
        return mat
    }

    private func makeFaceTexture(value: Int) -> UIImage {
        let sz = CGSize(width: 256, height: 256)
        return UIGraphicsImageRenderer(size: sz).image { _ in
            guard let ctx = UIGraphicsGetCurrentContext() else { return }

            // Base — rounded square, die colour
            UIColor(red: 0.27, green: 0.23, blue: 0.84, alpha: 1).setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: sz), cornerRadius: 44).fill()

            // Subtle top-highlight gradient for perceived depth on each face
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.white.withAlphaComponent(0.20).cgColor,
                         UIColor.clear.cgColor] as CFArray,
                locations: [0, 0.55])!
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: sz.width / 2, y: 0),
                end:   CGPoint(x: sz.width / 2, y: sz.height * 0.65),
                options: [])

            // Dots
            UIColor.white.setFill()
            for pos in dotPositions(for: value) {
                let r: CGFloat = 25
                UIBezierPath(ovalIn: CGRect(
                    x: pos.x * sz.width  - r,
                    y: pos.y * sz.height - r,
                    width: r * 2, height: r * 2)).fill()
            }
        }
    }

    private func dotPositions(for value: Int) -> [CGPoint] {
        switch value {
        case 1: return [.init(x: 0.5, y: 0.5)]
        case 2: return [.init(x: 0.3, y: 0.3), .init(x: 0.7, y: 0.7)]
        case 3: return [.init(x: 0.3, y: 0.3), .init(x: 0.5, y: 0.5), .init(x: 0.7, y: 0.7)]
        case 4: return [.init(x: 0.3, y: 0.3), .init(x: 0.7, y: 0.3),
                        .init(x: 0.3, y: 0.7), .init(x: 0.7, y: 0.7)]
        case 5: return [.init(x: 0.3, y: 0.3), .init(x: 0.7, y: 0.3),
                        .init(x: 0.5, y: 0.5),
                        .init(x: 0.3, y: 0.7), .init(x: 0.7, y: 0.7)]
        case 6: return [.init(x: 0.3, y: 0.22), .init(x: 0.7, y: 0.22),
                        .init(x: 0.3, y: 0.50), .init(x: 0.7, y: 0.50),
                        .init(x: 0.3, y: 0.78), .init(x: 0.7, y: 0.78)]
        default: return []
        }
    }

    // MARK: - Coordinator

    class Coordinator {
        var diceNode: SCNNode?
        var wasRolling = false
    }
}
