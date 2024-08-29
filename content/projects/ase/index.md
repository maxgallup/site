+++
authors = ["Max Gallup"]
title = "Autonomous Systems Engineering VU"
description = "ASE is final year bachelor's project for students of Computer Science at the Vrije Universiteit Amsterdam. We provide a complete self-driving robotics platform, that allows the students to pursue a hands-on and challenging final project."
date = 2024-08-20
draft = false

[taxonomies]
tags = ["project", "robotics", "education"]
+++

A commonly shared sentiment amongst computer science students is _"I've learned all this theory, but I feel unprepared to apply it in the __real world__"._ Although there are some courses that teach theory through practical assignments and encourage deep problem solving, there are no real opportunities that force students to practice project planning, rigor, and fastidiousness. At least this is the case at non-technical universities such as the [VU](https://vu.nl). While I found the bachelor course to be challenging and fulfilling in many ways, I would've benefitted from having a project where one builds a complete __thing__ through an iterative design process.

Luckily, I actually did have such an opportunity. Thanks to Natalia Silvis, the VU participates in the annual NXP Cup where students build and program an autonomous racing car and compete for the best lap times. I joined a team in 2023 and we decided to build a fully custom race car that uses a full linux-based computer (as opposed to a less capable micro controller found in the default kits). Since we used a usb camera for viewing the track, we really wanted to have a live video stream that would allow us to adjust and improve the system while it's driving. After many hours of work, [Elias Groot](https://ljz.nl) and I created such a system and were able to rapidly prototype the car's self driving algorithm. Over the next year we further improved the software and hardware up to a point which won us first place in at the NXP Cup in 2024.

The project was a fruitful learning experience that encompassed many key topics in Computer Science, but most importantly it emphasized the trial and error process found across all engineering disciplines. We thought that the platform we built for ourselves could be shared with students for them to build on top of and explore new and interesting ideas in the world of robotics and autonomous systems. So, Elias and I decided to build 20 new polished cars and modularize the software further so that students could use it and apply it to a new field of research for their bachelor projects. We called the project the name [Autonomous Systems Engineering (ASE)](https://ase.vu.nl) consisting additionally of Hugo van Wezenbeek, Eduardo Lira, Niels Althuisius who helped with software/hardware of the cars and Joshua Kenyon and Natalia Silvis who helped with student meetings and graded the students' final research reports. The 13 students who participated all successfully completed a challenging and rewarding project. Their research varied from analyzing component safety systems to comparing traffic jam prevention algorithms (see their [project showcase](https://ase.vu.nl/docs/project/showcase/2024)).

Elias and I hope that future students who have a deep passion for robotics and engineering will sign up and take on the challenge to create something they are truly proud of.
