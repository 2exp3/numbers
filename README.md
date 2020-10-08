# Numerosity comparison task in Shiny
 This is a "mock" version of the app used in our online study (arXiv), without the consent and the debrief text and with only 4 experimental trials. 
 For a quick peep at the app, go to https://agusps.shinyapps.io/numeros/. Otherwise, you may clone this repo and run it locally.
 As we run our study in Argentina, most of the displayed text is in Spanish.
 
 ## The why
 Shiny is a powerful yet straight-forward package for the design and development of online interactive tools (apps). As it is most famous for interactive data-viz apps, its power as an experimental-psychology tool has not yet been fully harnessed.
 As online experiments are becoming an increasingly relevant tool for cognitive psychology studies, we sought to understand whether we could reproduce a well-validated cognitive effect -the distance effect in number comparisons- in an online study using Shiny. This effect is inferred from Response Time (RT) to the comparison of several target numbers to a standard (65 in our study). Thus reliable timing is paramount to detect this effect.
 
 ## The task
 The task was adapted from Dehaene, S., Dupoux, E., & Mehler, J. (1990). Is numerical comparison digital? Analogical and symbolic effects in two-digit number comparison. Journal of experimental Psychology: Human Perception and performance, 16(3), 626.
 
 ## The code
 We used ShinyPsych (https://rdrr.io/github/ndphillips/ShinyPsych/) as the backbone for the app, but customized several components. 
 More importantly, we addressed RT collection using JavaScript functions (trial.js in www/). 
 Although R scripts are thoroughly annotated, we did not intend to provide a flexible and general tool, rather a well-functioning and reliable app for this specific task. That said, it is fairly straight-forward to adapt it to any other 2-alternative forced choice experimental paradigm.
 

