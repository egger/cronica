# Cronica

<p align="center">
    <img src="https://alexandremadeira.dev/resources/img/cronica/icon.webp" alt="Cronica Icon" width="100" height="100" />
</p>

<p align="center">
    Cronica is an app to remind you about your new movies, and tv shows.
</p>

<p align="center">
    <a href="https://twitter.com/_alexMadeira">
        <img src="https://img.shields.io/badge/Twitter-@_alexMadeira-lightgrey.svg?style=flat" alt="Twitter: @_alexMadeira" />
    </a>
<img src="https://img.shields.io/github/license/MadeiraAlexandre/Cronica" alt="GitHub license MIT badge" />

</p>


<p align="center">
    <img src="https://github.com/MadeiraAlexandre/Cronica/blob/main/Screenshots/CronicaHome.png?raw=true" alt="Cronica Screenshot" minWidth="220" maxWidth="560" minHeight="120" maxHeight="500">
</p>

## About

Cronica is built using Swift and SwiftUI, it uses Core Data to persist the user's watchlist, and CloudKit to sync the list effortlessly between the user's device. 

To provide release notifications, the app takes advantage of local notifications to notify users about new episodes or a movie release. To keep notifications useful, there's a background task that updates item values with new information using TMDb API, if needed.

Thanks to CloudKit and SwiftUI, Cronica also can run on every Apple device, and the information will automatically sync.

## Project Organization
> **I've made some changes to the app structure in the latest commits. These changes will make it easier for me to quickly port new iOS features to the macOS and tvOS versions of the app, while also allowing me to share the same App Store page.**

> **If you're interested, you can check out the commit the last ['Commit with the old structure'](https://github.com/MadeiraAlexandre/Cronica/tree/d594a9c2b1b68ec98ca9075c2504fff6574ce172) and follow the project organization outlined below:**
- Files related to Models, ViewModels, Network, Error, and Localization live inside the Shared folder.
- The iOS and iPadOS apps are fully inside the Shared folder.
- The tvOS app shares resources with Shared folder and it's unique UI elements lives only on AppleTV folder.
- The macOS app shares resources with Shared folder and it's unique UI elements lives only on Mac folder.
- The watchOS app shares resources with Shared folder and it's unique UI elements lives only on AppleWatch folder.

##  Build information

#### This project targets iOS 16, iPadOS 16, watchOS 9, macOS 13, tvOS 16 and requires Xcode 14.

To get started you'll need to:

1. Get an API key to use TMDb API, you can get yours at their [website](https://www.themoviedb.org/documentation/api),  after that, go to Shared/Configuration/Key and replace the value of *tmdbApi* with your own key.
2. You can remove TelemetryDeck service if you want to, I use it for the Feedback feature and sending signal when a catch occurs.

## App Store

### iOS/iPadOS

<p align="center">
	<img src="https://raw.githubusercontent.com/MadeiraAlexandre/Cronica/main/Screenshots/iPhone.webp" alt="Cronica running on MacBook Air displaying details for Top Gun: Maverick." minWidth="220" maxWidth="440" height="340">
</p>
<p align="center">
<a href="https://apple.co/38SXpVJ">
	<img src="https://alexandremadeira.dev/resources/img/cronica/AppStoreBadge.svg" alt="Badge for download Cronica on App Store" width="160" height="80">
</a>
</p>

### Apple Watch

<p align="center">
	<img src="https://raw.githubusercontent.com/MadeiraAlexandre/Cronica/main/Screenshots/Apple%20Watch.webp" alt="Cronica running on Apple Watch S7." minWidth="220" maxWidth="440" height="240">
</p>
<p align="center"> 
<a href="https://apps.apple.com/app/cronica/id1614950275">
	<img src="https://alexandremadeira.dev/resources/img/cronica/AppStoreBadge.svg" alt="Badge for download Cronica on Apple Watch App Store" width="160" height="80">
</a>
</p>

### Mac

<p align="center">
	<img src="https://raw.githubusercontent.com/MadeiraAlexandre/Cronica/main/Screenshots/Mac.webp" alt="Cronica running on MacBook Air displaying details for Top Gun: Maverick." maxWidth="220" maxWidth="440" >
</p>
<p align="center">
<a href="https://apple.co/38SXpVJ">
	<img src="https://raw.githubusercontent.com/MadeiraAlexandre/Cronica/main/Screenshots/Badges/Mac.svg" alt="Badge for download Cronica on Mac App Store" width="160" height="80">
</a>
</p>

### Apple TV
<p align="center">
	<img src="https://raw.githubusercontent.com/MadeiraAlexandre/Cronica/main/Screenshots/TV.webp" alt="Cronica running on Apple TV displaying details for Top Gun: Maverick." maxWidth="220" maxWidth="560" minWidth="40" minHeight="60">
</p>
<p align="center">
<a href="https://apple.co/38SXpVJ">
	<img src="https://raw.githubusercontent.com/MadeiraAlexandre/Cronica/main/Screenshots/Badges/AppleTV.svg" alt="Badge for download Cronica on Apple TV App Store" maxWidth="160" maxHeight="80"> 
</a>
</p>


### QR Code
<p align="center">
    <a href="https://apple.co/38SXpVJ">
            <img src="https://tools-qr-production.s3.amazonaws.com/output/apple-toolbox/d15209c4e281948b35db08fcd41ac5f0/4ab4af64ddd50c272495eae4245f6a8e.png" alt="App Store QR Code" minWidth="250" minHeight="250" width="300" height="300">
    </a>
 </p>

### TestFlight
<p>
You can also download the latest beta from <a href="https://testflight.apple.com/join/T8kwk6Gb">TestFlight</a>
</p>


## Contact

If you any question, you can send me an email at <a href = "mailto: contact@alexandremadeira.dev"> contact@alexandremadeira.dev</a>, I'll try to answer as quick as I can.<br>
Follow me on Twitter: [_alexMadeira](https://twitter.com/_alexMadeira).

