//
//  JWTValidator.swift
//  BindID Example
//
//  Created by Transmit Security on 07/12/2021.
//

import Foundation

typealias JWTValidatorError = String

class JWTValidator {
    
    enum Result {
        case success
        case error(String)
    }
    
    /**
     1. Parse the token to Headers, Payload and Signature
     2. Convert the headers, payload and signature to get their CFData representations
     3. Fetch the public key from the BindID jwks endpoint
     4. Parse our certificate to get its public key as a SecKey representation
     5. Verify the signature
     6. Decode JWT payload to verify the expiration date and the token issuer
     */
    
    public func validate(_ idToken: String, callback: @escaping (Result) -> Void) {
        
        // 1. Parse the token to Headers, Payload and Signature
        let tokenParts = idToken.split(separator: ".")
        guard tokenParts.count == 3 else {
            callback(.error("Error validating JWT token components formation"))
            return
        }
        
        let tokenHeadersAndPayload = "\(tokenParts[0]).\(tokenParts[1])"
        let tokenSignature = String(tokenParts[2])
        
        // 2. Convert the headers, payload and signature to get their CFData representations
        let tokenHeadersAndPayloadData = tokenHeadersAndPayload.data(using: .ascii)! as CFData
        guard let tokenSignatureData = Data(base64Encoded: tokenSignature.base64FromBase64Url) else {
            callback(.error("Error decoding token signature"))
            return
        }
        
        // 3. Fetch the BindID Public key
        fetchBindIDPublicKey { certificateBase64 in
            guard let certificateBase64 = certificateBase64 else {
                callback(.error("Error fetching BindID Public Key"))
                return
            }

            guard let certificateData = Data(base64Encoded: certificateBase64),
                  let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
                callback(.error("Error converting certificate to CFData"))
                return
            }
            
            if let publicKey = SecCertificateCopyKey(certificate), // 4. Parse our certificate to get its public key as a SecKey representation
               !SecKeyVerifySignature(                             // 5. Verify the signature
                publicKey,
                .rsaSignatureMessagePKCS1v15SHA256,
                tokenHeadersAndPayloadData, tokenSignatureData as CFData,
                nil) {
                callback(.error("Error validating BindID token signature"))
                return
            }
            
            // 6. Decode JWT payload to verify the expiration date and the token issuer
            guard let decodedPayload = try? JWTDecoder().decodePayload(idToken) else {
                callback(.error("Error decoding BindID JWT payload"))
                return
            }
            
            guard let iss = decodedPayload["iss"] as? String, // get issuer
                  let issuer = URL(string: iss),
                  let exp = decodedPayload["exp"] as? Double, // get expiration date
                  let expiration = exp.date else {
                callback(.error("Error extracting token issuer and expiration date"))
                return
            }
            
            guard let host = issuer.host, !host.isEmpty else {
                callback(.error("Missing issuer host in the JWT token"))
                return
            }
            
            if Environment.hostUrl == nil || host != Environment.hostUrl!.host { // compare issuer with BindID host
                callback(.error("Token issuer \(host) does not match BindID host \(String(describing: Environment.hostUrl))"))
                return
            }
            
            if expiration < Date() { // confirm expiration date is later then now
                callback(.error("Error verifying token issuer and expiration date"))
                return
            }
            
            callback(.success)
        }
    }
    
    private func fetchBindIDPublicKey(callback: @escaping (String?) -> Void) {

        func callbackInMainThread(_ publicKey: String?) {
            DispatchQueue.main.async {
                callback(publicKey)
            }
        }

        guard var hostUrl = Environment.hostUrl else { return callbackInMainThread(nil) }
        hostUrl.appendPathComponent("jwks")        
        
        // Fetch the public key from the BindID jwks endpoint
        let task = URLSession.shared.dataTask(with: hostUrl) { (data, response, error) in
            guard let data = data else { return callbackInMainThread(nil) }
            // Serialize the response and convert it to an array of key objects
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            guard let keys = json?["keys"] as? [[String: Any]] else { return callbackInMainThread(nil) }
            
            // Find the key that contains the "sig" value in the "use" key. Return the publicKey in it
            if let use = keys.first(where: { ($0["use"] as? String) == "sig" }) {
                if let x5c = use["x5c"] as? [String], let publicKey = x5c.first {
                    callbackInMainThread(publicKey)
                    return
                }
            }
            
            callbackInMainThread(nil) // Public key was not found in the publicKeyEndPoint response
        }

        task.resume()
    }
}

extension String {
    var base64FromBase64Url: String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        base64 += String(repeating: "=", count: base64.count % 4)
        
        return base64
    }
}
