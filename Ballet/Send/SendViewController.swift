//
//  SendViewController.swift
//  Ballet
//
//  Created by Ben Koksa on 12/20/17.
//  Copyright © 2017 Boilertalk. All rights reserved.
//

import UIKit
import Material
import DropDown
import BlockiesSwift

class SendViewController: UIViewController {

    // MARK: - Properties

    // var accountBtn = accountDropDownBtn()

    @IBOutlet weak var amountField: TextField!
    @IBOutlet weak var fromAccount: UIView!

    @IBOutlet weak var RecipientTextField: TextField!
    let dropDown = DropDown()
    let amountDropDown = DropDown()

    var selectedAccount: Account = Values.defaultAccount

    @IBOutlet weak var fromLabel: UILabel!
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UI Setup

    private func setupUI() {

        RecipientTextField.tag = 1
        RecipientTextField.delegate = self

        fromLabel.text = Values.defaultAccount.asTxtMsg()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dropDownPressed))
        fromAccount.addGestureRecognizer(recognizer)
        
        setupToolbar()

        setupDropDowns()

        amountField.keyboardType = UIKeyboardType.decimalPad
        amountField.tag = 2
        amountField.delegate = self

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = [String]()

        for account in Values.accounts {
            dropDown.dataSource.append(account.asTxtMsg())
        }

    }

    private func setupDropDowns() {
        dropDown.anchorView = fromAccount
        dropDown.dataSource = []

        for account in Values.accounts {
            dropDown.dataSource.append(account.asTxtMsg())
        }

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedAccount = Values.accounts[index]
            self.fromLabel.text = item
            self.dropDown.hide()
        }

        dropDown.width = fromAccount.frame.size.width
        
        let label = UILabel()
        label.text = "ETH"
        
        let amountRecognizer = UITapGestureRecognizer(target: self, action: #selector(amountDropDownPressed))
        label.addGestureRecognizer(amountRecognizer)
        
        amountDropDown.anchorView = label
        amountDropDown.dataSource = ["ETH", "BTH", "BCH", "EOS"]
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let label = UILabel()
            label.text = item
            
            let amountRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.amountDropDownPressed))
            label.addGestureRecognizer(amountRecognizer)
            self.amountField.leftView = label
            
            self.dropDown.hide()
        }

        
        amountField.leftView = label

    }

    private func setupToolbar() {
        navigationItem.titleLabel.text = "Send"
        navigationItem.titleLabel.textColor = Colors.lightPrimaryTextColor

        let qrImage = UIImage(named: "ic_qrcode")?.withRenderingMode(.alwaysTemplate)
        let qr = IconButton(image: qrImage, tintColor: Colors.lightPrimaryTextColor)

        qr.addTarget(self, action: #selector(scanQR), for: .touchUpInside)

        navigationItem.rightViews = [qr]
    }

    @objc private func scanQR() {
        let module = QRModule { (data) in
            print("Address: \(data.address)")
            print("Amount: \(data.amount)")
            print("Gas: \(data.gas)")
        }
        module.present(on: self)
    }

    @objc private func dropDownPressed() {
        dropDown.show()
    }
    
    @objc private func amountDropDownPressed() {
        amountDropDown.show()
    }
}

//MARK: - Text Field Delegate

extension SendViewController: TextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        
        let isBackSpace = strcmp(char, "\\b")

        if isBackSpace == -46 || isBackSpace == -92 {
            self.amountField.keyboardType = UIKeyboardType.decimalPad
            self.amountField.reloadInputViews()
        }
        
        return true
    }
    
    func textField(textField: TextField, didChange text: String?) {
        if textField.tag == 1 { // Recipient Text Field
            if let txt = text {
                if txt.count == 42 {
                    let blockie = Blockies(seed: txt, size: (Int(textField.frame.height/3)), scale: 3)
                    if let img = blockie.createImage() {
                        let imageView = UIImageView(image: img)

                        imageView.frame = CGRect(x: 0, y: 0, width: textField.frame.height, height: textField.frame.height)
                        textField.leftView = imageView
                    }
                } else {
                    let img = UIImage(named: "ic_error_outline")?.withRenderingMode(.alwaysTemplate)
                    if let img = img {
                        if let img = img.tint(with: UIColor.red) {
                            let imageView = UIImageView(image: img)
                            imageView.frame = CGRect(x: 0, y: 0, width: textField.frame.height, height: textField.frame.height)
                            textField.leftView = imageView
                        }
                    }
                }
            }
        } else if textField.tag == 2 { // Amount Text Field
            if let txt = text {
                if txt.last == "." {
                    self.amountField.keyboardType = UIKeyboardType.numberPad
                    self.amountField.reloadInputViews()
                }
            }
        }
    }
}
