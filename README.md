# Cronica

<p align="center">
    <img src="https://cronica.alexandremadeira.dev/resources/img/icon.png" alt="Cronica Icon" width="100" height="100" />
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

Thanks to CloudKit and SwiftUI, Cronica also can run on Apple Watch, and the information will automatically sync.


##  Build information

#### This project targets iOS 16, iPadOS 16, watchOS 9, macOS 13, and requires Xcode 14.

To get started you'll need to:

1. Get an API key to use TMDb API, you can get yours at their [webiste](https://www.themoviedb.org/documentation/api),  after that, go to Shared/Configuration/Key and replace the value of *tmdbApi* with your own key.
2. You can remove TelemetryDeck service if you want to, I use it for the Feedback feature and sending signal when a catch occurs.

If you any question, you can send me an email at <a href = "mailto: contact@alexandremadeira.dev"> contact@alexandremadeira.dev</a>, I'll try to answer as quick as I can.


## Instalation

Cronica is available in the [App Store](https://apple.co/38SXpVJ), you can also build it using its source-code.

<p align="center">
    <a href="https://apple.co/38SXpVJ">
            <img src="https://tools-qr-production.s3.amazonaws.com/output/apple-toolbox/d15209c4e281948b35db08fcd41ac5f0/4ab4af64ddd50c272495eae4245f6a8e.png" alt="App Store QR Code" minWidth="250" minHeight="250" width="300" height="300">
    </a>
 </p>
