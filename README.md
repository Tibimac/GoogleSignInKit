# GoogleSignInKit

<p align="left">
	<img alt="Static Badge" src="https://img.shields.io/badge/Licence-MIT-color.svg?&logoSize=auto&labelColor=black&color=FFC600">
	<img alt="Static Badge" src="https://img.shields.io/badge/SPM-Compatible-color.svg?&logoSize=auto&labelColor=black&color=green">
	<a href="https://swiftpackageindex.com/Tibimac/GoogleSignInKit" target="_blank">
		<img alt="Static Badge" src="https://img.shields.io/badge/Swift-5.8_%7C_5.9_%7C_5.10_%7C_6.0-color?logo=swift&logoColor=F05138&logoSize=auto&labelColor=black&color=F05138">
	</a>
	<img alt="Static Badge" src="https://img.shields.io/badge/Platform-iOS_|_macOS-color.svg?&logoSize=auto&labelColor=black&color=blue">
	<a href="https://mastodon.social/@tibimac" target="_blank">
		<img alt="Static Badge" src="https://img.shields.io/badge/Mastodon-Tibimac-color?logo=mastodon&logoColor=6364FF&logoSize=auto&labelColor=black&color=6364FF">
	</a>
</p>


This module is intended to be used to do a "Google Sign-In" for your app.
Using this module will give you ability to authenticate a user and either create him an account or log him to an existing account.
What we call "sign-in" is composed in two parts :
- First part is authenticating user and let him choose which Google account to use for sign-in. This is done on a Google dedicated web page.
- Second part is retrieving credentials for the user-choosen account. This is done by doing a request on Google API.
Let's see how it works (it's very easy 😉).

Depending on how you want to use this module you have two possible flows.

## First flow
Start by configuring the module by giving it a configuration (`GoogleSignInKit.Manager.Configuration`) through a call to the function `configure(configuration:)`.
This is only needed once in your app lifecycle. So you can do it from your AppDelegate or at init of your login view controller.

Then once sign-in is required call the function `signIn(overrideConfig:completion:)`. 
Through this function you can override some parameters of the module configuration (but not the client ID) just for the time of the authentication by giving an optional `GoogleSignInKit.Configuration` struct.
And of course give your completion block in which you'll receive the `GoogleSignInKit.Credentials` struct with all you need to do the sign-up / sign-in.
If you need to repeat the sign-in you can call this function again. 

## Second flow
When sign-in is required just call the function `signIn(configuration:completion:)`.
Through this single function you can set the module configuration and start sign-in. 
As a second parameter of course give your completion block in which you'll receive the  `GoogleSignInKit.Credentials` struct with all you need to do the sign-up / sign-in.
If you need to repeat the sign-in you can either call this function again or call `signIn(overrideConfig:completion:)`, it's up to you.

## Need Demo ?
Here's a [GoogleSignInKit-Demo project](https://github.com/Tibimac/GoogleSignInKit-Demo)
