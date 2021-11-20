import UIKit

protocol PageAware: AnyObject {
  func pageDidShow()
}

class PagesController: UIViewController {

  let controllers: [UIViewController]

  lazy var scrollView: UIScrollView = self.makeScrollView()
  lazy var scrollViewContentView: UIView = UIView()
  lazy var pageIndicator: PageIndicator = self.makePageIndicator()

  var selectedIndex: Int = 0
  let once = Once()

  // MARK: - Initialization

  required init(controllers: [UIViewController]) {
    self.controllers = controllers

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black
    setup()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard scrollView.frame.size.width > 0 else {
      return
    }

    once.run {
      DispatchQueue.main.async {
        self.scrollToAndSelect(index: self.selectedIndex, animated: false)
      }

      notify()
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let index = selectedIndex

    coordinator.animate(alongsideTransition: { context in
      self.scrollToAndSelect(index: index, animated: context.isAnimated)
    })

    super.viewWillTransition(to: size, with: coordinator)
  }

  // MARK: - Controls

  func makeScrollView() -> UIScrollView {
    let newScrollView = UIScrollView()
    newScrollView.isPagingEnabled = true
    newScrollView.showsHorizontalScrollIndicator = false
    newScrollView.alwaysBounceHorizontal = false
    newScrollView.bounces = false
    newScrollView.delegate = self

    return newScrollView
  }

  func makePageIndicator() -> PageIndicator {
    let items = controllers.compactMap { $0.title }
    let indicator = PageIndicator(items: items)
    indicator.delegate = self

    return indicator
  }

  // MARK: - Setup

  func setup() {
    let usePageIndicator = controllers.count > 1
    if usePageIndicator {
      view.addSubview(pageIndicator)
      Constraint.on(
        pageIndicator.leftAnchor.constraint(equalTo: pageIndicator.superview!.leftAnchor),
        pageIndicator.rightAnchor.constraint(equalTo: pageIndicator.superview!.rightAnchor),
        pageIndicator.heightAnchor.constraint(equalToConstant: 40)
      )

      if #available(iOS 11, *) {
        Constraint.on(
          pageIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        )
      } else {
        Constraint.on(
          pageIndicator.bottomAnchor.constraint(equalTo: pageIndicator.superview!.bottomAnchor)
        )
      }
    }

    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContentView)

    scrollView.gPinUpward()
    if usePageIndicator {
      scrollView.gPin(on: .bottom, view: pageIndicator, on: .top)
    } else {
      scrollView.gPinDownward()
    }

    scrollViewContentView.gPinEdges()

    for (i, controller) in controllers.enumerated() {
      addChild(controller)
      scrollViewContentView.addSubview(controller.view)
      controller.didMove(toParent: self)

      controller.view.gPin(on: .top)
      controller.view.gPin(on: .bottom)
      controller.view.gPin(on: .width, view: scrollView)
      controller.view.gPin(on: .height, view: scrollView)

      if i == 0 {
        controller.view.gPin(on: .left)
      } else {
        controller.view.gPin(on: .left, view: self.controllers[i-1].view, on: .right)
      }

      if i == self.controllers.count - 1 {
        controller.view.gPin(on: .right)
      }
    }
  }

  // MARK: - Index

  fileprivate func scrollTo(index: Int, animated: Bool) {
    guard !scrollView.isTracking && !scrollView.isDragging && !scrollView.isZooming else {
      return
    }

    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
    scrollView.setContentOffset(point, animated: animated)
  }

  fileprivate func scrollToAndSelect(index: Int, animated: Bool) {
    scrollTo(index: index, animated: animated)
    pageIndicator.select(index: index, animated: animated)
  }

  func updateAndNotify(_ index: Int) {
    guard selectedIndex != index else { return }

    selectedIndex = index
    notify()
  }

  func notify() {
    if let controller = controllers[selectedIndex] as? PageAware {
      controller.pageDidShow()
    }
  }
}

extension PagesController: PageIndicatorDelegate {

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    scrollTo(index: index, animated: false)
    updateAndNotify(index)
  }
}

extension PagesController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    pageIndicator.select(index: index)
    updateAndNotify(index)
  }
}
