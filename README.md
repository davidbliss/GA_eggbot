# GA_eggbot

An implementation of a Genetic Algorithm using multiple float parameters in place of a string of characters. Fitness is based on a user rating between 0 and 1.

![Image](https://github.com/davidbliss/GA_eggbot/blob/master/images/interface.png?raw=true)

To use, rate each individual in a generation. A higher rating increases the probability of inclusion in the next generation, but does not guarantee it. Any individual with a rating of 0 will not be eligable for advancement.
After all individuals are rated, click the evolve button to proceed to the next generation. Evolution selects individuals to proceed and which of those individuals to crossover. The crossover process involves exchanging values for a subset of parameters. 

The lineage button will show the highest rated parent of each previous generation.'

![Image](https://github.com/davidbliss/GA_eggbot/blob/master/images/generations3-5.png?raw=true)
_Generations 5, 4 and 3 (from top to bottom) of a particular design._

![Image](https://github.com/davidbliss/GA_eggbot/blob/master/images/generations1-3.png?raw=true)
_Generations 3, 2 and 1 (from top to bottom) of a particular design._

The print button will send the design to an http://egg-bot.com/ printer if attached.

To evovle your own designs, edit the Individual.pde file.
