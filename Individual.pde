// Individual holds the parameters, rating, parents and can draw itself 
// This is a simple template that draws a based on random numbers

class Individual implements Comparable {
  float[] parameters = {};
  float rating;
  int id;
  int[] parents = {};
  
  Individual(int pid) {
    id = pid;
    
    // Each individual should define its own parameters and decide what to do with them
    // parameter 0: magnatude of wave
    // parameter 1: wavelength of wave
    // parameter 2: magnatideModulationMagnatude
    // parameter 3: magnatideModulationWavelength
    // parameter 4: magnatideModulationMagnatude2
    // parameter 5: magnatideModulationWavelength2
    // parameter 6: numberWaves
    // parameter 7: numberOfModulations
    
    parameters = new float[8];
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
    int wavelength = (int)(parameters[1] * 1000);
    
    int magnatideModulationWavelength = (int)(parameters[3] * 1000);
    int magnatideModulationWavelength2 = (int)(parameters[5] * 1000);
    
    int numberWave = (int)(200*parameters[6]);
    float curveSegments = 40.0;
    
    for (int x = 0; x < (numberWave*wavelength); x+=(wavelength/curveSegments)) {
      //for (int j = 0; j <= curveSegments; j++) {
        //int x = (i * wavelength) + (int)(j*(wavelength/curveSegments));
        
        int magnatideModulationY = (int)(parameters[2] * 250 * sin( ((x % (float)magnatideModulationWavelength) / magnatideModulationWavelength) * TWO_PI));
        if (parameters[7] <.5){
          magnatideModulationY += (int)(parameters[4] * 150 * sin( ((x % (float)magnatideModulationWavelength2) / magnatideModulationWavelength2) * TWO_PI));
        }
        int y = 350 - (int)(parameters[0]*250*sin(((x%(float)wavelength)/wavelength)*TWO_PI)) + magnatideModulationY;
        canvas.movePen(x, y);
      //}
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
