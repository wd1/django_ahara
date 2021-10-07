import UIKit
import SwiftyJSON

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSendCode: UIButton!
    @IBOutlet weak var vwEmail: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwEmail.layer.cornerRadius = 25.0
        vwEmail.layer.borderWidth = 1
        vwEmail.layer.borderColor = UIColor(rgb: 0xEBEBEB).cgColor
     
        btnSendCode.layer.cornerRadius = 25.0
        txtEmail.addDoneButtonOnKeyboard()
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBackToLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSendCode(_ sender: Any) {
        self.showSpinner()
        if txtEmail.text == ""
        {
            let inputAlert = UIAlertController(title: "Ahara", message: "Phone number is required.", preferredStyle: UIAlertController.Style.alert)
            inputAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))

            present(inputAlert, animated: true, completion: nil)
            
            self.removeSpinner()
            return
        }
        reset_password(phone_number: txtEmail.text!, completionHandler: { response in
            let statusCode = response.response?.statusCode
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.removeSpinner()
                    print(json)
                    if statusCode == 404 {
                        let paramAlert = UIAlertController(title: "Ahara", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        }))
                        self.present(paramAlert, animated: true, completion: nil)
                    }
                    else {
                        reset_password_number = self.txtEmail.text!
                        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerificationCodeViewController") as? VerificationCodeViewController
                        else{
                            return
                        }
                        dst_vc.modalPresentationStyle = .fullScreen
                        self.present(dst_vc, animated: true, completion: nil)
                        return
                    }
                case .failure(let error):
                    self.removeSpinner()
                    let paramAlert = UIAlertController(title: "Internet Error", message: "Please check internet connection.", preferredStyle: UIAlertController.Style.alert)
                    paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    print(error)
                    self.present(paramAlert, animated: true, completion: nil)
                    return
            }
        })
    }
    
}
