# Number comparison task in Shiny
This is a demo version of the app used in our [study](https://psyarxiv.com/nuxdg), without the consent and the debrief text and set to 4 experimental trials only (you may change that by setting `ntr` to any other value between 1 and 116, or comment that line of code to run the full version). 
To try the app, go to https://2exp3.shinyapps.io/numbers/. Otherwise, you may download/clone this repo and run it locally.
Naturally, as we ran our study in Argentina, most of the displayed text is in Spanish.
 
 ## The why
Shiny is a powerful yet straight-forward package for the design and development of online interactive tools (apps). It is most famous for interactive data-viz apps and its power as an experimental-psychology tool has yet to be fully harnessed.
As online experiments are becoming an increasingly relevant tool for cognitive psychology studies, we sought to understand whether we could reproduce a well-validated cognitive effect -the distance effect in number comparisons- in an online study using Shiny. This effect is inferred from Response Time (RT) to the comparison of several target numbers to a standard (65 in our study). Thus, reliable timing is paramount to detect this effect.
 
 ## The task
The task was adapted from [Dehaene, S., Dupoux, E., & Mehler, J. (1990)](https://psycnet.apa.org/record/1991-00277-001). Is numerical comparison digital? Analogical and symbolic effects in two-digit number comparison. Journal of experimental Psychology: Human Perception and performance, 16(3), 626.
 
 ## The code
We used [ShinyPsych](https://rdrr.io/github/ndphillips/ShinyPsych/) as the backbone for the app, but customized several components. 
More importantly, we addressed RT collection using custom JavaScript functions (see [trial.js](https://github.com/2exp3/numbers/blob/main/www/trial.js)). 
Although R scripts are thoroughly annotated, we did not intend to provide a flexible and general tool, rather a well-functioning and reliable app for this specific task. That said, it is fairly straight-forward to adapt it to any other binary decision task.
 
