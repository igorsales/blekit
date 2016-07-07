---
title: About
layout: page
---

### Overview
BLEKit (/blekit/) is a Bluetooth Low Energy platform. With it you can

1. Discover BLEKit peripherals around you
1. Remotely control peripherals
1. Create wireless sensors
1. Create iBeacon devices

### Hardware
BLEKits are currently based on the [BLE-113](http://www.silabs.com/products/wireless/bluetooth/bluetooth-smart-modules/Pages/ble113-bluetooth-smart-module.aspx]) chip from Silicon Labs (parent company of [Bluegiga](https://www.bluegiga.com/en-US/)).

BLEKit open source hardware files are [here](https://github.com/igorsales/blekit-hw)

### Firmware

BLEKit's firmware is written in BGScript (Bluegiga's Smart Module programming language)

The open source firmware is [here](https://github.com/igorsales/blekit-fw)

### Software

BLEKit's interface software permits discovering, connecting to, and controller BLEKits. 
Currently, only iOS is supprted and is [here](https://github.com/igorsales/blekit)

#### Open Source BLEKit projects

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
