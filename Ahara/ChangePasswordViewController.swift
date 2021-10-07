import UIKit
import SwiftyJSON

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var vwNewPassword: UIView!
    @IBOutlet weak var vwConfirmPassword: UIView!
    @IBOutlet weak var btnNewShowHide: UIButton!
    @IBOutlet weak var txtNewPass: UITextField!
    @IBOutlet weak var btnConfirmShowHide: UIButton!
    @IBOutlet weak var txtConfirmPass: UITextField!
    
    var bNewShow = false
    var bConfirmShow = false
    
    var uid : String = ""
    var token : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwNewPassword.layer.cornerRadius = 25.0
        vwNewPassword.layer.borderWidth = 1
        vwNewPassword.layer.borderColor = UIColor(rgb: 0xEBEBEB).cgColor
        
        vwConfirmPassword.layer.cornerRadius = 25.0
        vwConfirmPassword.layer.borderWidth = 1
        vwConfirmPassword.layer.borderColor = UIColor(rgb: 0xEBEBEB).cgColor
     
        btnChange.layer.cornerRadius = 25.0
        txtNewPass.addDoneButtonOnKeyboard()
        txtConfirmPass.addDoneButtonOnKeyboard()
    }
    
    @IBAction func onBackToLogin(_ sender: Any) {
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        else{
            return
        }
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
        return
    }
    
    @IBAction func onChange(_ sender: Any) {
        self.showSpinner()
        if txtNewPass.text == "" || txtConfirmPass.text == ""
        {
            let inputAlert = UIAlertController(title: "Input Error", message: "You should input all fields.", preferredStyle: UIAlertController.Style.alert)
            inputAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))

            present(inputAlert, animated: true, completion: nil)
            
            self.removeSpinner()
            return
        }
        if txtNewPass.text != txtConfirmPass.text
        {
            let inputAlert = UIAlertController(title: "Input Error", message: "Two passwords are not match", preferredStyle: UIAlertController.Style.alert)
            inputAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))

            present(inputAlert, animated: true, completion: nil)
            
            self.removeSpinner()
            return
        }
        let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9]).{8,}$")
        if password.evaluate(with: txtNewPass.text) == false{
            let paramAlert = UIAlertController(title: "Ahara", message: "Must contain letters and numbers", preferredStyle: UIAlertController.Style.alert)
            paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            self.present(paramAlert, animated: true, completion: nil)
            self.removeSpinner()
            return
        }
        
        reset_password_confirm(uid: self.uid, token: self.token, new_password: txtNewPass.text!, re_new_password: txtConfirmPass.text!, completionHandler: { response in
            let statusCode = response.response?.statusCode
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    self.removeSpinner()
                    if statusCode == 400 {
                        var err_msg: String = ""
                        if json["new_password"].exists()
                        {
                            err_msg = json["new_password"][0].stringValue
                        }
                        let paramAlert = UIAlertController(title: "Ahara", message: err_msg, preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        }))
                        self.present(paramAlert, animated: true, completion: nil)
                    }
                    else {
                        let paramAlert = UIAlertController(title: "Ahara", message: "Password changed successfully. Please login again.", preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                            else{
                                return
                            }
                            dst_vc.modalPresentationStyle = .fullScreen
                            self.present(dst_vc, animated: true, completion: nil)
                            return
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
    
    @IBAction func onBtnNewShow(_ sender: Any) {
        if (bNewShow == false)
        {
            self.txtNewPass.isSecureTextEntry = false
            self.btnNewShowHide.setImage(UIImage(named: "passShow"), for: .normal)
        }else{
            self.txtNewPass.isSecureTextEntry = true
            self.btnNewShowHide.setImage(UIImage(named: "passHide"), for: .normal)
        }
        bNewShow = !bNewShow
    }
    
    @IBAction func onBtnConfirmShow(_ sender: Any) {
        if (bConfirmShow == false)
        {
            self.txtConfirmPass.isSecureTextEntry = false
            self.btnConfirmShowHide.setImage(UIImage(named: "passShow"), for: .normal)
        }else{
            self.txtConfirmPass.isSecureTextEntry = true
            self.btnConfirmShowHide.setImage(UIImage(named: "passHide"), for: .normal)
        }
        bConfirmShow = !bConfirmShow
    }
    
}
