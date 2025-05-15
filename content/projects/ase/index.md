+++
title = "The ASE Rover: an Educational Platform for Embedded Systems"
description = "Autonomous Systems Engineering (ASE) is a Lab providing small-scale autonomous vehicles for students of Computer Science at Vrije Universiteit Amsterdam."
date = 2024-05-05
draft = true
[extra]
image = "ase-logo.png"
repo = "https://github.com/VU-ASE"
docs = "https://ase.vu.nl"
+++

The main goal of this project was to create small-scale autonomous vehicles that use computer vision for real-time autonomous driving. Such vehicles would be used in the annual [NXP Cup](https://nxpcup.nxp.com/) which is an autonomous driving competition where students from the EMEA region build and program a small-scale autonomous vehicle. Since 2019, the student teams from the VU have been going to the races and in 2023 this project set out to create a fleet of 20 "Rovers". On top of racing, students have the option to do their bachelor thesis at the ASE Lab ranging from topics like computer vision, localization or energy efficient computing. The Rovers were thus designed with two main goals in mind: *performance* and *extensibility*.

![](rover-wide.jpg)

## Hardware Design

In order to create a fast vehicle, we decided to prioritize high acceleration and active braking. The drive train consisted of two brushless motors that were mounted in a direct drive configuration. This gave us the advantage of reducing mechanical complexity (no gears needed), however it shifted the complexity to the firmware in the speed controllers. Brushless motors (like those used in drones) use a rather simple, open loop control method and typically run at relatively high RPM. However, our motors need to spin much slower and with more torque due to the direct drive setup. To achieve this, we used the [*Field Oriented Control*](https://en.wikipedia.org/wiki/Vector_control_(motor)) control method which requires a sensor to measure the angle of the rotating wheel. Such a closed-loop system then receives a single target speed which it tries to maintain. Setting the target speed to *0* effectively creates a strong braking force and the motors will actively resist rotation, ideal for racing.

Furthermore, since the Rovers are used by students the high power electronics must be protected with fuses and fail safes. Separating the electronics into a power distribution board and a sensor connection board helped mitigate any damages caused by accidents. The sensor connection board offers numerous commonly used hardware interfaces allowing new sensors to be custom mounted. For example, one student project added connected a LiDAR over USB while another project used an accurate current sensor over I2C. As seen in the image below, the Rover was designed to be accessed primarily from the top half (above the blue line) which provides access to all of the electronic connections. On the bottom side of the line are the components that are less interesting for students, namely the aforementioned drive train and battery compartment.

![Side view of the Rover](./side-view.jpg)

At the heart of the Rover is the [Debix Model A](https://www.debix.io/hardware/model-a.html), a powerful single board computer running Linux. It features various I/O interconnects and comes with Wifi and Bluetooth to enable wireless data transfers.

![Overview of the Rover](./overview.png)

## Software Framework Overview

The ASE Software framework is a collection of modular programs that can be put together to form a basic self driving "pipeline". This design enforces a separation of concerns across programs (referred to as a "services") which send data to each other. By doing so, students can use just parts of the framework that they need and add their own software for their project. For example, the default pipeline consists of three services: `imaging`, `controller` and `actuator`.



Since the Rover is designed around a Linux-based computer, we decided to modularize the software framework running on the Rover 


<!-- ### Language Agnostic Interop

### The Web Utility

### Knowledge Base



## Use in Education
* Bachelor Projects


## Use for Competition
* NXP CUP Qualifiers + Finals 2025
* NXP CUP Qualifiers + Finals 2026
* videos -->




