//
//  ViewController.swift
//  FoundationAssignment
//
//  Created by Gaurang Patel on 14/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
            
    private let reuseIdentifier = "ImageCell"
    private let apiURL = URL(string: "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100")!
    private var mediaCoverages: [MediaCoverage] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMediaCoverages()
    }
    
    private func fetchMediaCoverages() {
            URLSession.shared.dataTask(with: apiURL) { data, response, error in
                guard let data = data else {
                    debugPrint("Failed to fetch media coverages:", error ?? "")
                    return
                }
                do {

                } catch {
                    debugPrint("Error decoding media coverages:", error)
                }
            }.resume()
        }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.contentView.backgroundColor = .systemPink
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 3 // 3 columns with 10 spacing
        return CGSize(width: width, height: width)
    }
}
