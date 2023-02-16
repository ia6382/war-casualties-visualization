class War{
  String commonName;
  String name;
  int startYear;
  int duration;
  int casultiesPerYear;
  int casultiesInGroupYear;

  War(String name, int startYear, int duration, int casulties, int yearGroup, int mouseYear){
    this.commonName = "";
    this.name = name;
    this.startYear = startYear;
    this.duration = duration;
    
    this.casultiesPerYear = casulties/(duration+1);
    this.casultiesInGroupYear = 0;
   }
   
   void casultiesForGroupYear(int yearGroup, int mouseYear){
     if(mouseYear != 0){
       int casulties = 0;
       for(int i = mouseYear - yearGroup + 1; i <= mouseYear; i++){
         if(i >= startYear && i <= startYear+duration){
           casulties += casultiesPerYear;
         }
       }
       casultiesInGroupYear = casulties;
     }
     else{
       casultiesInGroupYear = -1;
     }
     
   }
   
   float returnPercent(int currWorldPop){
     float percentage = (float)casultiesInGroupYear / (float)currWorldPop;
     return percentage;
   }
   
}

class SortByCasultiesGroup implements Comparator<War> 
{ 
    public int compare(War a, War b) 
    { 
        return b.casultiesInGroupYear - a.casultiesInGroupYear; 
    } 
} 
