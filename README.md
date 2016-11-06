# Hopper_Robot #
This repository contains code being used to run the *Hopper Robot* project in the Neuroscience and Robotics Lab at Northwestern University.

## Project Description ##
Project aims to integrate physics models and control methodologies for enhanced robotic legged locomotion on yielding terrain. Currently, robotic performace on natural substrates such as sand, snow, and grass is limited. Mechanical reactions of the earth exibit great spatial variation, imposing challenges to robotic design and control. Legged robots with greater mobility on natural terrain have applications in many areas, including: search and rescue, agricultural, planetary and space exploration, etc. The funding for this project is provided by NASA through the National Science Foundation as a part of the National Robotics Initiative.

## Apparatus ##
The apparatus for this project collects data used to characterize the material response and will be used to test controllers and designs that take advantage of these material properies.

![Overview](Images/Setup.jpeg "Apparatus image")

The apparatus consists of several components. The bed seen above is filled with a granular material (200 lbs of poppy seeds!). In order to *reset* the material between experiments, air is blown through the bottom of the bed using a blower. This air causes an increase in pressure which results in the [fluidization](https://en.wikipedia.org/wiki/Fluidization) of the material. The blower is then turned off at a fixed rate using a [variable frequency drive](https://en.wikipedia.org/wiki/Variable-frequency_drive). This allows the material to settle into a repeatable packing stage with a given packing fraction. The packing fraction is important in determining the properties of the bulk material.

![Overview](Images/Fluidizing.gif "Material Fluidization")



