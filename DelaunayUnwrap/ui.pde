// create the user interface elements

void initUI() {
  ui=new ControlP5(this);
  ui.addButton("stateDots", 0, 20, 20, 100, 20).setLabel("add dots");
  ui.addButton("stateTri", 1, 140, 20, 100, 20).setLabel("paint triangles");
  ui.addButton("state3D", 2, 260, 20, 100, 20).setLabel("Create 3D");
  ui.addButton("stateExport", 3, 380, 20, 100, 20).setLabel("Unwrap");
  ui.addButton("doLoadImage", 1, 700, 20, 100, 20).setLabel("Load Image");
  ui.addSlider("colorBlend", 0.0, 1.0, colorBlend, 500, 20, 100, 20).setLabel("color fade");
  ui.addSlider("targetZoom", 1, 4, targetZoom, 500, 50, 100, 20).setLabel("zoom");
  ui.addToggle("useMaterial", useMaterial, 20, 50, 20, 20).setLabel("use materials");
  ui.addToggle("showTriangleIDs", showTriangleIDs, 140, 50, 20, 20).setLabel("show id");
  ui.addButton("doExport", 1, 380, 50, 100, 20).setLabel("Export!!!");
  ui.addButton("doLoadProject", 1, 820, 20, 100, 20).setLabel("Load Project");
  ui.addButton("doSaveProject", 1, 820, 50, 100, 20).setLabel("Save Project");
  ui.addButton("saveHiRes2D", 1, 700, 50, 100, 20).setLabel("Save Hi-res");
}

// generic GUI event listener, called each time a GUI element has been triggered/modified
void controlEvent(ControlEvent e) {
  if (e.controller().name().indexOf("state")!=-1) {
    setAppState((int)e.controller().value());
  } 
  else {
    if (e.controller().name().equals("colorBlend")) {
      updateTriangleColors();
    }
  }
}

