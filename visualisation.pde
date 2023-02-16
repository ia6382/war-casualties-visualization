import java.util.*; 

Table data;

//estimated population in millions {year, number}
int [][] population = {{1400, 400}, {1500, 458}, {1600, 580}, {1700, 682}, {1750, 791}, {1800, 1000}, {1850, 1262}, {1900, 1650}, 
  {1950, 2525}, {1955, 2758}, {1960, 3018}, {1965, 3322}, {1970, 3682}, {1975, 4061}, {1980, 4440}, {1985, 4853}, 
  {1990, 5310}, {1995, 5735}, {2000, 6127}, {2005, 6520}
};

ArrayList<War> warsOfTheYear;
ArrayList<War> warsOfTheGroup;

int minYear;
int maxYear;
float minPercent;
float maxPercent;

PFont regular;
PFont bold;
float px1, px2, py1, py2;
int xInterval = 100;
float yInterval = 0.5;

int mouseYear = 0;
int yearGroup = 1;
int [] yearZoom = {1, 5, 10, 100};

float prevX = 0;

float currXforWin;
float prevXforWin;
float winWidth = 450;
float winHeight = 190;

void setup() { 
  size(1000, 800);
  surface.setResizable(true);

  //get parsed data
  data = loadData();

  //min and max values
  minYear = data.getRow(0).getInt("StartYear");
  maxYear = 2000;
  minPercent = 0;
  maxPercent = 2;

  //create fonts
  regular = createFont("Lato-Regular.ttf", 20, true); 
  //textFont(regular, 20); 
  smooth();
  
  bold = createFont("Lato-Bold.ttf", 20, true); 
  //textFont(bold, 20); 
  smooth();
  
  warsOfTheYear = new ArrayList();
}


void draw() {
  setUI();

  mouseYear = locateClosestYear();
  drawData(); 
  drawTitle("Casulties of conflicts for "+yearGroup+" years");
  drawXLabels();
  drawYLabels();
  drawAxisLabels("Percent of world\npopulation that\ndied", "Year");
  
  if(mouseYear != 0){
    displayWindow(3);
  }
}

void setUI(){
  //reset previous frame drawings
  background(200);
  
  // Corners of the plotted time series 
  px1 = 155;
  py1 = 60; 
  px2 = width - py1; 
  py2 = height - py1;
  prevX = px1;

  // Show the plot area as a white box 
  fill(255); 
  rectMode(CORNERS); 
  noStroke(); 
  rect(px1, py1, px2, py2);
  
  //resize window
  size(width, height);
}

int locateClosestYear(){
  //get the year of the mouse position
  int x;
  if(mouseX >= px1 && mouseX <= px2){
    x = (int)map(mouseX, px1,  px2, minYear, maxYear);
    
    //find the correct yearGroup
    if(yearGroup > 1){ //if it is 1 we already have the correct yearGroup = no group
      for(int i = minYear+yearGroup; i <= maxYear; i += yearGroup){
        if(i >= x){
          x = i;
          break;
        }
      }
    }
    
  }
  else{
    x = 0;
  }
  
  return x;
}

void displayWindow(int topWarsN){
  //sort the list
  
  for(int i = 0; i < warsOfTheGroup.size(); i ++){
    War war = warsOfTheGroup.get(i);
    war.casultiesForGroupYear(yearGroup, mouseYear);
  }
  
  Collections.sort(warsOfTheGroup, new SortByCasultiesGroup());
  int population = getWorldPop(mouseYear);
  
  //pop up window
  //determine position of window
  float x;
  float y = py1;
  if(currXforWin + winWidth <= px2){
    x = currXforWin;
  }
  else{
    x = prevXforWin - winWidth;
  }
  
  strokeWeight(1); 
  //stroke(150, 31, 0);
  stroke(0);
  fill(220);
  rectMode(CORNER);
  rect(x, y, winWidth, winHeight);
  
  //display the n top wars, if there are so many
  if(warsOfTheGroup.size() < topWarsN){
   topWarsN = warsOfTheGroup.size();
  }
  
  if(topWarsN == 0){
    textFont(bold, 15); 
    fill(0);
    textAlign(LEFT);
    text("No recorded conflicts for the years: "+ (mouseYear-yearGroup) +" - "+ mouseYear, x+5, y+20);
    return;
  }
  
  //write the information
  textFont(bold, 15); 
  fill(0);
  textAlign(LEFT);
  text("Top "+topWarsN+" biggest conflicts of years "+ (mouseYear-yearGroup) +" - "+ mouseYear +": ", x+5, y+20);
  //int tmp = 0;
  for(int i = 0; i < topWarsN; i ++){
      War war = warsOfTheGroup.get(i);
      int casulties = war.casultiesInGroupYear;
      float percentage = war.returnPercent(population);
      String detailedName = war.name;
      String name;
      
      if(war.commonName.equals("")){
        name = "Unnamed conflict";
      }
      else{
        name = war.commonName;
      }
      
      float offsetY = 50*(i+1);
      textFont(regular, 15); 
      fill(0);
      textAlign(LEFT);
      text("- "+name, x+5, y+offsetY);
      
      offsetY += 15;
      textFont(regular, 12); 
      fill(0);
      textAlign(LEFT);
      text("   "+detailedName, x+5, y+offsetY);
      
      offsetY += 12;
      text("   casulties: "+nfc(casulties)+"  ("+nf(percentage, 1, 2)+"% of world population)", x+5, y+offsetY);
      //tmp += casulties;
  }
  //println(tmp);
}

