/**
 * <p>This project was developed during the Processing & toxiclibs workshop with 4th year
 * students at Bezalel Academy in Jerusalem, April 11-14th 2011. Stellar support & dedication
 * by: Liat, Omer, Benjamin, Oz. Super special thanks to Mushon Zer-Aviv.</p>
 *
 * <p>This workshop focused on the creation of a custom design tool which would allow us to
 * recreate loaded images as 3D cones and fabricate them in paper using a cutting plotter.
 * We used the tool to create a typographic paper sculpture and several high res prints for
 * the Bezalel gallery, documenting our workshop. This is the first time in this school's history
 * that a codebased work has been hung on the walls of this gallery...</p>
 *
 * <p>Dependencies:<ul>
 * <li>Processing 1.2.1</li>
 * <li>toxiclibs-0021 (we used a pre-release of 0021)</li>
 * <li>controlP5</li>
 * </ul></p>
 */

/* 
 * Copyright (c) 2011 Karsten Schmidt and workshop crew
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
import processing.opengl.*;
import controlP5.*;

import toxi.color.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.geom.mesh2d.*;
import toxi.math.*;
import toxi.math.conversion.*;
import toxi.processing.*;
import toxi.util.*;
import toxi.util.datatypes.*;

import java.awt.event.*;

// radius of the root triangle which encompasses (MUST) all other points
float ROOT_SIZE = 100000;

//default image settings
String DEFAULT_IMAGE="duck.jpg";
int MAX_IMG_WIDTH = 800;
int MAX_IMG_HEIGHT = 600;

// high resolution output settings
int DPI=300;
int HIRES_WIDTH = (int)UnitTranslator.millisToPixels(297,DPI);
int HIRES_HEIGHT = (int)UnitTranslator.millisToPixels(420,DPI);

// physical output settings for unwrapped shapes (in mm)
float PHYS_MAX_WIDTH=600;
float PHYS_SCALE=PHYS_MAX_WIDTH/MAX_IMG_WIDTH;
// sheet size (in mm)
Rect PHYS_SHEET_BOUNDS = new Rect(0, 0, 260, 200);

// size of glue flap (in mm)
float GLUE_FLAP=10;
float GAP=40;

// warning flag for triangle count
int TRIANGLE_LIMIT = 100;

// file extension for project files
String FILE_EXT=".unwrap";

// color palette for materials
TColor[] materialCols=new TColor[] {
  TColor.newHSV(0.1, 0.15, 0.8), 
  TColor.newRGB(0.2, 0.2, 0.2),
  TColor.newGray(1)
};

// a Voronoi diagram relies on a Delaunay triangulation behind the scenes
// we simply use this as a front end
Voronoi voronoi;

// helper class for rendering
ToxiclibsSupport gfx;

// lists to store user added points and triangles
List<ColoredTriangle> triangles=new ArrayList<ColoredTriangle>();
List<Vec2D> points=new ArrayList<Vec2D>();
int numTriangles;

// application state ID
int appState=0;

// user loaded image & file path
PImage img;
String imgPath;

// user interface
ControlP5 ui;

// impact of average color for each triangle
float colorBlend=0.8;

// switches
boolean doLoadImage=false;
boolean doExport=false;
boolean doScreenshot=false;
boolean doLoadProject=false;
boolean doSaveProject=false;
boolean useMaterial = false;
boolean showTriangleIDs=false;
boolean isWheelAttached=false;

// dxf export related tools
DXFWriter dxf;
VectorFont vfont;
Vec2D origin;

// 3D camera state variables
Vec2D currRotation=new Vec2D();
Vec2D targetRotation=new Vec2D();
float currZoom=1, targetZoom=1;

void setup() {
  size(1024, 720,OPENGL);
  smooth();
  gfx = new ToxiclibsSupport(this);
  dxf = new DXFWriter(gfx);
  vfont=new VectorFont(dxf, 5);
  origin=new Vec2D(width/2, height/2);
  initVoronoi();
  initUI();
  initMouseWheel();
}

void draw() {
  // turn on depth testing (only needed for 3D mode really)
  hint(ENABLE_DEPTH_TEST);
  // check if any of the file choosers were requested
  // due to threading issues they need to be called from within draw()
  if (doLoadImage) {
    chooseAndLoadImage();
  } 
  else if (doLoadProject) {
    loadProject();
  } 
  else if (doSaveProject) {
    saveProject();
  }
  background(208);
  // interpolate zoom factor
  currZoom+=(targetZoom-currZoom)*0.05;
  if (img!=null) {
    pushMatrix();
    // handle the different app states
    switch(appState) {
    // adding points
    case 0:
      drawDotState();
      break;
    // display 2D colored triangles
    case 1:
      drawTriangleState();
      break;
    // display 3D mesh
    case 2:
      draw3D();
      break;
    // display unwrapped shapes
    case 3:
      drawUnrwapped();
      break;
    }
    popMatrix();
    // check if we need to save screenshot
    // images are saved in the th "export" subfolder of the sketch
    if (doScreenshot) {
      saveFrame("export/unwrap-"+DateUtils.timeStamp()+".png");
      doScreenshot=false;
    }
    // display triangle count
    if (numTriangles>TRIANGLE_LIMIT) {
      fill(255, 0, 0);
    } else {
      fill(255);
    }
    text("triangles: "+numTriangles, 20, height-20);
  }
  // disable depth buffer in order to force the UI is always drawn on top
  noLights();
  hint(DISABLE_DEPTH_TEST);
  fill(0,100);
  rect(0,0,width,100);
}

void mousePressed() {
  if (img!=null) {
    Vec2D mousePos=new Vec2D(mouseX, mouseY).sub(origin).scale(1.0/currZoom);
    switch(appState) {
      case 0:
        if (mouseY>100) {
          Rect imgBounds=new Rect(-img.width/2, -img.height/2, img.width, img.height);
          if (imgBounds.containsPoint(mousePos)) {
            if (mouseButton==LEFT) {
              voronoi.addPoint(mousePos);
              points.add(mousePos);
              updateTriangleCount();
            } 
            else {
              // Right button to remove point
              // find closest point
              for (Iterator<Vec2D> i=points.iterator(); i.hasNext();) {
                Vec2D p=i.next();
                if (p.distanceTo(mousePos)<10) {
                  i.remove();
                  voronoi = new Voronoi(ROOT_SIZE);
                  voronoi.addPoints(points);
                  updateTriangleCount();
                  break;
                }
              }
            }
          }
        }
        break;
    case 1:
      for (ColoredTriangle t : triangles) {
        if (t.containsPoint(mousePos)) {
          t.materialID=(t.materialID+1) % materialCols.length;
          break;
        }
      }
      break;
    }
  }
}

void keyPressed() {
  if (key==' ') {
    doScreenshot=true;
  }
  if (key=='-') {
    targetZoom=max(targetZoom-0.1,1);
  }
  if (key=='=') {
    targetZoom=min(targetZoom+0.1,4);
  }
  if (keyCode==LEFT) {
    origin.x+=10;
  }
  if (keyCode==RIGHT) {
    origin.x-=10;
  }
  if (keyCode==DOWN) {
    origin.y-=10;
  }
  if (keyCode==UP) {
    origin.y+=10;
  }
  if (key=='x') {
    saveHiRes2D();
  }
  if (key=='o') {
    saveAsOBJ();
  }
}

// switches into a new application state and performs
// any necessary initializations/computations
void setAppState(int state) {
  appState=state;
  println("new app state: "+state);
  switch(appState) {
  case 1:
    // recompute all triangles
    updateTriangles();
    break;
  case 2:
    // switch to 3D mode: build cone meshes for each triangle
    for (ColoredTriangle t : triangles) {
      t.buildMesh();
    }
    // reset camera rotation
    currRotation.clear();
    targetRotation.clear();
    break;
  case 3:
    // unwrap all triangle cones from 3D -> 2D
    for (ColoredTriangle t : triangles) {
      t.unwrap();
    }
  }
}

// returns the color of the pixel at the given point in the image
// since the image is centered at 0;0 we need to compute the coordinates
// in image space first
TColor getColorAtPoint(Vec2D p) {
  int x=(int)(p.x+img.width/2);
  int y=(int)(p.y+img.height/2);
  if (x>=0 && x<img.width && y>=0 && y<img.height) {
    return TColor.newARGB(img.get(x, y));
  }
  else {
    // return white if point is outside image
    return TColor.newGray(1);
  }
}

void addColorSamplesOnLine(Vec2D a, Vec2D b, ColorList colors) {
  for (Vec2D lp : new Line2D(a, b).splitIntoSegments(null,2,true)) {
    colors.add(getColorAtPoint(lp));
  }
}

void updateTriangles() {
  triangles.clear();
  for (Triangle2D t : voronoi.getTriangles()) {
    // ignore any triangles which share a vertex with the initial root triangle
    if (isValidTriangle(t)) {
      ColoredTriangle tri=new ColoredTriangle(t);
      triangles.add(tri);
    }
  }
  updateTriangleColors();
}

void updateTriangleColors() {
  for (ColoredTriangle t : triangles) {
    // get colors for corners
    t.colA=getColorAtPoint(t.a);
    t.colB=getColorAtPoint(t.b);
    t.colC=getColorAtPoint(t.c);
    // triangle centroid
    Vec2D centroid=t.computeCentroid();
    // sample colors along lines between centroid -> corners A,B,C
    ColorList colors=new ColorList();
    addColorSamplesOnLine(t.a, centroid, colors);
    addColorSamplesOnLine(t.b, centroid, colors);
    addColorSamplesOnLine(t.c, centroid, colors);
    // compute average color
    t.colAverage=colors.getAverage();
    t.colA.blend(t.colAverage, colorBlend);
    t.colB.blend(t.colAverage, colorBlend);
    t.colC.blend(t.colAverage, colorBlend);
  }
}
void updateTriangleCount() {
  numTriangles=0;
  for (Triangle2D t : voronoi.getTriangles()) {
    // ignore any triangles which share a vertex with the initial root triangle
    if (isValidTriangle(t)) {
      numTriangles++;
    }
  }
}

// checks if triangle is not one of the outliers sharing a vertex
// with the delaunay root triangle (which we want to ignore)
boolean isValidTriangle(Triangle2D t) {
  return abs(t.a.x)!=ROOT_SIZE && abs(t.a.y)!=ROOT_SIZE;
}

void chooseAndLoadImage() {
  String path=FileUtils.showFileDialog(
  frame, 
  "Choose an image...", 
  dataPath(""), 
  new String[] {
    ".png", ".jpg"
  }
  , 
  FileUtils.LOAD
    );
  if (path!=null) {
    img=loadImage(path);
  } 
  else {
    path=DEFAULT_IMAGE;
  }
  loadProjectImage(path);
}

void initVoronoi() {
  voronoi=new Voronoi(ROOT_SIZE);
  points.clear();
  triangles.clear();
}

void initMouseWheel() {
  frame.addMouseWheelListener(new MouseWheelListener() {
    public void mouseWheelMoved(MouseWheelEvent e) {
      targetZoom+=e.getWheelRotation()*0.05;
    }
  });
}
