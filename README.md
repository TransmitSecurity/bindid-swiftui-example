# Login

Build app-less, passwordless login experiences with BindID for customers that want to access your iOS SwiftUI application. This sample app uses the BindID SDK to initiate strong authentication flows with the BindID service to sign in your users.

## Prerequisites

Before you begin, you'll need to have an application configured in the [BindID Admin Portal](https://admin.bindid-sandbox.io/console/#/applications). From the application settings, obtain the client credentials and configure a redirect URI for this client that will receive the authentication result. This URI should use a custom scheme such as `bindidexample://login`.   
For more, see [BindID Admin Portal: Get Started](https://developer.bindid.io/docs/guides/admin_portal/topics/getStarted/get_started_admin_portal).

## Instructions

To run the sample on your iOS device:  

1 - Configure your client credentials in the Environment.swift file:
```bash
'bindIDClientID' # Client ID obtained from the BindID Admin Portal
'bindIDRedirectURI' # Redirect URI you defined in the BindID Admin Portal
```  

2 - Build and run the application in XCode on your iOS device target.


## What is BindID?
The BindID service is an app-less, strong portable authenticator offered by Transmit Security. BindID uses FIDO-based biometrics for secure, frictionless, and consistent customer authentication. With one click to create new accounts or sign into existing ones, BindID eliminates passwords and the inconveniences of traditional credential-based logins.  
[Learn more about how you can boost your experiences with BindID.](https://www.transmitsecurity.com/developer)

## Author
Transmit Security, https://github.com/TransmitSecurity

## License
This project is licensed under the MIT license. See the LICENSE file for more info.
