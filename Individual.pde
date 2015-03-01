// Individual holds the parameters, rating, parents and can draw itself 
// This is a simple template that draws a based on random numbers

class Individual implements Comparable {
  float[] parameters = {};
  float rating;
  int id;
  int[] parents = {};
  
  Individual(int pid) {
    // build array of random parameters
    id = pid;
    
    // Each individual should define its own parameters and decide what to do with them
    parameters = new float[30];
    for (int i = 0; i < parameters.length; i++) {
      parameters[i] = random(1);
    }  
  }
  
  void mutate(float probability){
    // mutation is a gausian perterbation/nudge 
    for (int i = 0; i < parameters.length; i++) {
      if (random(1) < probability){
        parameters[i] = min(max(parameters[i]+(randomGaussian()/4),0),1);
      }
    }
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
    Individual copy = new Individual(-1);
    for (int i=0; i< parameters.length; i++){
      copy.parameters[i] = parameters[i];
    }
    return copy;
  }
  
  // used by Arrays to do sort
  int compareTo(Object obj) {
    Individual other = (Individual) obj;
    if (rating > other.rating) {
      return 1;
    }
    else if (rating < other.rating) {
      return -1;
    }
    return 0;
  }
  
  String output(){
    // TODO: include other things like parents and ID
    String output = "ID:"+id+"\nrating:"+rating+"\nparents:";
    for (int i = 0; i < parents.length; i++) {
      output += parents[i];
      if (i < parents.length-1) output += ", ";
    }
    output += "\nparameters:";
    for (int i = 0; i < parameters.length; i++) {
      output += parameters[i];
      if (i < parameters.length-1) output += ", ";
    }
    output += "\n";
    return output;
  }
}
