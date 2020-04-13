//
//  ViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import AlamofireImage


var topViewPositionLimit: CGFloat = 200
var topViewInitialPosition: CGFloat?
var topViewFinalPosition: CGFloat?
var topViewTopConstraintRange: Range<CGFloat>?

class HomeViewController: UIViewController {
    let tabsCount = AppConstants.home_tab_titles.count
    
    @IBOutlet weak var statusBarImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var tabBarCollectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    
    var pageViewController = UIPageViewController()
    var selectedTabView = UIView()
    var pageCollection = Util.PageCollection()
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var task: DispatchWorkItem?
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat
        
        switch gesture.state {
            
        case .began:
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            
        case .changed:
            
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            innerTableViewDidScroll(withDistance: dragYDiff)
            
        case .ended:
            innerTableViewScrollEnded()
            
        default: return
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupCollectionView()
        setupPagingViewController()
        populateBottomView()
        addPanGestureToTopViewAndCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topViewInitialPosition = 0
        topViewFinalPosition = -headerImageView.frame.height
        topViewTopConstraintRange = topViewFinalPosition! ..< topViewInitialPosition!
    }
    
    func setupHeader() {
        if let headerUrl = Util.getHeaderUrl() {
            if headerUrl.count > 0 {
                Util.loadCachedImage(url: headerUrl) { (image) in
                    self.headerImageView!.image = image
                }
            }
        }
    }
    
    func setupCollectionView() {
        let layout = tabBarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = CGSize(width: 100, height: 40)
        
        setupSelectedTabView()
    }
    
    func setupPagingViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    func populateBottomView() {
        
        for (index, requestType) in AppConstants.home_tab_types.enumerated() {
            let tabContentVC = UIStoryboard(name: "HomeContentView", bundle: nil).instantiateInitialViewController() as! HomeContentViewController
            tabContentVC.innerTableViewScrollDelegate = self
            tabContentVC.requestType = requestType
            
            let displayName = AppConstants.home_tab_titles[index]
            let page = Util.Page(with: displayName, _vc: tabContentVC)
            pageCollection.pages.append(page)
        }

        let initialPage = 0

        pageViewController.setViewControllers([pageCollection.pages[initialPage].vc],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)


        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        bottomView.addSubview(pageViewController.view)

        pinPagingViewControllerToBottomView()
    }
    
    func addPanGestureToTopViewAndCollectionView() {
        
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(topViewPanGesture)
    }
    
    func pinPagingViewControllerToBottomView() {
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
    }
    
    func setupSelectedTabView() {
        selectedTabView.frame = CGRect(x: 20, y: 45, width: 0, height: 5)
        selectedTabView.backgroundColor = .systemYellow
        tabBarCollectionView.addSubview(selectedTabView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.scrollSelectedTabView(toIndexPath: IndexPath(item: 0, section: 0))
        }
    }
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        
        pageViewController.setViewControllers([pageCollection.pages[index].vc],
                                                  direction: navigationDirection,
                                                  animated: true,
                                                  completion: nil)
    }
    
    func scrollSelectedTabView(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
        
        pageCollection.selectedPageIndex = indexPath.item
        
        UIView.animate(withDuration: 0.3) {
            
            if let cell = self.tabBarCollectionView.cellForItem(at: indexPath) {
                
                self.selectedTabView.frame.size.width = cell.frame.width
                self.selectedTabView.frame.origin.x = cell.frame.origin.x
            }
        }
    }
    
    func scrollToTop() {
        let contentViewController = pageCollection.pages[pageCollection.selectedPageIndex].vc
        contentViewController.tableView.setContentOffset(.zero, animated: true)
        scrollToInitialView()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageCollection.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let tabCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTabBarCellID, for: indexPath) as? HomeTabBarCell {
            
            tabCell.tabNameLabel.text = pageCollection.pages[indexPath.row].name
            return tabCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == pageCollection.selectedPageIndex {
            
            return
        }
        
        var direction: UIPageViewController.NavigationDirection
        
        if indexPath.item > pageCollection.selectedPageIndex {
            
            direction = .forward
            
        } else {
            
            direction = .reverse
        }
        
        pageCollection.selectedPageIndex = indexPath.item
        
        tabBarCollectionView.scrollToItem(at: indexPath,
                                          at: .centeredHorizontally,
                                          animated: true)
        
        scrollSelectedTabView(toIndexPath: indexPath)
        
        setBottomPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

extension HomeViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                
                // go to previous page in array
                
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                
                // go to next page in array
                
                return pageCollection.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.vc == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        
        scrollSelectedTabView(toIndexPath: indexPathAtCollectionView)
        tabBarCollectionView.scrollToItem(at: indexPathAtCollectionView,
                                          at: .centeredHorizontally,
                                          animated: true)
    }
}

extension HomeViewController: InnerTableViewScrollDelegate {
    var currentHeaderTop: CGFloat {
        
        return headerViewTopConstraint.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        let newConstant = headerViewTopConstraint.constant - scrollDistance
        
        if newConstant < topViewFinalPosition! {
            headerViewTopConstraint.constant = topViewFinalPosition!
        }
        else if newConstant > topViewPositionLimit/2.0 {
            headerViewTopConstraint.constant = headerViewTopConstraint.constant - scrollDistance*0.3
        } else if newConstant > topViewPositionLimit {
            headerViewTopConstraint.constant = topViewInitialPosition! - scrollDistance*0.1
        }
        else {
            headerViewTopConstraint.constant = newConstant
        }
    }
    
    func innerTableViewScrollEnded() {
        
        if headerViewTopConstraint.constant > topViewInitialPosition! {
            scrollToInitialView()
        }
    }
    
    func innerTableViewBounceEnded(withScrollView scrollView: UIScrollView) {
        if task != nil {
            task?.cancel()
        }
        
        task = DispatchWorkItem {
            if self.headerViewTopConstraint.constant > topViewInitialPosition! {
                
                if scrollView.isScrollEnabled {
                    scrollView.isScrollEnabled = false
                    scrollView.contentOffset.y = 0
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.scrollToInitialView()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        scrollView.isScrollEnabled = true
                        self.task = nil
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: task!)
    }

    func scrollToInitialView() {

        let topViewCurrentTop = headerImageView.frame.origin.y
        let distanceToBeMoved = abs(topViewCurrentTop - topViewInitialPosition!)
        var time = distanceToBeMoved / 500
        
        if time > 0.25 {
            time = 0.25
        }
        
        headerViewTopConstraint.constant = topViewInitialPosition!
        
        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }
}
