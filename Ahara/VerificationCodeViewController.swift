
import UIKit
import PinCodeTextField
import SwiftyJSON

class VerificationCodeViewController: UIViewController {

    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var pcText: PinCodeTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwEmail.layer.cornerRadius = 25.0
        vwEmail.layer.borderWidth = 1
        vwEmail.layer.borderColor = UIColor(rgb: 0xEBEBEB).cgColor
     
        btnVerify.layer.cornerRadius = 25.0
        
        pcText.becomeFirstResponder()
        pcText.keyboardType = .numberPad
    }
    
    @IBAction func onBackToLogin(_ sender: Any) {
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        else{
            return
        }
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
    }
    
    @IBAction func onVerify(_ sender: Any) {
        if pcText.text == nil || pcText.text!.count < 6 {
            let inputAlert = UIAlertController(title: "Input Error", message: "You should input code correctly.", preferredStyle: UIAlertController.Style.alert)
            inputAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))

            present(inputAlert, animated: true, completion: nil)
            return
        }
        self.showSpinner()
        reset_password_verify(phone_number: reset_password_number, otp:pcText.text!, completionHandler: { response in
            let statusCode = response.response?.statusCode
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //print(json)
                    self.removeSpinner()
                    if statusCode == 400 {
                        let paramAlert = UIAlertController(title: "Authentication Error", message: "Invalid Code", preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        }))
                        self.present(paramAlert, animated: true, completion: nil)
                    }
                    else {
                        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController
                        else{
                            return
                        }
                        dst_vc.token = json["token"].stringValue
                        dst_vc.uid = json["uid"].stringValue
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
    
    @IBAction func onResend(_ sender: Any) {
        self.showSpinner()
        reset_password(phone_number: reset_password_number, completionHandler: { response in
            let statusCode = response.response?.statusCode
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.removeSpinner()
                    if statusCode == 404 {
                        let paramAlert = UIAlertController(title: "Ahara", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        }))
                        self.present(paramAlert, animated: true, completion: nil)
                    }else{
                        let paramAlert = UIAlertController(title: "Ahara", message: "Code resent successfully", preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        }))
                        self.present(paramAlert, animated: true, completion: nil)
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
