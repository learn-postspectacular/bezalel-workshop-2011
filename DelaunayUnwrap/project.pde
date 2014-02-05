void loadProject() {
  String path=FileUtils.showFileDialog(
  frame, 
  "Load project...", 
  dataPath(""), 
  new String[] {
    FILE_EXT
  }, 
  FileUtils.LOAD);
  if (path!=null) {
    String[] data=loadStrings(path);
    String ipath=data[0];
    // check if file path is absolute
    // if not, add base path of project file
    if (ipath.indexOf("/")==-1) {
      ipath=new File(path).getParent()+"/"+ipath;
    }
    loadProjectImage(ipath);
    for (int i=1; i<data.length; i++) {
      if (data[i].length()>0) {
        float[] coords=float(split(data[i], ","));
        Vec2D p=new Vec2D(coords[0], coords[1]);
        voronoi.addPoint(p);
        points.add(p);
      }
    }
    updateTriangles();
    updateTriangleCount();
  }
  doLoadProject=false;
}

void saveProject() {
  String path=FileUtils.showFileDialog(
  frame, 
  "Save project...", 
  dataPath(""), 
  new String[] {
    FILE_EXT
  }, 
  FileUtils.SAVE);
  if (path!=null) {
    if (path.indexOf(FILE_EXT)==-1) {
      path+=FILE_EXT;
    }
    // copying image to same folder as project file
    // image will be renamed into project name as well
    byte[] rawImg=loadBytes(imgPath);
    String targetFolder=new File(path).getParent();
    String imgName=new File(path).getName();
    imgName=imgName.substring(0,imgName.lastIndexOf("."));
    imgName+=imgPath.substring(imgPath.lastIndexOf("."));
    imgPath=targetFolder+"/"+imgName;
    println("copying image to: "+imgPath);
    saveBytes(imgPath,rawImg);
    String[] data=new String[points.size()+1];
    data[0]=imgName;
    for (int i=0; i<points.size(); i++) {
      Vec2D p=points.get(i);
      data[i+1]=p.x+","+p.y;
    }
    println("saving project: "+path);
    saveStrings(path, data);
  }
  doSaveProject=false;
}

void loadProjectImage(String path) {
  println("loading image: "+path);
  imgPath=path;
  img=loadImage(path);
  // resize image to fit max width/height
  if (img.width>MAX_IMG_WIDTH) {
    float s=(float)MAX_IMG_WIDTH/img.width;
    PImage img2=new PImage(MAX_IMG_WIDTH, (int)(img.height*s));
    img2.copy(img, 0, 0, img.width, img.height, 0, 0, img2.width, img2.height);
    img=img2;
  }
  if (img.height>MAX_IMG_HEIGHT) {
    float s=(float)MAX_IMG_HEIGHT/img.height;
    PImage img2=new PImage((int)(img.width*s), MAX_IMG_HEIGHT);
    img2.copy(img, 0, 0, img.width, img.height, 0, 0, img2.width, img2.height);
    img=img2;
  }
  doLoadImage=false;
  initVoronoi();
  setAppState(0);
}

