//
//  MemberInviteView.swift
//  TUIRoomKit
//
//  Created by krabyu on 2023/8/21.
//

import Foundation

class MemberInviteView: UIView {
    let viewModel: MemberInviteViewModel
    private var isViewReady: Bool = false
    var viewArray: [UIView] = []
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.textColor = UIColor(0xD5E0F2)
        label.font = UIFont(name: "PingFangSC-Regular", size: 18)
        label.textAlignment = .left
        return label
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 3
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let copyButton: UIButton = {
        let button = UIButton()
        button.setTitle(.copyRoomInformation, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor(0x4F586B).withAlphaComponent(0.3)
        button.layer.cornerRadius = 6
        return button
    }()
    
    init(viewModel: MemberInviteViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 12
    }
    
    func constructViewHierarchy() {
        addSubview(stackView)
        addSubview(headView)
        headView.addSubview(titleLabel)
        addSubview(copyButton)
    }
    
    func activateConstraints() {
        headView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(25.scale375())
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(25.scale375())
            make.width.equalTo(182.scale375())
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom).offset(20.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
        }
        copyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(40.scale375Height())
            make.top.equalTo(stackView.snp.bottom).offset(20.scale375Height())
        }
        
        for item in viewModel.messageItems {
            let view = ListCellItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(24.scale375Height())
                make.width.equalToSuperview()
            }
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        viewModel.viewResponder = self
        copyButton.addTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
    }
    
    @objc func copyAction(sender: UIButton) {
        viewModel.copyAction()
        makeToast(.roomInformationCopiedSuccessfully)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension MemberInviteView: MemberInviteResponder {
    func showCopyToast(copyType: CopyType?) {
        guard let copyType = copyType else { return }
        var test: String
        switch copyType {
        case .copyRoomPassword:
            test = .copyRoomPasswordSuccess
        case .copyRoomIdType:
            test = .copyRoomIdSuccess
        case .copyRoomLinkType:
            test = .copyRoomLinkSuccess
        }
        RoomRouter.makeToastInCenter(toast: test,duration: 0.5)
    }
}

private extension String {
    static var copyRoomIdSuccess: String {
        localized("Conference ID copied.")
    }
    static var copyRoomLinkSuccess: String {
        localized("Conference Link copied.")
    }
    static let conferencePasswordSuccess = localized("Conference password copied successfully.")
    static let copyRoomInformation = localized("Copy room information")
    static let roomInformationCopiedSuccessfully = localized("Room information copied successfully")
    static let copyRoomPasswordSuccess = localized("Conference password copied")
}
