import UIKit
import SwiftyJSON
import FBSDKShareKit

class ShareViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    var recp:JSON = []
    @IBOutlet weak var imgRecipe: UIImageView!
    @IBOutlet weak var vwRotate: UIView!
    @IBOutlet weak var vwContainer: UIView!
    
    var documentController: UIDocumentInteractionController!
    
    var shareImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwRotate.rotate(angle: 11)
        vwContainer.layer.cornerRadius = 12.0
        imgRecipe.sd_setImage(with: URL(string: recp["image"].stringValue))
        vwContainer.clipsToBounds = true
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func onFacebook(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: vwContainer.bounds.size)
        self.shareImage = renderer.image { ctx in vwContainer.drawHierarchy(in: vwContainer.bounds, afterScreenUpdates: true)}
                
        let shareImage = SharePhoto()
        shareImage.image = self.shareImage
        shareImage.isUserGenerated = true
        
        let content = SharePhotoContent()
        content.photos = [shareImage]
        
        let shareDialoge = ShareDialog()
        shareDialoge.shareContent = content
        
        shareDialoge.fromViewController = self
        shareDialoge.mode = .automatic
        
        if (shareDialoge.canShow) {
            shareDialoge.show()
        } else {
            let alertController = UIAlertController(title: "Error", message: "Facebook app is not installed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onInstagram(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: vwContainer.bounds.size)
        self.shareImage = renderer.image { ctx in vwContainer.drawHierarchy(in: vwContainer.bounds, afterScreenUpdates: true)}
        
        let imageShare = [self.shareImage!]
        let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .mail, .markupAsPDF, .message, .openInIBooks, .postToFlickr, .postToTencentWeibo, .postToWeibo, .print, .saveToCameraRoll, .postToVimeo]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        /*
        DispatchQueue.main.async {
            //Share To Instagram:
            let instagramURL = URL(string: "instagram://app")
            if UIApplication.shared.canOpenURL(instagramURL!) {

                let imageData = self.shareImage!.jpegData(compressionQuality: 100)
                let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("My Recipe.igo")

                do {
                    try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
                } catch {
                    print(error)
                }

                let fileURL = URL(fileURLWithPath: writePath)
                self.documentController = UIDocumentInteractionController(url: fileURL)
                self.documentController.delegate = self
                //self.documentController.uti = "com.instagram.exlusivegram"

                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.documentController.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
                } else {
                    //self.documentController.presentOpenInMenu(from: self.IGBarButton, animated: true)
                }
            } else {
                print(" Instagram is not installed ")
            }
        }*/
    }
    @IBAction func OnTwitter(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: vwContainer.bounds.size)
        self.shareImage = renderer.image { ctx in vwContainer.drawHierarchy(in: vwContainer.bounds, afterScreenUpdates: true)}
        
        let imageShare = [ self.shareImage! ]
        let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .mail, .markupAsPDF, .message, .openInIBooks, .postToFlickr, .postToTencentWeibo, .postToWeibo, .print, .saveToCameraRoll, .postToVimeo]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}
