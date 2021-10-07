//
//  LetsCookViewController.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/20/21.
//

import UIKit
import ASPVideoPlayer
import Cosmos
import VGSegment
import SwiftyJSON

class LetsCookViewController: UIViewController, VGSegmentDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblLiked: UILabel!
    @IBOutlet weak var imgLiked: UIImageView!
    @IBOutlet weak var vwScroll: UIScrollView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var lblCookTime2: UILabel!
    @IBOutlet weak var lblCookTime1: UILabel!
    @IBOutlet weak var lblManCount: UILabel!
    @IBOutlet weak var lblCheifName: UILabel!
    @IBOutlet weak var lblRecipeName: UILabel!
    @IBOutlet weak var tblIngredient: UITableView!
    @IBOutlet weak var tblInstruction: UITableView!
    @IBOutlet weak var vwLearnMore: UIView!
    @IBOutlet weak var lblLearnMoreTitle: UILabel!
    @IBOutlet weak var lblLearnMoreDesc: UILabel!
    
    @IBOutlet weak var videoPlayerBackgroundView: UIView!
    @IBOutlet weak var vwPlayer: ASPVideoPlayer!
    @IBOutlet weak var containerView: UIView!
    
    var previousConstraints: [NSLayoutConstraint] = []
    
    var recp:JSON = []
    var serve:String = ""
    var t_prep:String = ""
    var t_cook:String = ""
    var desc:String = ""
    var cheifName:String = ""
    var recpName:String = ""
    var videoURL:String = ""
    var b_index:Int = 0
    
    var isLike:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let rect = CGRect(x: 0, y: lblDesc.layer.position.y + lblDesc.layer.frame.height + 20, width: view.frame.width, height: 45)
       let titles = ["       Ingredients       ", "     Instructions      ", "      Learn More       "]
       
       let segment = VGSegment(frame: rect, titles: titles)
       segment.delegate = self
       vwScroll.addSubview(segment)
        vwLearnMore.layer.cornerRadius = 12.0
       
       var configuration: VGSegmentConfiguration {
           let configura = VGSegmentConfiguration()
           // TODO: configuration segment
        configura.segmentBackgroundColor = UIColor(rgb: 0xF8D90F)
        configura.indicatorColor = UIColor(rgb: 0xE2283D)
        configura.normalTitleColor = UIColor(rgb: 0x333333)
        configura.normalTitleFont = UIFont(name:"Roboto-Regular", size:12.0)!
        configura.selectedTitleColor = UIColor(rgb: 0x333333)
        configura.selectedTitleFont = UIFont(name:"Roboto-Bold", size:12.0)!
        //configura.selectedTitleFont = UIFont(name: "Roboto-Black", size: 12.0)!
           return configura
       }
       segment.configuration = configuration
        
        tblIngredient.delegate = self
        tblIngredient.dataSource = self
        tblInstruction.delegate = self
        tblInstruction.dataSource = self
         
        lblDesc.text = desc
        lblManCount.text = serve
        lblCookTime1.text = t_prep
        lblCookTime2.text = t_cook
        lblRecipeName.text = recpName
        lblCheifName.text = cheifName
        lblLearnMoreTitle.text = recp["learn_more_title"].stringValue
        lblLearnMoreDesc.text = recp["learn_more_desc"].stringValue
        isLike = recp["is_liked"].boolValue
        lblLiked.text = isLike ? "" : "Favorite"
        imgLiked.image = isLike ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onfavourite(_:)))
        imgLiked.addGestureRecognizer(tap)
        imgLiked.isUserInteractionEnabled = true
        
        vwPlayer.delegate = self
        vwPlayer.configuration = ASPVideoPlayer.Configuration(videoGravity: .aspectFill, startPlayingWhenReady: true, controlsInitiallyHidden: true)
        
        vwPlayer.resizeClosure = { [unowned self] isExpanded in
            self.rotate(isExpanded: isExpanded)
        }
        self.vwPlayer.videoURLs.append(URL(string:videoURL)!)
        
    }
    @IBAction func onShare(_ sender: Any) {
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareViewController") as? ShareViewController
        else{
            return
        }
        dst_vc.recp = recp
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
    }
    
    @objc func onfavourite(_ sender: UITapGestureRecognizer? = nil)
    {
        self.showSpinner()
        like_or_unlike(id:self.recp["pk"].stringValue, completionHandler: { response in
            switch response.result {
                case .success(let value):
                    self.removeSpinner()
                    print(value)
                    self.isLike = !self.isLike
                    self.lblLiked.text = self.isLike ? "" : "Favorite"
                    self.imgLiked.image = self.isLike ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arrIngredient = self.recp["recipe_ingredients"].arrayValue
        let steps = self.recp["preparations"].arrayValue
        if tableView == self.tblIngredient{
            return arrIngredient.count
        }else{
            return steps.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tblIngredient{
            return 80
        } else{
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arrIngredient = self.recp["recipe_ingredients"].arrayValue
        let steps = self.recp["preparations"].arrayValue
        if tableView == self.tblInstruction
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell", for: indexPath) as! InstructionCell
            let step = steps[indexPath.row]
            cell.lblStep.text = "Step " + String(indexPath.row)
            cell.lblDesc.text = step["detail"].stringValue
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath) as! IngredientCell
            let item = arrIngredient[indexPath.row]
            cell.lblName.text = item["ingredient"].stringValue
            cell.lblAmount.text = item["unit"].stringValue
            return cell
        }
    }
    
    func didSelectAtIndex(_ index: Int) {
        if index == 0{
            tblIngredient.isHidden = false
            tblInstruction.isHidden = true
            vwLearnMore.isHidden = true
        } else if index == 1{
            tblIngredient.isHidden = true
            tblInstruction.isHidden = false
            vwLearnMore.isHidden = true
        } else{
            tblIngredient.isHidden = true
            tblInstruction.isHidden = true
            vwLearnMore.isHidden = false
        }
    }
    @IBAction func onBack(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        if self.b_index == 0{
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyBoxViewController") as? MyBoxViewController
            else{
                return
            }
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        } else if (self.b_index == 1) {
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReadyToCookViewController") as? ReadyToCookViewController
            else{
                return
            }
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        } else if (self.b_index == 2){
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindReceipeViewController") as? FindReceipeViewController
            else{
                return
            }
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        }
    }
    
}

extension LetsCookViewController: ASPVideoPlayerViewDelegate {
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
