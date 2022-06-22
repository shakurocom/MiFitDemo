import UIKit
import Lottie

final class MiFitToogleOpenButton: UIControl {

    private var openAnimationView: LOTAnimationView
    private var closeAnimationView: LOTAnimationView

    var isOpen: Bool = false {
        didSet {
            openAnimationView.isHidden = isOpen
            closeAnimationView.isHidden = !isOpen

            if isOpen {
                openAnimationView.stop()
            } else {
                closeAnimationView.stop()
            }
            invalidateIntrinsicContentSize()
        }
    }

    override init(frame: CGRect) {
        let podBundle = Bundle(for: MiFitToogleOpenButton.self)
        if let bundleURL = podBundle.url(forResource: "MiFit", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL) {
            self.openAnimationView = LOTAnimationView(name: "play_pause", bundle: bundle)
            self.closeAnimationView = LOTAnimationView(name: "pause_play", bundle: bundle)
        } else {
            self.openAnimationView = LOTAnimationView(name: "play_pause")
            self.closeAnimationView = LOTAnimationView(name: "pause_play")
        }
        super.init(frame: frame)

        self.commomInit()
    }

    required init?(coder: NSCoder) {
        let podBundle = Bundle(for: MiFitToogleOpenButton.self)
        if let bundleURL = podBundle.url(forResource: "MiFit", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL) {
            self.openAnimationView = LOTAnimationView(name: "play_pause", bundle: bundle)
            self.closeAnimationView = LOTAnimationView(name: "pause_play", bundle: bundle)
        } else {
            self.openAnimationView = LOTAnimationView(name: "play_pause")
            self.closeAnimationView = LOTAnimationView(name: "pause_play")
        }
        super.init(coder: coder)

        self.commomInit()
    }

    override var intrinsicContentSize: CGSize {
        return openAnimationView.isHidden ? closeAnimationView.intrinsicContentSize : openAnimationView.intrinsicContentSize
    }

    func runToogleOpenAnimation() {
        isEnabled = false
        let completionClosure: (Bool) -> Void = { [weak self] (_) in
            guard let actualSelf = self else {
                return
            }
            actualSelf.isOpen.toggle()
            actualSelf.isEnabled = true
        }
        if isOpen {
            closeAnimationView.play(completion: completionClosure)
        } else {
            openAnimationView.play(completion: completionClosure)
        }
    }
}

// MARK: - Private

private extension MiFitToogleOpenButton {
    private func commomInit() {
        accessibilityTraits = .button
        backgroundColor = .clear

        openAnimationView.clipsToBounds = false
        openAnimationView.translatesAutoresizingMaskIntoConstraints = false
        openAnimationView.contentMode = .scaleAspectFit
        openAnimationView.isUserInteractionEnabled = false

        closeAnimationView.clipsToBounds = false
        closeAnimationView.translatesAutoresizingMaskIntoConstraints = false
        closeAnimationView.contentMode = .scaleAspectFit
        closeAnimationView.isUserInteractionEnabled = false

        addSubview(openAnimationView)
        addSubview(closeAnimationView)

        openAnimationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        openAnimationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        openAnimationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        openAnimationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        closeAnimationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        closeAnimationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        closeAnimationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        closeAnimationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
