# GoogleSignInKit

<img src="https://camo.githubusercontent.com/86f8561418bbd6240d5c39dbf80b83a3dc1e85e69fe58da808f0168194dcc0d3/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5377696674504d2d436f6d70617469626c652d627269676874677265656e2e737667" alt="SwiftPM Compatible" data-canonical-src="https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg" style="max-width:100%;">

⚠️ In its v1.0.0 this module is intended to be use in an iOS app only.

This module is intended to be used to do a "Google Sign-In" for your app.
Using this module will give you ability to authenticate a user and either create him an account or log him to an existing account.
What we call "sign-in" is composed in two parts :
- First part is authenticating user and let him choose which Google account to use for sign-in. This is done on a Google dedicated web page.
- Second part is retrieving credentials for the user-choosen account. This is done by doing a request on Google API.
Let's see how it works (it's very easy 😉).

Depending on how you want to use this module you have two possible flows.

## First flow
Start by configuring the module by giving it a configuration (`GoogleSignInKit.Manager.Configuration`) through a call to the function `configure(configuration:)`.
This is only needed once in your app lifecycle. So you can do it from your AppDelegate or at init of you login view controller.

Then once sign-in is required call the function `signIn(overrideConfig:completion:)`. 
Through this function you can override some parameters of the module configuration (but not the client ID) just for the time of the authentication by giving an optional `GoogleSignInKit.Configuration` struct.
And of course give your completion block in which you'll receive the `GoogleSignInKit.Credentials` struct with all you need to do the account creation / sign-in.
If you need do repeat the sign-in you can call this function again. 

## Second flow
When sign-in is required just call the function `signIn(configuration:completion:)`.
Through this single function you can set the module configuration and start sign-in. 
As a second paramter of course give your completion block in which you'll receive the  `GoogleSignInKit.Credentials` struct with all you need to do the account creation / sign-in.
If you need do repeat the sign-in you can either call this function again or call `signIn(overrideConfig:completion:)`, it's up to you.

## Need Demo ?
Here's a [GoogleSignInKit-Demo project](https://github.com/Tibimac/GoogleSignInKit-Demo)
