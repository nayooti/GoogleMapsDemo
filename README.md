# GoogleMapsDemo

This project demonstrates a crash when assiging a map to GMSPolyline due to memory issues.
The crash only happens after the polyline covers a certain distance. 

#### How to reproduce:
1. in MapController set your API key
2. run the app on a real device (running the app on a simulator can crash your machine)
  - the app tries to draw a polyline from Berlin to Munich and crashes due to memory isues
3. in MapController+viewDidAppear change the polyline from Berlin to Potsdam (short distance)
  - the does no longer crash

    

    
  

