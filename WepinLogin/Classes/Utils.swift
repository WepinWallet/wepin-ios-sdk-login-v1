//
//  Utils.swift
//  WepinLogin
//
//  Created by iotrust on 6/18/24.
//

import Foundation
import BCrypt

func hashPassword(_ password: String) -> String {
    let BCRYPT_SALT = "$2a$10$QCJoWqnN.acrjPIgKYCthu"
    return try! BCrypt.Hash(password, salt: BCRYPT_SALT)
}
// 사용 예시
func isFirstEmailUser(errorString: String) -> Bool {
    do {
       // JSON 문자열 추출
       let data = errorString.data(using: .utf8)!
       let jsonObject = try JSONSerialization.jsonObject(with: data, options:  [.allowFragments])
       guard let dictionary = jsonObject as? [String: Any] else {
           return false
       }

       // 필요한 필드 값 추출
       guard let status = dictionary["status"] as? Int,
             let message = dictionary["message"] as? String else {
           return false
       }

       // 조건 검사
       let isStatus400 = (status == 400)
       let isMessageContainsNotExist = message.contains("not exist")

       // 결과 출력
       return isStatus400 && isMessageContainsNotExist
   } catch {
//       print("Error parsing JSON: \(error.localizedDescription)")
       return false
   }
}

// JSON 디코딩 함수
func decodeJSONToDictionary(jsonData: Data) -> [String: Codable]? {
    do {
        if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Codable] {
            return jsonDictionary
        }
    } catch {
//        print("JSON 디코딩 에러: \(error.localizedDescription)")
    }
    return nil
}

// URL 인코딩 함수
func customURLEncode(_ string: String) -> String {
    // 인코딩할 캐릭터셋을 정의
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: ":/")
    return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
}
