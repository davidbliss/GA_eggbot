import controlP5.*;
ControlP5 cp5;

Generation [] generations; // an array of generations

int numIndividuals = 50; // number must be even
float mutationPropability = .04; // likely target should be 1% of the time
float crossoverProbability = .75; // likely target should be 75% of the time

int windowWidth = 1001;
int windowHeight = 801;
int windowCanvasHeight = numIndividuals * 240 + 20; // raw eggbot canvas is 175
int vOffset = 0;

int displayMode = 0; // 0 = generations; 1 = lineage

EggbotCanvas printCanvas;
EggbotCanvas [] individualCanvases = {};

Individual [] lineage = {}; // an array of individuals 

void setup() {
  size(1001, 801);
  cp5 = new ControlP5(this);
  
  // set up one eggbot canvas to use for the actual plotting, pass it to each generation so it can be passed onto the individuals
  printCanvas = new EggbotCanvas(this, true);
  printCanvas.penUp(true);
  
  
  generations = new Generation [1];
  
  cp5.addButton("back")
     .setPosition(-2000,-2000)
     ;
     
  cp5.addButton("evolve")
     .setPosition(10,windowHeight-30)
     ;
  
  cp5.addButton("output")
     .setPosition(90,windowHeight-30)
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
    cp5.addButton("lineage " + i)
      .setPosition(820,240*i+20)
    ;
    
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
  
  // create initial generation
  generations[0] = new Generation(this, numIndividuals, mutationPropability, crossoverProbability, printCanvas, individualCanvases);
  
  // set UI to show generations
  generations();
  
  // draw things
  manualDraw();
}

void draw() {
  // don't update anything automatically
}

void manualDraw() {
  // called after an interaction with UI
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
    
    // draw individuals in the lineage array
    for (int i = 0; i<lineage.length; i++){
      
      individualCanvases[canvasIndex].drawBackground();
      lineage[i].draw(individualCanvases[canvasIndex]);
      
      canvasIndex++;
      translate(0, 240);
    }
    
    for (int i = 0; i<numIndividuals; i++){
      cp5.get("lineage " + i)
       .setPosition(-2000, -2000)
       ;
      
      if (i<lineage.length){
        cp5.get("print " + i)
         .setPosition(830,240*i+175+vOffset)
         ;
      } else {
        cp5.get("print " + i)
          .setPosition(-2000, -2000)
          ;
      }
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
  vOffset -= (int) event.getCount() * 10;
  vOffset = max(min(vOffset, 0), -windowCanvasHeight+windowHeight);
  cp5.get("scroll").setValue(map(vOffset, -windowCanvasHeight+windowHeight, 0, 0, 100));
}

void evolve(){
  // create a new generation 
  generations = (Generation[]) append (generations, new Generation(this, numIndividuals, mutationPropability, crossoverProbability, printCanvas, individualCanvases));
  
  // evolve latest generation based on previous generation
  generations[generations.length-1].evolve(generations[generations.length-2]);
  
  //reset values in rating UI.
  for (int i = 0; i<numIndividuals; i++){
    cp5.get("rating " + i)
      .setValue(0)
      ;
  }
}

void generations(){
  displayMode = 0;
  vOffset = 0;
  // set up generation ui
  cp5.get("back")
    .setPosition(-2000,-2000)
    ;
    
  cp5.get("evolve")
    .setPosition(10,height-30)
    ;
      
  cp5.get("output")
    .setPosition(90,height-30)
    ;    
}

void lineage(int individualIndex){
  displayMode = 1;
  vOffset = 0;
  
  // build lineage array
  lineage = (Individual[]) subset(lineage, 0, 0);
  Individual individual = generations[generations.length-1].individuals[individualIndex];
  lineage = (Individual []) append(lineage, individual );
 
  // loop through generations from 2nd to latest down to first, drawing the graph of the fittest parent of fittest
  for (int i = generations.length-2; i>=0; i--){
    
    if (individual.parents.length == 2){
      if (generations[i].individuals[individual.parents[0]].rating < generations[i].individuals[individual.parents[1]].rating){
        individual = generations[i].individuals[individual.parents[1]];
        lineage = (Individual []) append(lineage, individual);
      } else {
        individual = generations[i].individuals[individual.parents[0]];
        lineage = (Individual []) append(lineage, individual);
      }
    } else {
      individual = generations[i].individuals[individual.parents[0]];
      lineage = (Individual []) append(lineage, individual);
    }
  }
  
  // set up lineage ui
  cp5.get("back")
    .setPosition(10,height-30)
    ;
    
  cp5.get("evolve")
    .setPosition(-2000,-2000)
    ;
      
  cp5.get("output")
    .setPosition(-2000,-2000)
    ;
}


void back(){
  // return to generations from lineage
  generations();
}

void controlEvent(ControlEvent theEvent){
  // Handle events from UI
  String name = theEvent.getController().getName();
  
  if (name.indexOf("rating")>-1) {
    generations[generations.length-1].rate(Integer.valueOf(name.substring(7, name.length())),theEvent.getController().getValue()); 
  } else if (name.indexOf("print")>-1) { 
    if (displayMode ==0){
      // generation mode
      generations[generations.length-1].print(Integer.valueOf(name.substring(6, name.length())));
    } else if (displayMode ==1){
      // lineage mode
      lineage[Integer.valueOf(name.substring(6, name.length()))].draw(printCanvas);
    }
  } else if (name.indexOf("lineage")>-1) { 
    lineage(Integer.valueOf(name.substring(8, name.length())));
  } else if (name.indexOf("scroll")>-1) { 
    // scroll value between 0 and 1 translat between 0 and -windowCanvasHeight+windowHeight
    float m = map(theEvent.getController().getValue(), 100, 0, 0, -windowCanvasHeight+windowHeight);
    vOffset = int(m);
  }
  
  manualDraw();
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