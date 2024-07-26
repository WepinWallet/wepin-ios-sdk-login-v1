//
//  SignMessage.swift
//  WepinLogin
//
//  Created by iotrust on 6/13/24.
//

import Foundation
import secp256k1
import CryptoKit

func signMessage(message: String, hexPrivateKey: String) -> String? {
    // message를 Data로 변환
    guard let messageData = message.data(using: .utf8) else {
//        print("메시지를 Data로 변환하는 데 실패했습니다.")
        return nil
    }
    
    // hexPrivateKey를 Data로 변환
    guard let privateKeyData = Data(hexString: hexPrivateKey) else {
//        print("Hex Private Key를 Data로 변환하는 데 실패했습니다.")
        return nil
    }
    
    // secp256k1 context 생성
    guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
//        print("secp256k1 context 생성 실패")
        return nil
    }
    defer {
        secp256k1_context_destroy(ctx)
    }

    // private key 설정
    var privateKey = privateKeyData.bytes
    guard secp256k1_ec_seckey_verify(ctx, &privateKey) == 1 else {
//        print("유효하지 않은 Private Key입니다.")
        return nil
    }

    // 메시지 해시 생성 (SHA256 사용)
  
    var hash = Data(SHA256.hash(data: messageData)).bytes

    // 서명 생성
    var signature = secp256k1_ecdsa_signature()
    guard secp256k1_ecdsa_sign(ctx, &signature, &hash, &privateKey, nil, nil) == 1 else {
//        print("서명 생성 실패")
        return nil
    }

    // 서명 직렬화
    var signatureSerialized = [UInt8](repeating: 0, count: 64)
    _ = 64
    guard secp256k1_ecdsa_signature_serialize_compact(ctx, &signatureSerialized, &signature) == 1 else {
//        print("서명 직렬화 실패")
        return nil
    }

    // 직렬화된 서명을 hex string으로 변환하여 반환
    return Data(signatureSerialized).hexString
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex
        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }

    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }

    var bytes: [UInt8] {
        return [UInt8](self)
    }
}
