YesWeScan
=========

A sample project that demonstrates bar code recognition &amp; QR code creation made available in iOS 7.

## Introduction

If you've ever had to generate a barcode or read one with software, you may have used libraries like the following:

   * Open Source: http://code.google.com/p/zxing/
   * Commercial: http://redlaser.com/developers/

There are limitations to each of these. So I was excited when Apple announced a "barcode recognition" API, and discussed it in more detail in Session 610 ("What's New in Camera Capture"). AVFoundation adds support for the 10 or so formats supported by Passbook (note the "Scan Code" feature added to that app). 

The sample app should be installed on two devices, and demonstrates creation of a QR code in one tab, and the successful reading of that code in the other. The project is called "Yes We Scan."

## Technical Details

The project consists of a UITabBarController with two tabs: one to create QR codes (CreateViewController), and one to read them (ReadViewController). The former presents a UISearchBar that allows you to enter the encoded string; the latter scans for available codes. Tapping the screen while a code is highlighted will present a UIAlertView with the decoded text.

## References

This project was influenced by the following WWDC sessions and sample code:

   * Session 610 ("What's New in Camera Capture"): QRchestra
   * Session 509 ("Core Image Effects and Techniques"): CIFunHouse
