// Individual holds the parameters, defines it's fitness and can draw itself 

class Individual implements Comparable {
  float[] parameters = {};
  float fitness;
  float rating;
  int id;
  int[] parents = {};
  
  Individual(int numParameters, int pid) {
    // build array of random parameters
    id = pid;
    
    parameters = new float[numParameters];
    for (int i = 0; i < parameters.length; i++) {
      parameters[i] = random(1);
    }
    
    // TODO: once drawing and rating is in place, each individual will define it's own parameters and how to initialize each one
    // Parameters can be anything, most will likely be float between 0-1 or int between 0 and n (for classification type parameters)
    
  }
  
  void mutate(float probability){
    // mutation is a gausian perterbation/nudge 
    for (int i = 0; i < parameters.length; i++) {
      if (random(1) < probability){
        parameters[i] = min(max(parameters[i]+(randomGaussian()/4),0),1);
      }
    }
  }
  
  void calculateFitness(float[] targetParameters) {
    // TODO: fitness will be defined based on the rating not based on the parameters.
    // full fitness is 1
    
    fitness = 0;
    
    for (int i = 0; i < parameters.length; i++) {
      fitness += abs(parameters[i] - targetParameters[i]);
    }
    fitness /= parameters.length;
    fitness = 1 - fitness;
  }
  
  void draw(EggbotCanvas canvas){
    // draw itself to the specified canvas
    canvas.setPen(3);
    canvas.penUp(true);
    canvas.movePen(0, 350);
    canvas.penUp(false);
    canvas.movePen(2000, 350);
    
    canvas.penUp(true);
    canvas.movePen(0, 350);
    canvas.penUp(false);
    
    canvas.setPen(1);
    
    int numParameters = parameters.length;
    for (int i = 0; i < numParameters; i++) {
      canvas.movePen(i*(2000/(numParameters-1)), int(parameters[i]*700));
    }
  }
  
  void rate(float r){
    rating = r;
  }
  
  Individual clone(){
    Individual copy = new Individual(parameters.length, -1);
    for (int i=0; i< parameters.length; i++){
      copy.parameters[i] = parameters[i];
    }
    return copy;
  }
  
  // used by Arrays to do sort
  int compareTo(Object obj) {
    Individual other = (Individual) obj;
    if (fitness > other.fitness) {
      return 1;
    }
    else if (fitness < other.fitness) {
      return -1;
    }
    return 0;
  }
  
  String output(){
    String output = "fitness:"+fitness+" parameters:";
    for (int i = 0; i < parameters.length; i++) {
      output += parameters[i];
      if (i < parameters.length-1) output += ", ";
    }
    output += "\n";
    return output;
  }
}
