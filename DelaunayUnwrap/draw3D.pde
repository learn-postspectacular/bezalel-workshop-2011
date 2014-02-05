void draw3D() {
  lights();
  translate(width/2, height/2, 0);
  if (mousePressed && mouseButton==RIGHT) {
    targetRotation.x=map(mouseY, 0, height, -PI, PI);
    targetRotation.y=map(mouseX, 0, width, -PI, PI);
  }
  currRotation.interpolateToSelf(targetRotation, 0.05);
  rotateX(currRotation.x);
  rotateY(currRotation.y);
  scale(currZoom);
  for (ColoredTriangle t : triangles) {
    if (useMaterial) {
      fill(materialCols[t.materialID].toARGB());
    } 
    else {
      fill(t.colAverage.toARGB());
    }
    gfx.mesh(t.mesh);
  }
}

void saveAsOBJ() {
  TriangleMesh mesh=new TriangleMesh();
  for(ColoredTriangle t : triangles) {
    mesh.addMesh(t.mesh);
  }
  mesh.saveAsOBJ(sketchPath("test.obj"));
}
