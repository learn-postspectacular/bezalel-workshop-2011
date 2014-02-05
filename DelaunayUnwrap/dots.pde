void drawDotState() {
  stroke(0);
  noFill();
  stroke(0, 0, 255);
  translate(origin.x, origin.y);
  scale(currZoom);
  image(img, -img.width/2, -img.height/2);
  beginShape(TRIANGLES);
  // get the delaunay triangles
  for (Triangle2D t : voronoi.getTriangles()) {
    // ignore any triangles which share a vertex with the initial root triangle
    if (isValidTriangle(t)) {
      gfx.triangle(t, false);
    }
  }
  endShape();
  fill(255, 0, 255);
  noStroke();
  float s=5/currZoom;
  for (Vec2D c : voronoi.getSites()) {
    ellipse(c.x, c.y, s,s);
  }
}

