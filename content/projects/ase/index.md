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

<br>
<br>

## ASE Software Framework

When we first started programming a prototype Rover in 2022 there was a number of programs we wrote for ourselves that had nothing to do with the racing algorithm. We actually spent most of our time in making tools for ourselves that help us debug and introspect the Rover. Since the Rover features a rather powerful processor, we decided to build a Web Interface that receives live data from the Rover. This allowed us to see the images from the camera and to plot the values from the sensors live, while the Rover was driving autonomously (more on that later). Furthermore, we wanted to make it easy to manage complex configurations and monitor the status of the Rover so we wrote a lightweight manager that constantly runs on the Rover. Lastly, we wrote a command line utility that gives us full control over the Rover, taking inspiration from command lines tools such as `kubectl`. The following is a simplified bird's eye view of the software framework:

![Overview of the Rover](./software-framework.svg)

From the diagram on the left, we can see modular programs put together to form a basic self driving "pipeline". This design enforces a separation of concerns across multiple programs (referred to as "services") which exchange data with one another. This modularization allows students to just use parts of the framework that they need and add their own functionality as needed. For example, the default pipeline consists of three services: `imaging`, `controller` and `actuator`. The `imaging` service is responsible for processing the frames coming out of the camera and from them it extracts the midpoint of the lane. Then, the controller uses this middle point to calculate the speed and steering angle using PID control. It derives speed and steering commands that are passed on to the actuator, which translates those commands into hardware signals that are sent to the underlying actuators. As we can see, there is a dependency between services where the one depends on values computed by the other. Meanwhile, the `transceiver` service is one that listens to all data published by any service and reports it live over the network to the developer.

But this seems like an unnecessary amount of inter-process communication, why not write just one program? While this results in roughly 1-2ms of overhead to the entire pipeline, it is a worth tradeoff for the following reason: with this fine grained modularity, students are able to replace any one of these services and not have to spend time implementing parts of the system that add no value to their research. They simply don't need to reinvent the wheel if that's not part of their project. For example, if a student wants to write their own image processing and navigation algorithm, they can simply pass data to the existing `actuator` service which commands the underlying hardware to control the motors and steering. Furthermore, the services communicate in a language agnostic protocol meaning that students can implement their service in any programming language. But how exactly?

### Language Agnostic Interop

In order to make the framework language agnostic, separate processes have to exchange messages with as little latency as possible. Shared memory is basic infrastructure provided by the operating system which does exactly that: share memory between processes. [LibZMQ](https://zeromq.org/get-started/) is a library that exposes handy wrappers on top of shared memory and exposes useful primitives such as **message queues** and **publish-subscribe** models. Luckily, ZMQ offers excellent language support, meaning that a program written in any language could use its ZMQ library to communicate with the rest of the system. However, since most students will either be programming in C or Python, we offer wrappers around ZMQ to make it even easier to write a service in those languages. Since all of our services are written in Go, there is of course support for that as well. At the core of supporting any language is the flexibility gained by using a message passing implementation such as ZMQ.

### Managing Services

After deciding on the service-oriented architecture, we desperately needed a way of starting and stopping these services and we wanted to create an easy way to hook in to the system by giving names to the inputs and outputs of each service. First, we decided to create a convention that organizes the metadata of a single service into a file called the `service.yaml`. This file sits at the root of each service and contains the following information:

``` yaml
name: controller
author: vu-ase
version: 1.0.0

commands:
  run: ./bin/controller
  build: make build

inputs:
  - service: imaging
    streams:
      - path

outputs:
  - decision

configuration:
  - name: speed
    tunable: true
    type: number
    value: 0.4
    mutable: true
  ...
```

We wanted it to make it as **easy** as possible for students to start writing their own service, so let's take a look at each of these fields to understand how the underlying software is helping out manage the complexity.

* `name` - A short name that uniquely identifies a service when running a pipeline (there is always only one "controller" running at a time).
* `author` - Since the Rovers are a shared resource for students, it was important to further identify a service by its author.
* `version` - This further distinguishes a service which is useful for racing. At the day of the competition, one might have multiple versions of the same code which makes it convenient to identify them as different.
* `commands`
    * `run` - Since we want to be able to remotely start the execution, the system needs to know which command to use to actually run the service. In the case of python scripts, this could be something like `run: python main.py`
    * `build` - In case the service needs to be compiled before running, this command will be executed.
* `inputs` - Inputs specify any optional data dependencies from other services. In this case we are subscribing to the "path" output stream of the "imaging" service.
* `outputs` - Outputs specify data streams that this service is publishing. Other service can the read the data by specifying the name of the output stream as one of their inputs.
* `configuration` - This section specifies data that is made available to the program just for convenience. It is often useful to separate data from code, especially if the data is often changed. One nice thing here is the `mutable` field, which allows you to change this configuration value while the Rover is running through the Web interface.


Each service must specify such a `service.yaml` and multiple services together form a pipeline. Using the `roverctl` or via the web interface, one can specify the list of service that should make up a pipeline and start them. 




For this, we created `roverd` which is a long-running process (daemon) that listens for requests from `roverctl`, a command line tool exposing the full functionality of the services running on the rover. 



### The Web Utility

![todo image of web ui]() 
Since the Rover is designed around a Linux-based computer, we decided to modularize the software framework running on the Rover 

### Bird's Eye view of ASE Software


<!-- 



### Knowledge Base



## Use in Education
* Bachelor Projects


## Use for Competition
* NXP CUP Qualifiers + Finals 2025
* NXP CUP Qualifiers + Finals 2026
* videos -->