void drawAxisLabels(String yTitle, String xTitle) {
  textFont(bold, 15); 
  fill(0);
  textLeading(15);

  textAlign(LEFT, CENTER);
  text(yTitle, 0+10, (py1+py2)/2);
  textAlign(CENTER);
  text(xTitle, (px1+px2)/2, py2+40);
}

void drawTitle(String title) {
  textFont(bold, 20); 
  fill(0); 
  textAlign(CENTER);
  text(title, (px1+px2)/2, 0 + 40);
}

void drawYLabels() {
  textFont(regular, 10); 
  fill(0);
  textAlign(RIGHT);

  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);

  for (float i = minPercent; i <= maxPercent; i+=yInterval) {
    float y = map(i, minPercent, maxPercent, py2, py1);
    String s = nf(i, 1, 2);
    text(s, px1-5, y);
  }
}

void drawXLabels() {
  textFont(regular, 10); 
  fill(0);
  textAlign(CENTER, TOP);


  for (int i = 0; i <= maxYear-minYear+1; i++) {
    if (i % xInterval == 0) {
      float x = map(i+minYear, minYear, maxYear, px1, px2); 
      text(i+minYear, x, py2 + 5);
    }
  }
}

void drawData() {
  warsOfTheYear.clear();
  int groupCasulties = 0;

  for (int i = minYear; i <= maxYear; i++) {
    int casultiesCounter = 0;

    //check if some of the wars have ended this year
    if (warsOfTheYear.size() != 0) {
      for (int j = warsOfTheYear.size()-1; j >= 0; j --) {
        War oldWar = warsOfTheYear.get(j);

        if ((oldWar.startYear + oldWar.duration) < i) {
          warsOfTheYear.remove(j);
        } else {
          casultiesCounter += oldWar.casultiesPerYear;
        }
      }
    }

    //initialize the warsOfTheGroup list with current wars on the year yearGroup started
    if(mouseYear != 0 && i == mouseYear - yearGroup + 1){
      warsOfTheGroup = new ArrayList<War>(warsOfTheYear);
    }

    //add wars that started this year (i) to the list
    for (TableRow row : data.findRows(Integer.toString(i), "StartYear")) {
      War newWar = new War(row.getString("Name"), row.getInt("StartYear"), row.getInt("DurationY"), row.getInt("TotalFatalities"), yearGroup, mouseYear);
      String commonName = row.getString("Common Name");
      if(!commonName.equals("")){
        newWar.commonName = commonName;
      }
      warsOfTheYear.add(newWar);

      casultiesCounter += newWar.casultiesPerYear;
      
      //if a war started in the yearGroup add it to the list warsOfTheGroup
      if(mouseYear != 0 && i > mouseYear - yearGroup && i <= mouseYear){
        warsOfTheGroup.add(newWar);
      }
    }

    if (i % yearGroup == 0 && i != minYear) {
      groupCasulties += casultiesCounter;

      //get currentWorldPopultaion
      int currWorldPop = getWorldPop(i);

      //plot
      float percentage = (float)groupCasulties / (float)currWorldPop;
      //if(mouseYear != 0 && i == mouseYear){println("Year: "+i+", casulties: "+groupCasulties+" pop: "+currWorldPop+" percent: "+percentage);}

      float x = map(i, minYear, maxYear, px1, px2); 
      float y = map(percentage, minPercent, maxPercent, py2, py1);
      
      if(percentage > 0){
        noStroke();
        fill(80, 80, 80);
        rectMode(CORNERS);
      }
      else{
        noStroke();
        fill(27, 143, 52);
        rectMode(CORNERS);
      }
      
      if(i == mouseYear-yearGroup){
        prevXforWin = x;
      }
      else if(i == mouseYear){
        fill(150, 31, 0);
        currXforWin = x;
      }
      rect(prevX, y, x, py2);
      prevX = x;
      

      groupCasulties = 0;
    } 
    else {
      groupCasulties += casultiesCounter;
    }
  }
}

int getWorldPop(int year){
  //za velika stevila int ne deluje, zato sem ze delil z 100 populacijo. Kasneje ne bo treba pri procentih
  int currWorldPop = 0;
  for (int j = 0; j < population.length; j++) {
    if (population[j][0] > year) {
      currWorldPop = population[j-1][1] * 10000;
      break;
    }
  }
  return currWorldPop;
}

Table loadData() {
  // "header" indicates the file has header row. The size of the array 
  // is then determined by the number of rows in the table. 
  Table data = loadTable("conflictsComma.csv", "header");

  //filter rows with no fatalities data
  for (int i = data.getRowCount()-1; i >= 0; i--) {
    // Iterate over all the rows in a table.
    TableRow row = data.getRow(i);

    if (row.getString("TotalFatalities").equals("")) {
      data.removeRow(i);
    }
  }
  //saveTable(data, "data/new.csv");
  return data;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0){
    for(int i = 0; i < yearZoom.length-1; i++){
      if(yearGroup == yearZoom[i]){
        yearGroup = yearZoom[i+1];
        break;
      }
    }
  }
  else{
    for(int i = 1; i < yearZoom.length; i++){
      if(yearGroup == yearZoom[i]){
        yearGroup = yearZoom[i-1];
        break;
      }
    }
  }
}
