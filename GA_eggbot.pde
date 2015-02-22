import controlP5.*;
ControlP5 cp5;

Generation [] generations; // an array of generations

int numIndividuals = 20; // number must be even
float mutationPropability = .01; // likely target should be 1% of the time
float crossoverProbability = .75; // likely target should be 75% of the time

int windowWidth = 1001;
int windowHeight = 801;
int windowCanvasHeight = numIndividuals * 240 + 20; // raw eggbot canvas is 175
int vOffset = 0;

int displayMode = 0; // 0 = generations; 1 = lineage

EggbotCanvas printCanvas;
EggbotCanvas [] individualCanvases = {};

void setup() {
  cp5 = new ControlP5(this);
  
  // set up one eggbot canvas to use for the actual plotting, pass it to each generation so it can be passed onto the individuals
  printCanvas = new EggbotCanvas(this, true);
  printCanvas.penUp(true);
  printCanvas.movePen(0, 0);
  
  size(windowWidth, windowHeight);
  
  generations = new Generation [1];
  
  cp5.addButton("mutate")
     .setPosition(10,windowHeight-30)
     ;
     
  cp5.addButton("lineage")
     .setPosition(90,windowHeight-30)
     ;
  
  cp5.addButton("generations")
     .setPosition(170,windowHeight-30)
     ;
  
  
  cp5.addSlider("scroll")
     .setPosition(985,5)
     .setBroadcast(false)
     .setSize(10,790)
     .setRange(0,100)
     .setValue(100)
     .setLabelVisible(false) 
     .setBroadcast(true)
     ;
    
  for (int i=0; i<numIndividuals; i++){
    cp5.addButton("print " + i)
      .setPosition(820,240*i+20)
    ;
     
    cp5.addSlider("rating " + i)
     .setBroadcast(false)
     .setPosition(830,240*i+50)
     .setRange(0,1)
     .setNumberOfTickMarks(6)
     .setBroadcast(true)
     ;
     
     EggbotCanvas canvas = new EggbotCanvas(this, false);
     canvas.penUp(true);
     canvas.movePen(0, 0);
     canvas.penUp(false);
     individualCanvases = (EggbotCanvas[]) append(individualCanvases, canvas);
  }
  
  // create and evaluate initial generation
  generations[0] = new Generation(this, numIndividuals, mutationPropability, crossoverProbability, printCanvas, individualCanvases);
  generations[0].evaluate();
  getFittest();
  
  manualDraw();
}

void draw() {
}

void manualDraw() {
  translate(0, vOffset);
  background(200);
  
  if (displayMode==0){
    // draw grid of the lastest generation
    generations[generations.length-1].draw(vOffset);
    
  } else if (displayMode==1){
    // draw lineage of fittest individual
    // TODO: fix bug arrising from the fact that currently if number of generations is greater than number of individuals, there will not be enough canvases for the lineage
    
    int canvasIndex = 0;
    translate(20, 20);
    
    // draw the fittest individual in the latest generation
    Individual fittest = generations[generations.length-1].getFittest();
    individualCanvases[canvasIndex].drawBackground();
    fittest.draw(individualCanvases[canvasIndex]);
    canvasIndex++;
    translate(0, 240);
    
    // loop through generations from 2nd to latest down to first, drawing the graph of the fittest parent of fittest
    for (int i = generations.length-2; i>=0; i--){
      
      if (fittest.parents.length == 2){
        if (generations[i].individuals[fittest.parents[0]].rating < generations[i].individuals[fittest.parents[1]].rating){
          fittest=generations[i].individuals[fittest.parents[1]];
        } else {
          fittest=generations[i].individuals[fittest.parents[0]];
        }
      } else {
        fittest=generations[i].individuals[fittest.parents[0]];
      }
      
      individualCanvases[canvasIndex].drawBackground();
      fittest.draw(individualCanvases[canvasIndex]);
      
      canvasIndex++;
      translate(0, 240);
    }
    
    for (int i = 0; i<numIndividuals; i++){
       cp5.get("print " + i)
       .setPosition(-2000, -2000)
       ;
      
      cp5.get("rating " + i)
        .setPosition(-2000, -2000)
        ;
    }
    translate(-20, -240*generations.length-20);
  }
  translate(0, -vOffset);
}

void mouseWheel(MouseEvent event) {
  // possitive vOffset moves the drawing down the screen
  vOffset -= (int) event.getCount();
  vOffset = max(min(vOffset, 0), -windowCanvasHeight+windowHeight);
  
  cp5.get("scroll").setValue(map(vOffset, -windowCanvasHeight+windowHeight, 0, 0, 100));
}

void mutate(){
  Individual fittest = getFittest();
  println("making a new generation");
  // create a new generation 
  generations = (Generation[]) append (generations, new Generation(this, numIndividuals, mutationPropability, crossoverProbability, printCanvas, individualCanvases));
  
  // evolve latest generation based on previous generation
  generations[generations.length-1].evolve(generations[generations.length-2]);
  
  

}

void generations(){
  displayMode = 0;
  vOffset = 0;
}

void lineage(){
  displayMode = 1;
  vOffset = 0;
}

void controlEvent(ControlEvent theEvent){
  // Handle events from the print buttons
  String name = theEvent.controller().name();
  
  if (name.indexOf("rating")>-1) {
    generations[generations.length-1].rate(Integer.valueOf(name.substring(7, name.length())),theEvent.controller().value()); 
  } else if (name.indexOf("print")>-1) { 
    generations[generations.length-1].print(Integer.valueOf(name.substring(6, name.length())));
  } else if (name.indexOf("scroll")>-1) { 
    // scroll value between 0 and 1 translat between 0 and -windowCanvasHeight+windowHeight
    float m = map(theEvent.controller().value(), 100, 0, 0, -windowCanvasHeight+windowHeight);
    vOffset = int(m);
  }
  
  manualDraw();
  
}

Individual getFittest(){
  // get the fittest
  Individual fittest = generations[generations.length-1].getFittest();
  println("fittest individual in generation "+ generations.length +" is " + fittest.rating);
  return fittest;
}

void output(){
  //TODO: create a more export friendly format (Json or CSV)
  println("output:");
  String output="";
  for (int i = 0; i < generations.length; i++) {
    output += "Generation:"+ i +"\n";
    output += generations[i].output();
  }
  println(output);
}

