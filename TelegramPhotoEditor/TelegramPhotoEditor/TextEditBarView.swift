//
//  TextEditBar.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 17.10.2022.
//

import UIKit

protocol TextEditBarViewDelegate: AnyObject {
    
    func didSelectAlignment(_ view: TextEditBarView, alignment: NSTextAlignment)
    
    func didSelectFilling(_ view: TextEditBarView, filling: TextFilling)
    
    func didSelectFont(_ view: TextEditBarView, font: Font, index: Int)
    
}

class TextEditBarView: UIInputView {
    
    weak var delegate: TextEditBarViewDelegate?

    let fillButton = UIButton()
    
    let alignmentButton = UIButton()
    
    var fonts: [Font] = [
        .init(font: UIFont.init(name: "SFProDisplay-Bold", size: 14)!,
              name: "San Francisco"),
        .init(font: UIFont.init(name: "NewYorkExtraLarge-Bold", size: 14)!,
              name: "New York"),
        .init(font: UIFont.init(name: "RobotoMono-Bold", size: 14)!,
              name: "Monospace"),
    ]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        return collectionView
    }()
    
    let collectionContainerView = UIView()
    
    var alignment: NSTextAlignment = .center {
        didSet {
            setAlignmentButtonImage()
        }
    }
    
    var filling: TextFilling = .normal {
        didSet {
            setFillingButtonImage()
        }
    }
    
    var currentFontIndex: Int = 0
    
    override init(frame: CGRect = .zero, inputViewStyle: UIInputView.Style = .keyboard) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        fillButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fillButton)
        fillButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        fillButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        fillButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        fillButton.widthAnchor
            .constraint(equalTo: fillButton.heightAnchor).isActive = true
        fillButton.addTarget(self, action: #selector(fillingButtonTapped),
                             for: .touchUpInside)
        
        alignmentButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(alignmentButton)
        alignmentButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        alignmentButton.leftAnchor.constraint(equalTo: fillButton.rightAnchor,
                                              constant: 10).isActive = true
        alignmentButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        alignmentButton.widthAnchor
            .constraint(equalTo: alignmentButton.heightAnchor).isActive = true
        alignmentButton.addTarget(self, action: #selector(alignmentButtonTapped),
                                  for: .touchUpInside)
        
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionContainerView)
        collectionContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionContainerView.leftAnchor.constraint(equalTo: alignmentButton.rightAnchor,
                                             constant: 5).isActive = true
        collectionContainerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionContainerView.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: collectionContainerView.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: collectionContainerView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: collectionContainerView.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionContainerView.bottomAnchor).isActive = true
        collectionView.backgroundColor = .clear

        collectionView.register(FontCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset.left = 10
        collectionView.contentInset.right = 10
        setFillingButtonImage()
        setAlignmentButtonImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let collectionFrame = CGRect(origin: .zero,
                                     size: collectionContainerView.frame.size)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.black.cgColor,
                                UIColor.black.cgColor,
                                UIColor.clear.cgColor]
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint = .init(x: 1, y: 0)
        gradientLayer.locations = [
            .init(floatLiteral: 0),
            .init(floatLiteral: 15 / collectionContainerView.frame.width),
            .init(floatLiteral: (collectionContainerView.frame.width - 15) / collectionContainerView.frame.width),
            .init(floatLiteral: 1)
        ]
        gradientLayer.frame = collectionFrame
        collectionContainerView.layer.mask = gradientLayer
    }
    
    func setFillingButtonImage() {
        fillButton.setImage(filling.buttonImage, for: .normal)
    }
    
    func setAlignmentButtonImage() {
        var image: UIImage?
        switch alignment {
        case .center:
            image = UIImage(named: "textCenter")
        case .left:
            image = UIImage(named: "textLeft")
        case .right:
            image = UIImage(named: "textRight")
        default:
            break
        }
        alignmentButton.setImage(image, for: .normal)
    }
    
    func addBlurBackground() {
        backgroundColor = .clear
    }
    
    @objc
    func fillingButtonTapped() {
        switch filling {
        case .normal:
            self.filling = .filled
        case .stroke:
            self.filling = .normal
        case .filled:
            self.filling = .semi
        case .semi:
            self.filling = .stroke
        }
        delegate?.didSelectFilling(self, filling: filling)
    }
    
    @objc
    func alignmentButtonTapped() {
        switch alignment {
        case .left:
            self.alignment = .right
        case .center:
            self.alignment = .left
        case .right:
            self.alignment = .center
        default:
            break
        }
        delegate?.didSelectAlignment(self, alignment: alignment)
    }
    
}

extension TextEditBarView: UICollectionViewDelegate,
                        UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count * 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                      for: indexPath) as! FontCell
        cell.setup(fonts[indexPath.item % fonts.count])
        cell.isCurrent = currentFontIndex == indexPath.item % fonts.count
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = fonts[indexPath.item % fonts.count].font
        let name = fonts[indexPath.item % fonts.count].name
        if let font = font {
            return .init(width: name.width(withConstrainedHeight: 30, font: font) + 14,
                         height: 30)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? FontCell {
            let font = fonts[currentFontIndex]
            cell.isCurrent = cell.font?.name == font.name
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        setCurrentFont(indexPath.item % fonts.count, scrolls: false)
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally, animated: true)
        delegate?.didSelectFont(self, font: fonts[currentFontIndex],
                                index: currentFontIndex)
    }
    
    func setCurrentFont(_ newValue: Int, scrolls: Bool) {
        let oldFont = fonts[currentFontIndex]
        let newFont = fonts[newValue]
        guard oldFont.name != newFont.name else { return }
        if let visibleCells = collectionView.visibleCells as? [FontCell] {
            for cell in visibleCells {
                if cell.font?.name == oldFont.name {
                    cell.isCurrent = false
                }
            }
        }
        
        currentFontIndex = newValue
        
        if let visibleCells = collectionView.visibleCells as? [FontCell] {
            for cell in visibleCells {
                if cell.font?.name == newFont.name {
                    cell.isCurrent = true
                }
            }
            
            
            if scrolls {
                if let cell = visibleCells.first(where: { value in
                    return value.isCurrent == true
                }), let indexPath = collectionView.indexPath(for: cell) {
                    collectionView.scrollToItem(at: indexPath,
                                                at: .centeredHorizontally, animated: true)
                }
            }
            
        }
    }
}

class FontCell: UICollectionViewCell {
    
    let label = UILabel()

    var font: Font?
    
    var isCurrent: Bool = false {
        didSet {
            guard isCurrent != oldValue else { return }
            UIView.animate(withDuration: 0.3) {
                self.layer.borderColor = self.isCurrent ? UIColor.white.cgColor : UIColor.systemGray.cgColor
                self.layer.borderWidth = self.isCurrent ? 1 : 0.5
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.textAlignment = .center
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ font: Font) {
        self.font = font
        self.label.text = font.name
        self.label.font = font.font?.withSize(14)
    }
}
