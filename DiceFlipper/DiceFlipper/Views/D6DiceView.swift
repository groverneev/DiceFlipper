import SwiftUI
import SceneKit

/// SceneKit-backed d6 that rolls into the requested face instead of snapping
/// to it after the visible motion has already ended.
struct D6DiceView: UIViewRepresentable {
    let result: Int
    let targetResult: Int
    let rollTrigger: Int
    let onRollComplete: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onRollComplete: onRollComplete)
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false

        let scene = SCNScene()
        scnView.scene = scene

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 34
        camera.camera?.wantsHDR = true
        camera.position = SCNVector3(x: 0, y: 3.2, z: 5.8)
        camera.eulerAngles = SCNVector3(-0.52, 0, 0)
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 210
        ambient.light?.color = UIColor(white: 0.92, alpha: 1)
        scene.rootNode.addChildNode(ambient)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .omni
        fill.light?.intensity = 420
        fill.light?.color = UIColor(red: 0.86, green: 0.89, blue: 0.98, alpha: 1)
        fill.position = SCNVector3(x: -4.2, y: 1.8, z: 3.2)
        scene.rootNode.addChildNode(fill)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .spot
        key.light?.intensity = 1050
        key.light?.spotInnerAngle = 34
        key.light?.spotOuterAngle = 72
        key.light?.castsShadow = true
        key.light?.shadowMode = .deferred
        key.light?.shadowSampleCount = 16
        key.light?.shadowRadius = 8
        key.light?.shadowColor = UIColor.black.withAlphaComponent(0.26)
        key.position = SCNVector3(x: 3.3, y: 6.4, z: 4.8)
        key.look(at: SCNVector3(0, 0.2, 0))
        scene.rootNode.addChildNode(key)

        let rim = SCNNode()
        rim.light = SCNLight()
        rim.light?.type = .omni
        rim.light?.intensity = 250
        rim.light?.color = UIColor(red: 0.75, green: 0.82, blue: 0.98, alpha: 1)
        rim.position = SCNVector3(x: -4.6, y: 4.3, z: -4.2)
        scene.rootNode.addChildNode(rim)

        let floor = SCNNode(geometry: SCNPlane(width: 6.5, height: 6.5))
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.03)
        floor.geometry?.firstMaterial?.isDoubleSided = true
        floor.geometry?.firstMaterial?.lightingModel = .constant
        floor.eulerAngles.x = -.pi / 2
        floor.position = SCNVector3(x: 0, y: -1.08, z: 0)
        floor.opacity = 0.9
        scene.rootNode.addChildNode(floor)

        let box = SCNBox(width: 1.85, height: 1.85, length: 1.85, chamferRadius: 0.18)
        box.materials = [2, 3, 5, 4, 1, 6].map { makeFaceMaterial(value: $0) }

        let diceNode = SCNNode(geometry: box)
        diceNode.castsShadow = true
        diceNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(diceNode)

        context.coordinator.diceNode = diceNode
        context.coordinator.currentResult = result
        context.coordinator.currentRollTrigger = rollTrigger
        diceNode.simdOrientation = restingOrientation(for: result, yawIndex: 0)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        context.coordinator.onRollComplete = onRollComplete

        guard let node = context.coordinator.diceNode else { return }

        if rollTrigger != context.coordinator.currentRollTrigger {
            context.coordinator.currentRollTrigger = rollTrigger
            context.coordinator.currentResult = targetResult
            context.coordinator.startRoll(on: node, targetResult: targetResult, finalOrientation: restingOrientation(for: targetResult, yawIndex: Int.random(in: 0..<4)))
            return
        }

        if result != context.coordinator.currentResult {
            context.coordinator.currentResult = result
            node.removeAllActions()
            node.position = SCNVector3(0, 0, 0)
            node.simdOrientation = restingOrientation(for: result, yawIndex: 0)
        }
    }

    // MARK: - Orientation helpers

    private func restingOrientation(for value: Int, yawIndex: Int) -> simd_quatf {
        let yawAngles: [Float] = [0, .pi / 2, .pi, 3 * .pi / 2]
        let faceUp = faceUpQuaternion(for: value)
        let yaw = simd_quatf(angle: yawAngles[yawIndex % yawAngles.count], axis: simd_float3(0, 1, 0))
        return simd_normalize(yaw * faceUp)
    }

    // SCNBox material order: front(+Z), right(+X), back(-Z), left(-X), top(+Y), bottom(-Y)
    private func faceUpQuaternion(for value: Int) -> simd_quatf {
        switch value {
        case 1:
            return simd_quatf(angle: 0, axis: simd_float3(0, 1, 0))
        case 2:
            return simd_quatf(angle: -.pi / 2, axis: simd_float3(1, 0, 0))
        case 3:
            return simd_quatf(angle: .pi / 2, axis: simd_float3(0, 0, 1))
        case 4:
            return simd_quatf(angle: -.pi / 2, axis: simd_float3(0, 0, 1))
        case 5:
            return simd_quatf(angle: .pi / 2, axis: simd_float3(1, 0, 0))
        case 6:
            return simd_quatf(angle: .pi, axis: simd_float3(1, 0, 0))
        default:
            return simd_quatf(angle: 0, axis: simd_float3(0, 1, 0))
        }
    }

    // MARK: - Materials

    private func makeFaceMaterial(value: Int) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = makeFaceTexture(value: value)
        material.metalness.contents = 0.02
        material.roughness.contents = 0.42
        material.specular.contents = UIColor.white.withAlphaComponent(0.12)
        material.shininess = 0.18
        material.lightingModel = .physicallyBased
        material.fresnelExponent = 0.6
        return material
    }

    private func makeFaceTexture(value: Int) -> UIImage {
        let size = CGSize(width: 300, height: 300)

        return UIGraphicsImageRenderer(size: size).image { _ in
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            let rect = CGRect(origin: .zero, size: size)
            let cornerRadius: CGFloat = 50

            UIColor(red: 0.97, green: 0.97, blue: 0.985, alpha: 1).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).fill()

            let faceGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.white.withAlphaComponent(0.98).cgColor,
                    UIColor(red: 0.92, green: 0.93, blue: 0.97, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            ctx.saveGState()
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            ctx.drawLinearGradient(
                faceGradient,
                start: CGPoint(x: size.width * 0.2, y: 0),
                end: CGPoint(x: size.width * 0.85, y: size.height),
                options: []
            )
            ctx.restoreGState()

            UIColor(red: 0.76, green: 0.79, blue: 0.88, alpha: 0.7).setStroke()
            let borderRect = rect.insetBy(dx: 8, dy: 8)
            let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - 8)
            borderPath.lineWidth = 4
            borderPath.stroke()

            UIColor(red: 0.42, green: 0.47, blue: 0.60, alpha: 0.92).setStroke()
            let outerBorderRect = rect.insetBy(dx: 18, dy: 18)
            let outerBorderPath = UIBezierPath(
                roundedRect: outerBorderRect,
                cornerRadius: cornerRadius - 18
            )
            outerBorderPath.lineWidth = 10
            outerBorderPath.stroke()

            let highlightGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.white.withAlphaComponent(0.45).cgColor,
                    UIColor.clear.cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            ctx.saveGState()
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            ctx.drawRadialGradient(
                highlightGradient,
                startCenter: CGPoint(x: size.width * 0.28, y: size.height * 0.2),
                startRadius: 8,
                endCenter: CGPoint(x: size.width * 0.28, y: size.height * 0.2),
                endRadius: size.width * 0.5,
                options: []
            )
            ctx.restoreGState()

            UIColor(red: 0.16, green: 0.20, blue: 0.32, alpha: 1).setFill()
            for position in dotPositions(for: value) {
                let radius: CGFloat = value == 1 ? 28 : 24
                let pipRect = CGRect(
                    x: position.x * size.width - radius,
                    y: position.y * size.height - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                UIBezierPath(ovalIn: pipRect).fill()
            }
        }
    }

    private func dotPositions(for value: Int) -> [CGPoint] {
        switch value {
        case 1:
            return [CGPoint(x: 0.5, y: 0.5)]
        case 2:
            return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.7, y: 0.7)]
        case 3:
            return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.7, y: 0.7)]
        case 4:
            return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.7, y: 0.3), CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.7, y: 0.7)]
        case 5:
            return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.7, y: 0.3), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.7, y: 0.7)]
        case 6:
            return [CGPoint(x: 0.3, y: 0.22), CGPoint(x: 0.7, y: 0.22), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.3, y: 0.78), CGPoint(x: 0.7, y: 0.78)]
        default:
            return []
        }
    }

    // MARK: - Coordinator

    class Coordinator {
        var diceNode: SCNNode?
        var currentRollTrigger: Int = 0
        var currentResult: Int = 1
        var onRollComplete: () -> Void
        private var completionWorkItem: DispatchWorkItem?

        init(onRollComplete: @escaping () -> Void) {
            self.onRollComplete = onRollComplete
        }

        func startRoll(on node: SCNNode, targetResult: Int, finalOrientation: simd_quatf) {
            completionWorkItem?.cancel()
            node.removeAllActions()

            let startOrientation = simd_normalize(node.presentation.simdOrientation)
            node.simdOrientation = startOrientation
            node.position = node.presentation.position

            let randomAxisA = simd_normalize(simd_float3(
                Float.random(in: 0.55...1.0),
                Float.random(in: 0.25...0.7),
                Float.random(in: 0.35...0.9)
            ))
            let randomAxisB = simd_normalize(simd_float3(
                Float.random(in: -0.4...0.4),
                1,
                Float.random(in: -0.4...0.4)
            ))
            let overshootAxis = simd_normalize(simd_float3(
                Float.random(in: -0.15...0.15),
                1,
                Float.random(in: -0.15...0.15)
            ))

            let tumbleTurns = simd_quatf(angle: Float.random(in: 4.4...5.6) * .pi, axis: randomAxisA)
            let crossSpin = simd_quatf(angle: Float.random(in: 1.7...2.5) * .pi, axis: randomAxisB)
            let overshoot = simd_quatf(angle: Float.random(in: 0.12...0.22) * .pi, axis: overshootAxis)

            let midOrientation = simd_normalize((crossSpin * tumbleTurns) * startOrientation)
            let overshootOrientation = simd_normalize(overshoot * finalOrientation)

            let driftX = CGFloat.random(in: -0.2...0.2)
            let driftZ = CGFloat.random(in: -0.16...0.16)

            let hop = SCNAction.move(to: SCNVector3(driftX * 0.45, 0.34, driftZ * 0.4), duration: 0.18)
            hop.timingMode = .easeOut

            let sweep = SCNAction.move(to: SCNVector3(driftX, 0.08, driftZ), duration: 0.42)
            sweep.timingMode = .easeInEaseOut

            let settle = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.28)
            settle.timingMode = .easeOut

            let orientPhase1 = SCNAction.customAction(duration: 0.6) { node, elapsed in
                let progress = Float(elapsed / 0.6)
                node.simdOrientation = simd_slerp(startOrientation, midOrientation, progress)
            }

            let orientPhase2 = SCNAction.customAction(duration: 0.18) { node, elapsed in
                let progress = Float(elapsed / 0.18)
                node.simdOrientation = simd_slerp(midOrientation, overshootOrientation, progress)
            }

            let orientPhase3 = SCNAction.customAction(duration: 0.28) { node, elapsed in
                let progress = Float(elapsed / 0.28)
                node.simdOrientation = simd_slerp(overshootOrientation, finalOrientation, progress)
            }

            let moveSequence = SCNAction.sequence([hop, sweep, settle])
            let rotateSequence = SCNAction.sequence([orientPhase1, orientPhase2, orientPhase3])
            let finish = SCNAction.run { [weak self] node in
                node.simdOrientation = finalOrientation
                node.position = SCNVector3(0, 0, 0)
                self?.currentResult = targetResult
            }

            let totalDuration = 0.18 + 0.42 + 0.28
            let completion = DispatchWorkItem { [weak self] in
                self?.onRollComplete()
            }
            completionWorkItem = completion

            node.runAction(SCNAction.sequence([SCNAction.group([moveSequence, rotateSequence]), finish]))
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration, execute: completion)
        }
    }
}
