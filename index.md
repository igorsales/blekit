---
title: About
layout: page
---

### Overview
BLEKit (/blekit/) is a simple iOS Framework to develop apps based on the BLEKit platform. With it you can

1.  iBeacons
1. Discover BLEKit peripherals around you
1. Remotely control peripherals
1. Create wireless sensors

### Hardware
BLEKits are currently based on the [BLE-113](http://www.silabs.com/products/wireless/bluetooth/bluetooth-smart-modules/Pages/ble113-bluetooth-smart-module.aspx]) chip from Silicon Labs (subsidiary of [Bluegiga](https://www.bluegiga.com/en-US/)).

The hardware source design files can be found [here](https://github.com/igorsales/blekit-hw)

### Firmware

BLEKit's firmware is currently written in BGScript (Bluegiga's Smart Module programming language)

The firmware source can be found [here](https://github/igorsales/blekit-fw)

### Software

BLEKit's interface software permits discovering, connecting to, and controller BLEKits. Only iOS is currently supprted.

The software  for iOS can be found [here](https://github.com/igorsales/blekit)

#### Some BLEKits available

1. [BLEKitRC](https://github.com/igorsales/blekit-rc)
1. [CarBeacon](https://github.com/igorsales/carbeacon)
1. iBeacon

#### Future work

These are some of the ideas I would like to develop in the future:

* RoadBeacon

BLEKit beacons along a road or highway, and create an app to aggregate user's obfuscated information to allow better flow of traffic.

* GardenSensor

BLEKit with multiple sensors in your gargen, measuring humidity, sun exposure, etc. 
Turns on a beacon when your attention is required. Collect stats over time.


### Authors and Contributors
In 2014, @igorsales started working on BLEKit on his spare time. He is still the principal maintainer. Open Source since July/2016.
