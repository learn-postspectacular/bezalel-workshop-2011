// draws the delaunay triangles in 2D using their underlying color or material
void drawTriangleState() {
  // move origin & scale
  translate(origin.x, origin.y);
  scale(currZoom);
  if (showTriangleIDs || useMaterial) {
    stroke(255);
  } 
  else {
    noStroke();
  }
  beginShape(TRIANGLES);
  for (ColoredTriangle t : triangles) {
    if (useMaterial) {
      fill(materialCols[t.materialID].toARGB());
      gfx.triangle(t);
    } 
    else {
      fill(t.colA.toARGB());
      vertex(t.a.x, t.a.y);
      fill(t.colB.toARGB());
      vertex(t.b.x, t.b.y);
      fill(t.colC.toARGB());
      vertex(t.c.x, t.c.y);
    }
  }
  endShape();
  // draw triangle IDs in center of each shape
  if (showTriangleIDs) {
    fill(255);
    int i=0;
    for (ColoredTriangle t : triangles) {
      text(i, t.computeCentroid().x, t.computeCentroid().y);
      i++;
    }
  }
}

