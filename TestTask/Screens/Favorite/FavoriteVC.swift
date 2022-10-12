//
//  FavoriteVC.swift
//  TestTask
//
//  Created by MacBook on 10.10.2022.
//

import UIKit
import RxSwift

class FavoriteVC: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: FavoriteVM

    private lazy var imagesCollcetion: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let size = (view.frame.width - 30) / 2
        layout.itemSize = CGSize(width: size, height: size)
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        return view
    }()

    init(viewModel: FavoriteVM) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindRx()
    }

    override func viewDidAppear(_ animated: Bool) {
        viewModel.getImages()
    }

    private func setupViews() {
        view.addSubview(imagesCollcetion)

        NSLayoutConstraint.activate([
            imagesCollcetion.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imagesCollcetion.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            imagesCollcetion.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            imagesCollcetion.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func bindRx() {
        viewModel
            .models
            .bind(to: imagesCollcetion.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)) { index, model, cell in
                cell.model.onNext(model)
            }.disposed(by: disposeBag)

        imagesCollcetion
            .rx
            .modelSelected(ImageModel.self)
            .subscribe(onNext: { model in
                let vc = ImageVC(model: model)
                vc.isLiked.bind { value in
                    if value {
                        guard var models = try? self.viewModel.models.value() else { return }

                        models.append(model)
                        self.viewModel.models.onNext(models)
                    } else {
                        guard var models = try? self.viewModel.models.value() else { return }

                        let index = models.firstIndex(of: model)
                        guard let index = index else { return }

                        models.remove(at: index)
                        self.viewModel.models.onNext(models)
                    }
                }
                .disposed(by: self.disposeBag)
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
