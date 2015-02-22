// Generation builds individuals, orders them based on fitness and coordinates breeding
import java.util.Arrays;
import controlP5.*;

class Generation {
  
  Individual [] individuals = {};// an array of generations
  float mutationProbability;
  float crossoverProbability;
  float[] targetParameters;
  EggbotCanvas printCanvas;
  EggbotCanvas [] individualCanvases = {};
  PApplet parent;
  
  Generation(PApplet p, int numIndividuals, float mp, float cp, float[] tp, EggbotCanvas pc, EggbotCanvas [] ic) {
    parent = p;
    mutationProbability = mp;
    crossoverProbability = cp;
    targetParameters = tp;
    printCanvas = pc;
    individualCanvases = ic;
    
    // Build array of individuals based on parameters
    
    for (int i=0; i< numIndividuals; i++){
      
     
      individuals = (Individual []) append(individuals, new Individual(targetParameters.length, i) );
    }
  }
  
  void evaluate() {
    for (int i = 0; i < individuals.length; i++) {
      individuals[i].calculateFitness(targetParameters);
    }
    
    // sort by fitness
    Arrays.sort(individuals);
  }
  
  Individual getFittest(){
    // in case it has not already been called, go ahead and force evaluate
    evaluate();
    
    return individuals[individuals.length-1];
  }
  
  void evolve(Generation parent) {
    int firstQuartile = (int)individuals.length/4;
    int secondQuartile = (int)individuals.length/2;
    int thirdQuartile = (int)individuals.length-individuals.length/4;
  
    for (int i=0; i< individuals.length; i++){
      // pick the individuals to clone from the parent
      // For now use quartiles of based on the rank ordering, I don't see a need to normalize and bucket base on the values. Might later learn that a better sampling exists?
    
      float spin = random(1);
      int pick;
      //println (individuals[i]+":"+spin);
      if (spin <= .1){
        // 10% of time pick lower 25% of the
        pick = int(random(0,firstQuartile));
      } else if (spin <= .3) {
        // 20% if the time pick from the second quartile
        pick = int(random(firstQuartile, secondQuartile));
      } else if (spin <= .6) {
        // 30% of the time pick from the third quartile
        pick = int(random(secondQuartile, thirdQuartile));
      } else {
        // 40% of the time pick from the top quartile
        pick = int(random(thirdQuartile, individuals.length));
      }
      individuals[i] = parent.individuals[pick].clone();
      individuals[i].id = i;
      // record the parent id
      individuals[i].parents = append(individuals[i].parents, pick);
    }
    
    // loop through two at a time and based on probability, do the crossover
    for (int i=0; i< individuals.length; i=i+2){
      if (random(1) <= crossoverProbability){
        int crossoverPoint = (int) random(1, individuals[i].parameters.length);
        for (int p=0; p<crossoverPoint; p++){
          float tempParameter = individuals[i+1].parameters[p];
          
          individuals[i+1].parameters[p] = individuals[i].parameters[p];
          
          individuals[i].parameters[p] = tempParameter;
        }
        // record the second parent id
        individuals[i+1].parents = append(individuals[i+1].parents, individuals[i].parents[0]);
        individuals[i].parents = append(individuals[i].parents, individuals[i+1].parents[0]);
      } 
    }
    
    for (int i = 0; i < individuals.length; i++) {
      individuals[i].mutate(mutationProbability);
    }
  }
  
  void print(int individual){
    individuals[individual].draw(printCanvas);
  }
  
  void rate(int individual, float rating){
    individuals[individual].rate(rating);
  }
  
  void draw(int vOffset){
    translate(20, 20);
    for (int i=0; i< individuals.length; i++){
      individualCanvases[i].drawBackground();
      individuals[i].draw(individualCanvases[i]);
      
      cp5.get("print " + i)
       .setPosition(830,240*i+175+vOffset)
       ;
      
      cp5.get("rating " + i)
        .setPosition(830,240*i+20+vOffset)
        ;
        
      translate(0, 240);
    }
    translate(-20, -240*individuals.length-20);
  }
  
  String output(){
    String output = "";
    for (int i = 0; i < individuals.length; i++) {
      output += "Individual "+ i +": ";
      output += individuals[i].output();
    }
    return output;
  }

}
