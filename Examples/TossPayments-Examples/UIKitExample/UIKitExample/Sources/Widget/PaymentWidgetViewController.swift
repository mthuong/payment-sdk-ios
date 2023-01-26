//
//  File.swift
//  
//
//  Created by 김진규 on 2022/12/06.
//

#if canImport(UIKit)

import UIKit
import WebKit
import TossPayments

public final class PaymentWidgetViewController: ViewController {
    enum Constant {
        static let defaultAmount: Double = 1000
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    var isWebLoaded: Bool = false
    
    private lazy var amountInputField = TextField()
    private lazy var orderIdInputField = TextField()
    private lazy var orderNameInputField = TextField()
    
    private lazy var widget: PaymentWidget = PaymentWidget(clientKey: Environment.clientKey)
    private lazy var 빈화면 = UIView()
    
    private lazy var button = UIButton()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "위젯"
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        scrollViewBottomAnchorConstraint?.isActive = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        ])
        button.backgroundColor = .systemBlue
        button.setTitle("결제하기", for: .normal)
        button.addTarget(self, action: #selector(requestPayments), for: .touchUpInside)
        
        stackView.addArrangedSubview(amountInputField)
        stackView.addArrangedSubview(orderIdInputField)
        stackView.addArrangedSubview(orderNameInputField)
        stackView.addArrangedSubview(widget)
        stackView.addArrangedSubview(빈화면)
        
        amountInputField.title = "amount (원)"
        amountInputField.text = "\(Constant.defaultAmount)"
        orderIdInputField.title = "orderId"
        orderIdInputField.text = UUID().uuidString
        orderNameInputField.title = "orderName"
        orderNameInputField.text = "토스페이먼츠 세트"
        
        amountInputField.textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        amountInputField.textField.keyboardType = .numberPad
        
        widget.amount = Constant.defaultAmount
        widget.delegate = self
        widget.widgetUIDelegate = self
        
        NSLayoutConstraint.activate([
            빈화면.heightAnchor.constraint(equalToConstant: 200)
        ])
        빈화면.backgroundColor = .lightGray
    }
    
    @objc func requestPayments() {
        widget.requestPayments(
            info: DefaultPaymentInfo(
                amount: widget.amount,
                orderId: orderIdInputField.textField.text ?? UUID().uuidString,
                orderName: orderNameInputField.textField.text ?? "테스트 결제"
            ),
            on: self
        )
    }
}

extension PaymentWidgetViewController {
    @objc func textFieldDidChanged(_ sender: Any) {
        if let amountString = (sender as? UITextField)?.text,
           let amount = Double(amountString) {
            widget.amount = amount
        }
    }
}

extension PaymentWidgetViewController: TossPaymentsDelegate {
    public func handlePaymentSuccessResult(_ success: TossPaymentsResult.Success) {
        let viewModel = ResultViewModel(
            result1: ("paymentKey", success.paymentKey),
            result2: ("orderId", success.orderId),
            result3: ("amount", "\(success.amount)")
        )
        let viewController = ResultViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public func handlePaymentFailResult(_ fail: TossPaymentsResult.Fail) {
        let viewModel = ResultViewModel(
            result1: ("errorCode", fail.errorCode),
            result2: ("errorMessage", fail.errorMessage),
            result3: ("orderId", fail.orderId)
        )
        let viewController = ResultViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PaymentWidgetViewController: TossPaymentsWidgetUIDelegate {
    public func didUpdateHeight(_ widget: PaymentWidget, height: CGFloat) {
        print("didUpdateHeight \(height)")
    }
    
    
}

#endif
