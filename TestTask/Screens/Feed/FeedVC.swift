//
//  FeedVCViewController.swift
//  TestTask
//
//  Created by MacBook on 10.10.2022.
//

import UIKit
import Moya
import RxDataSources
import RxCocoa
import RxSwift

class FeedVC: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel: FeedVM
    var searchText: String = ""

    private lazy var searchBar: UITextField = {
        let view = UITextField()
        view.placeholder = "Search"
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setLeftPaddingPoints(10)
        return view
    }()

    private lazy var imagesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let size = (view.frame.width - 30) / 2
        layout.itemSize = CGSize(width: size, height: size)
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)

        return view
    }()

    init(viewModel: FeedVM) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addDoneButtonOnKeyboard()
        setupViews()
        bindRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.getImages(text: searchText)
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.models.onNext([])
    }

    private func setupViews() {
        view.addSubview(searchBar)
        view.addSubview(imagesCollection)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 50),

            imagesCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            imagesCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imagesCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imagesCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func bindRx() {
        viewModel
            .models
            .bind(to: imagesCollection.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)) { index, model, cell in
                cell.model.onNext(model)
            }.disposed(by: disposeBag)

        imagesCollection
            .rx
            .didScroll
            .bind {
                // Add images when scrolls to bottom
                let cellHeight = (self.view.frame.width - 30) / 2
                let modelsCount = (try? self.viewModel.models.value().count) ?? Int.max
                let fullHeight = CGFloat(modelsCount) / 2 * (cellHeight + 10) - 10
                let needsOffset = fullHeight - self.imagesCollection.frame.height
                if self.imagesCollection.contentOffset.y > needsOffset + 10 {
                    self.viewModel.getImages(text: self.searchText)
                }
            }
            .disposed(by: disposeBag)

        imagesCollection
            .rx
            .modelSelected(ImageModel.self)
            .subscribe(onNext: { model in
                let vc = ImageVC(model: model)
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        searchBar
            .rx
            .text
            .orEmpty
            .bind(onNext: {
                self.viewModel.models.onNext([])
                self.searchText = $0
            })
            .disposed(by: disposeBag)

        viewModel.hasError.subscribe(onNext: {
            if $0 {
                self.showErrorAlert()
            }
        }).disposed(by: disposeBag)
    }

    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong, try later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        searchBar.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        searchBar.resignFirstResponder()

        viewModel.getImages(text: searchText)
    }
}
