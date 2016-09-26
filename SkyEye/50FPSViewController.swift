//
//  50FPSViewController.swift
//  NuPlayer
//
//  Created by CCHSU20 on 9/26/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit


class _0FPSViewController: UIViewController, UITextFieldDelegate {
    //MARK: IBOutlet, IBAction
    @IBOutlet var urlText: UITextField?
    @IBAction func connectURL(){
        if urlText?.text != "" {
            let localURL = urlText!.text
            let parameters = [KxMovieParameterDisableDeinterlacing: true]
            let vc: KxMovieViewController = KxMovieViewController.movieViewControllerWithContentPath(localURL, parameters: parameters) as! KxMovieViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
