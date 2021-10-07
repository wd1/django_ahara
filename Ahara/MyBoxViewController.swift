
import UIKit
import SideMenu
import ASPVideoPlayer
import SwiftyJSON
import SDWebImage

class MyBoxViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    @IBOutlet weak var videoPlayerBackgroundView: UIView!
    @IBOutlet weak var vwPlayer: ASPVideoPlayer!
    @IBOutlet weak var vwRecipesCollection: UICollectionView!
    @IBOutlet weak var vwPlay: blurView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var recipesArray:[JSON] = []
    var previousConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vwRecipesCollection.delegate = self
        vwRecipesCollection.dataSource = self
        
        vwPlayer.delegate = self
        vwPlayer.configuration = ASPVideoPlayer.Configuration(videoGravity: .aspectFill, startPlayingWhenReady: false, controlsInitiallyHidden: false)
        vwPlayer.resizeClosure = { [unowned self] isExpanded in
            self.rotate(isExpanded: isExpanded)
        }
        containerView.layer.cornerRadius = 12.0
        vwPlayer.layer.cornerRadius = 12.0
        vwPlayer.layer.masksToBounds = true
        videoPlayerBackgroundView.layer.cornerRadius = 12.0
        self.getUnboxing()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onNewBox(_:)))
        imgLogo.addGestureRecognizer(tap)
        imgLogo.isUserInteractionEnabled = true
    }
    
    @objc func onNewBox(_ sender: UITapGestureRecognizer? = nil)
    {
        vwPlayer.videoPlayerControls.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.getUnboxing()
    }
    
    func getRecipes()
    {
        self.showSpinner()
        getAllRecipes(completionHandler: { response in
            switch response.result {
                case .success(let value):
                    //print(value)
                    self.removeSpinner()
                    let arr = JSON(value).arrayValue
                    for item in arr{
                        if item["is_this_week"].intValue == 1{
                            self.recipesArray.append(item)
                        }
                    }
                    self.vwRecipesCollection.reloadData()
                    if user.isEmpty == true{
                        self.readMe()
                    }
                    return
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
    
    func readMe(){
        self.showSpinner()
        UserReadMe(completionHandler: { response in
            switch response.result {
                case .success(let value):
                    //print(value)
                    user = JSON(value)
                    print(user)
                    self.removeSpinner()                    
                    return
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
    
    func getUnboxing(){
        self.showSpinner()
        getUnbox(completionHandler: { response in
            switch response.result {
                case .success(let value):
                    self.removeSpinner()
                    self.getRecipes()
                    let items = JSON(value).arrayValue
                    for item in items{
                        //print(item)
                        if item["is_current"].boolValue == true{
                            //print(item["video"].stringValue)
                            self.vwPlayer.videoURLs.append(URL(string: item["video"].stringValue)!)
                            return
                        }
                    }
                    return
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
    
    func rotate(isExpanded: Bool) {
        let views: [String:Any] = ["videoPlayer": vwPlayer as Any,
                                           "backgroundView": videoPlayerBackgroundView as Any]

                var constraints: [NSLayoutConstraint] = []

                if isExpanded == false {
                    self.containerView.removeConstraints(self.vwPlayer.constraints)

                    self.view.addSubview(self.videoPlayerBackgroundView)
                    self.view.addSubview(self.vwPlayer)
                    self.vwPlayer.frame = self.containerView.frame
                    self.videoPlayerBackgroundView.frame = self.containerView.frame

                    let padding = (self.view.bounds.height - self.view.bounds.width) / 2.0

                    var bottomPadding: CGFloat = 0

                    if #available(iOS 11.0, *) {
                        if self.view.safeAreaInsets != .zero {
                            bottomPadding = self.view.safeAreaInsets.bottom
                        }
                    }

                    let metrics: [String:Any] = ["padding":padding,
                                                 "negativePaddingAdjusted":-(padding - bottomPadding),
                                                 "negativePadding":-padding]

                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "H:|-(negativePaddingAdjusted)-[videoPlayer]-(negativePaddingAdjusted)-|",
                                                       options: [],
                                                       metrics: metrics,
                                                       views: views))
                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "V:|-(padding)-[videoPlayer]-(padding)-|",
                                                       options: [],
                                                       metrics: metrics,
                                                       views: views))

                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "H:|-(negativePadding)-[backgroundView]-(negativePadding)-|",
                                                       options: [],
                                                       metrics: metrics,
                                                       views: views))
                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "V:|-(padding)-[backgroundView]-(padding)-|",
                                                       options: [],
                                                       metrics: metrics,
                                                       views: views))

                    self.view.addConstraints(constraints)
                } else {
                    self.view.removeConstraints(self.previousConstraints)

                    let targetVideoPlayerFrame = self.view.convert(self.vwPlayer.frame, to: self.containerView)
                    let targetVideoPlayerBackgroundViewFrame = self.view.convert(self.videoPlayerBackgroundView.frame, to: self.containerView)

                    self.containerView.addSubview(self.videoPlayerBackgroundView)
                    self.containerView.addSubview(self.vwPlayer)

                    self.vwPlayer.frame = targetVideoPlayerFrame
                    self.videoPlayerBackgroundView.frame = targetVideoPlayerBackgroundViewFrame

                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayer]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: views))
                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayer]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: views))

                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: views))
                    constraints.append(contentsOf:
                        NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: views))

                    self.containerView.addConstraints(constraints)
                }

                self.previousConstraints = constraints
                
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
                    self.vwPlayer.transform = isExpanded == true ? .identity : CGAffineTransform(rotationAngle: .pi / 2.0)
                    self.videoPlayerBackgroundView.transform = isExpanded == true ? .identity : CGAffineTransform(rotationAngle: .pi / 2.0)

                    self.view.layoutIfNeeded()
                })
    }
    
    @IBAction func onSideMenu(_ sender: Any) {
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RightMenuController") as? RightMenuController
        else{
            return
        }
        let menu = SideMenuNavigationController(rootViewController: dst_vc)
        menu.isNavigationBarHidden = true
        menu.menuWidth = 250
        menu.presentationStyle = .menuSlideIn
        menu.leftSide = true
        dst_vc.isMybox = true
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func btnViewAllRecipes(_ sender: Any) {
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReadyToCookViewController") as? ReadyToCookViewController
        else{
            return
        }
        dst_vc.from = "mybox"
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipesArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receipeCell", for: indexPath) as! ReceipeCell
        let recipeInfo = recipesArray[indexPath.row]
        cell.lblRecipeName.text = recipeInfo["name"].stringValue
        cell.lblTime.text = String(recipeInfo["cooking_time"].intValue) + " min"
        //cell.lblMarkCount.text = String(recipeInfo["likes"].arrayValue.count)
        cell.imgLiked.image = recipeInfo["is_liked"].boolValue ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        let cheif = recipeInfo["chef"].dictionaryValue
        cell.lblCheifName.text = (cheif["first_name"]?.stringValue)! + " " + (cheif["last_name"]?.stringValue)!
        cell.imgReceipe.sd_setImage(with: URL(string: recipeInfo["image"].stringValue))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recp = self.recipesArray[indexPath.row]
        let chef = recp["chef"].dictionaryValue
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LetsCookViewController") as? LetsCookViewController
        else{
            return
        }
        dst_vc.b_index = 0
        dst_vc.recp = recp
        dst_vc.t_cook = String(recp["cooking_time"].stringValue) + " min"
        dst_vc.t_prep = String(recp["prep_time"].stringValue) + " min"
        dst_vc.serve = recp["serving"].stringValue
        dst_vc.desc = recp["description"].stringValue
        dst_vc.recpName = recp["name"].stringValue
        dst_vc.cheifName = "by " +   (chef["first_name"]?.stringValue)! + (chef["last_name"]?.stringValue)!
        let videos = recp["videos"].arrayValue
        let video = videos[0]
        dst_vc.videoURL = video["video"].stringValue
        
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
    }
}

extension MyBoxViewController: ASPVideoPlayerViewDelegate {
    func startedVideo() {
        
    }

    func stoppedVideo() {
    }

    func newVideo() {
    }

    func readyToPlayVideo() {
    }

    func playingVideo(progress: Double) {
       
    }

    func pausedVideo() {
       
    }

    func finishedVideo() {
        
    }

    func seekStarted() {
    }

    func seekEnded() {
        
    }

    func error(error: Error) {
    }

    func willShowControls() {
    }

    func didShowControls() {
    }

    func willHideControls() {
    }

    func didHideControls() {
    }
}
