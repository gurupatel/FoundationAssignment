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
    private var imageCache: NSCache<NSString, UIImage> = NSCache()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMediaCoverages()
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

    private func fetchMediaCoverages() {
            URLSession.shared.dataTask(with: apiURL) { data, response, error in
                guard let data = data else {
                    debugPrint("Failed to fetch media coverages:", error ?? "")
                    return
                }
                do {
                    let json = try JSONDecoder().decode([MediaCoverage].self, from: data)
                    self.mediaCoverages = json
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    debugPrint("Error decoding media coverages:", error)
                }
            }.resume()
        }
            
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - CollectionView Delegate / DataSource Methods

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaCoverages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
        let mediaCoverage = mediaCoverages[indexPath.item]
        
//        debugPrint("coverageURL : ", mediaCoverage.coverageURL ?? "" as Any)
                
        // Load image from cache or fetch it asynchronously
        if let cachedImage = imageCache.object(forKey: mediaCoverage.coverageURL as? NSString ?? "") {
            cell.imageView.image = cachedImage
        } else {
            cell.imageView.image = UIImage(named: "placeholder_image") // Placeholder image
            
            loadImage(from: URL(string: mediaCoverage.coverageURL ?? "")!) { [weak self] image in
                guard let self = self, let image = image else { return }
                self.imageCache.setObject(image, forKey: mediaCoverage.coverageURL as? NSString ?? "")
                DispatchQueue.main.async {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 3 // 3 columns with 10 spacing
        return CGSize(width: width, height: width)
    }
}

// MARK: - CollectionViewCell

class ImageCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.addRoundCorners(radius: 10, borderWidth: 2, color: .lightGray)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImageView {
    func addRoundCorners(radius: CGFloat, borderWidth: CGFloat = 0, color: UIColor = .clear) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderWidth = borderWidth
        layer.borderColor = color.cgColor
    }
}
