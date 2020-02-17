//
//  SMDashboardViewController.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 06/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

private let kMinimumTypingInterval: TimeInterval = 0.5 // We will start hitting server for search result after this time interval.
private let kMinimumLettersForSearch: Int = 3 // We are getting "Too many results" error from server. So, we set minimum characters to be available for proceeding search.
private let kPaginationCount: Int = 10
private let kSearchTextKey = "search_text"
private let kPageKey = "page"

class SMDashboardViewController: SMViewController {
    
    @IBOutlet weak private var contentTypeSegment: UISegmentedControl!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var infoLabel: SMLabel!
    
    private var searchedText: String?
    private var previouslySearchedText: String?
    private var refreshControl: UIRefreshControl?
    private var shouldShowPaginationCell: Bool = false
    private var searchMetaData: [String : Any]?
    private var loadingView: SMLoadingView?
    
    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDefaultSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        process(searchText: searchBar.text, isRefresh: true)
    }
    
    
    // MARK: Action methods
    
    @IBAction func typeChanged(_ sender: Any) {
        configureDefaultSearch()
        process(searchText: searchBar.text, isRefresh: true)
    }
    
    
    // MARK: - Custom methods
    
    /**Configure the initial UI and setup*/
    func configureUI() {
        // Initialise loading view and set it as custom title view. We use this as loading indicator when making API calls.
        if let loadingView = Bundle.main.loadNibNamed("SMLoadingView", owner: self, options: nil)?.first as? SMLoadingView, self.loadingView == nil {
            self.loadingView = loadingView
            self.loadingView?.hideLoading()
            navigationItem.titleView = self.loadingView
        }
        hideInfoLabel()
        addRefreshControl()
    }
    
    /**Add pull to refresh functionality to table view*/
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTableViewData), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    /**Table view pull to refresh action*/
    @objc func refreshTableViewData() {
        SMContentManager.shared.clearAll()
        process(searchText: searchBar.text, isRefresh: true)
    }
    
    /**Set default search text based and placeholder on selected content type*/
    func configureDefaultSearch() {
        resetDetails() // Clear existing content.
        if contentTypeSegment.selectedSegmentIndex == 0 { // Movie content type.
            searchBar.placeholder = NSLocalizedString("kMovieSearchBarPlaceholder", comment: "Placeholder text")
            searchBar.text = NSLocalizedString("kMovieDefaultSearchText", comment: "Default search text")
        } else { // Show content type.
            searchBar.placeholder = NSLocalizedString("kShowSearchBarPlaceholder", comment: "Placeholder text")
            searchBar.text = NSLocalizedString("kShowDefaultSearchText", comment: "Default search text")
        }
    }
    
    /**Start loading indicator in navigation bar to denote data is being fetch from server*/
    func startLoading() {
        loadingView?.showLoading()
    }
    
    /**Stop loading indicator in navigation bar*/
    func stopLoading() {
        refreshControl?.endRefreshing()
        loadingView?.hideLoading()
    }
    
    /**Fetch contents from server for given search text*/
    func fetchContents(for searchText: String?, page: Int = 1) {
        if kAppDelegate?.isHavingNetworkReachability() == false { // Check internet connection and react.
            showAlert(with: NSLocalizedString("kInternetOfflineMessage", comment: "Error message"))
            return
        }
        
        startLoading()
        var type = SMContentType.Movie
        if contentTypeSegment.selectedSegmentIndex == 1 { // Configure type paramter for api request based on select index in typeSegment
            type = .Show
        }
        SMContentManager.shared.fetchContents(for: searchText, type: type, page: page, successBlock: { [weak self] (_, _) in
            self?.stopLoading()
            self?.checkPaginationStatus()
            if (SMContentManager.shared.contents?.count ?? 0) > 0 {
                self?.hideInfoLabel()
                self?.reloadTableView()
            } else {
                self?.showInfoLabel(with: NSLocalizedString("KNoSearchResults", comment: "Error message"))
            }
        }) { [weak self] (response, cancelStatus) in
            self?.stopLoading()
            self?.checkPaginationStatus()
            if cancelStatus { // Do nothing, if request was cancelled
                return
            }
            if let errorJSON = response?.result.value as? [String: Any], let errorMessage = errorJSON["Error"] as? String {
                self?.showInfoLabel(with: errorMessage)
            } else {
                self?.showInfoLabel(with: NSLocalizedString("kCommonErrorMessage", comment: "Error message"))
            }
        }
    }
    
    /**Check currently fetched data and total available results for given search text. Based on this, decide whether pagnation is needed or not*/
    func checkPaginationStatus() {
        if let fetchedContentsCount = SMContentManager.shared.contents?.count, let totalResultsString = SMContentManager.shared.totalResults, let totalResults = Int(totalResultsString), fetchedContentsCount < totalResults {
            self.shouldShowPaginationCell = true
        } else {
            self.shouldShowPaginationCell = false
        }
    }
    
    /**Show alert with given message*/
    func showAlert(with message: String?) {
        if let message = message {
            let alert = UIAlertController(title: NSLocalizedString("kErrorAlertTitle", comment: "Alert title"), message: message, preferredStyle: .alert)
            let okayButtonAction = UIAlertAction(title: NSLocalizedString("kOkayButtonTitle", comment: "Button title"), style: .default, handler: nil)
            alert.addAction(okayButtonAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /**Reload table view*/
    func reloadTableView() {
        tableView.reloadData()
    }
    
    /**App connected to online, do things when app connected to internet*/
    override func networkConnectedViaLANorWIFI() {
        process(searchText: searchBar.text, isRefresh: true)
    }
    
    /**App enters forground*/
    override func appWillEnterForeground() {
        process(searchText: searchBar.text, isRefresh: true)
    }
    
    /**Format the search text before searching contents*/
    func format(searchText: String?) -> String? {
        return searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /**Process search text for hitting API to get contents from server*/
    func process(searchText: String?, with delay: TimeInterval = kMinimumTypingInterval, isRefresh: Bool = false, page: Int = 1) {
        cancelPreviousyScheduledActions()
        
        guard let formattedSearchText = format(searchText: searchText ?? "") else { return }
        if formattedSearchText.count < kMinimumLettersForSearch { // User entered less than `kMinimumLettersForSearch`. Just ignore.
            resetDetails()
            return
        }
        previouslySearchedText = format(searchText: searchText ?? "")
        if searchText?.isEmpty == true { // If user clicks clear button or deleted all text, no need to add `kMinimumTypingInterval` delay in clearing text and show result.
            resetDetails()
        }  else {
            if !isRefresh { // Check whether this call is for refreshing contents for same search text.
                if (searchedText == previouslySearchedText){ // After formatting `searchText`, if we get the same previously searched text we should not do anything. This is for performance optimisation.
                    return
                } else {
                    SMContentManager.shared.currentPage = 0
                    SMContentManager.shared.totalResults = nil
                }
            }
            
            searchedText = previouslySearchedText
            searchMetaData = [kSearchTextKey: previouslySearchedText ?? "", kPageKey: page]
            perform(#selector(handle(metaData:)), with: searchMetaData, afterDelay: delay) // We should not hit API at when user continously typing. We adding this delay to make sure we are not hitting API too frequetly in this case. We need to hit API after `kMinimumTypingInterval`.
        }
    }
    
    /**Search text has been changed we need to cancel previously scheduled actions*/
    func cancelPreviousyScheduledActions() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handle(metaData:)), object: searchMetaData) // Cancel previously scheduleded perform selector
    }
    
    /**Handles search text*/
    @objc func handle(metaData: [String: Any]?) {
        guard let searchText = metaData?[kSearchTextKey] as? String, let page = metaData?[kPageKey] as? Int else { return }
        if !searchText.isEmpty { // Proceed hitting API only if search string is not empty.
            fetchContents(for: searchText.lowercased(), page: page)
        } else { // If search text is empty reset all details and show info label.
            resetDetails()
        }
    }
    
    /**Resets all search details and refresh view*/
    func resetDetails() {
        searchedText = nil
        previouslySearchedText = nil
        SMContentManager.shared.contents = nil
        SMContentManager.shared.currentPage = 0
        SMContentManager.shared.totalResults = nil
        shouldShowPaginationCell = false
        stopLoading()
        reloadTableView()
    }
    
    /**Shows info label with given message*/
    func showInfoLabel(with message: String?) {
        if let message = message {
            infoLabel.text = message
        }
        infoLabel.isHidden = false
        tableView.isHidden = true
    }
    
    /**Hides info label*/
    func hideInfoLabel() {
        infoLabel.isHidden = true
        tableView.isHidden = false
    }
    
    /**Initiates fetching next page content as pagination*/
    func fetchNextPage() {
        if (SMContentManager.shared.contents?.count ?? 0) < Int(SMContentManager.shared.totalResults ?? "0") ?? 0 {
            process(searchText: searchBar.text, isRefresh: true, page: SMContentManager.shared.currentPage + 1)
        }
    }
    
}


// MARK: - Tableview datasource and delegate methods

extension SMDashboardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = SMContentManager.shared.contents?.count ?? 0
        return shouldShowPaginationCell ? count + 1 : count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == (SMContentManager.shared.contents?.count ?? 0) { // Pagination loading cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as? SMLoadingTableViewCell else { return UITableViewCell() }
            cell.activityIndicator.startAnimating()
            return cell
        } else { // Movie / show content cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell") as? SMContentTableViewCell else { return UITableViewCell() }
            if let contents = SMContentManager.shared.contents {
                let content = contents[indexPath.row]
                cell.updateCell(with: content)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == (SMContentManager.shared.contents?.count ?? 0) { // Pagination loading cell height
            return 40
        } else { // Movie/show cell height
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == SMContentManager.shared.contents?.count ?? 0 {
            fetchNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: On selection of movie/shoe, can show complete details in separate screen
    }
    
}


// MARK: - Search bar delegate methods

extension SMDashboardViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        process(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Search will be happend automatically when user starts typing, so when user click search button, just dismiss the keyboard.
    }
    
}
