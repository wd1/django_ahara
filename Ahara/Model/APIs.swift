//
//  APIs.swift
//  Ahara
//
//  Created by Miroslav Kostic on 4/20/21.
//

import Foundation
import Alamofire
import SwiftyJSON

func UserLogin(phone_number: String, password:String, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let parameters: Parameters = [
        "phone_number": phone_number,
        "password": password
    ]
    AF.request(constants.api_path + "auth/token/login/", method: .post, parameters: parameters).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func UserLogout(completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let headers: HTTPHeaders = [
        "Authorization": "Token " + UserDefaults.standard.string(forKey: "auth_token")!
    ]
    AF.request(constants.api_path + "auth/token/logout/", method: .post, headers:  headers).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func UserReadMe(completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let headers: HTTPHeaders = [
        "Authorization": "Token " + UserDefaults.standard.string(forKey: "auth_token")!
    ]
    AF.request(constants.api_path + "auth/users/me/", method: .get, headers: headers).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func reset_password_confirm(uid: String, token:String, new_password:String, re_new_password:String, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let parameters: Parameters = [
        "uid": uid,
        "token": token,
        "new_password": new_password,
        "re_new_password": re_new_password
    ]
    AF.request(constants.api_path + "auth/users/reset_password_confirm/", method: .post, parameters: parameters).validate(statusCode: [200, 201, 204, 400, 401]).responseJSON() { response in
        completionHandler(response)
    }
}

func reset_password_verify(phone_number: String, otp:String, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let parameters: Parameters = [
        "phone_number": phone_number,
        "otp": otp
    ]
    AF.request(constants.api_path + "auth/users/reset_password_verify_code/", method: .post, parameters: parameters).validate(statusCode: [200, 201, 204, 400, 401]).responseJSON() { response in
        completionHandler(response)
    }
}

func reset_password(phone_number: String, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let parameters: Parameters = [
        "phone_number": phone_number
    ]
    AF.request(constants.api_path + "auth/users/reset_password/", method: .post, parameters: parameters).validate(statusCode: [200, 201, 204, 400, 401, 404]).responseJSON() { response in
        completionHandler(response)
    }
}

func UserResendCode(phone_number: String, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let parameters: Parameters = [
        "phone_number": phone_number
    ]
    AF.request(constants.api_path + "auth/users/resend_activation/", method: .post, parameters: parameters).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func getAllRecipes(completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let headers: HTTPHeaders = [
        "Authorization": "Token " + UserDefaults.standard.string(forKey: "auth_token")!
    ]
    AF.request(constants.api_path + "recipe/", method: .get, headers: headers).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func getApprovedRecipes(completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let headers: HTTPHeaders = [
        "Authorization": "Token " + UserDefaults.standard.string(forKey: "auth_token")!
    ]
    AF.request(constants.api_path + "recipe/approved/", method: .get, headers: headers).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func getUnbox(completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let headers: HTTPHeaders = [
        "Authorization": "Token " + UserDefaults.standard.string(forKey: "auth_token")!
    ]
    AF.request(constants.api_path + "unbox/", method: .get, headers: headers).validate(statusCode: [200, 201, 204, 400]).responseJSON() { response in
        completionHandler(response)
    }
}

func like_or_unlike(id: String, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()) {
    let headers: HTTPHeaders = [
        "Authorization": "Token " + UserDefaults.standard.string(forKey: "auth_token")!
    ]
    AF.request(constants.api_path + "recipe/" + id + "/like/", method: .patch, headers: headers).validate(statusCode: [200, 201, 204, 400, 401, 404]).responseJSON() { response in
        completionHandler(response)
    }
}
