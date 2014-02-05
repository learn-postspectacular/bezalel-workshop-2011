void saveHiRes2D() {
  Rect bounds=Rect.getBoundingRect(points);
  float scale=1;
  int w,h;
  if (bounds.width>bounds.height) {
    scale=HIRES_HEIGHT/bounds.width;
    w=HIRES_HEIGHT;
    h=HIRES_WIDTH;
  } else {
    scale=HIRES_HEIGHT/bounds.height;
    w=HIRES_WIDTH;
    h=HIRES_HEIGHT;
  }
  PGraphics gfx=createGraphics(w,h,P3D);
  gfx.beginDraw();
  gfx.background(255);
  gfx.translate(gfx.width/2,gfx.height/2);
  gfx.scale(scale);
  gfx.beginShape(TRIANGLES);
  for (ColoredTriangle t : triangles) {
    gfx.fill(t.colA.toARGB());
    gfx.vertex(t.a.x, t.a.y);
    gfx.fill(t.colB.toARGB());
    gfx.vertex(t.b.x, t.b.y);
    gfx.fill(t.colC.toARGB());
    gfx.vertex(t.c.x, t.c.y);
  }
  gfx.endShape();
  gfx.endDraw();
  String path=sketchPath(String.format("delaunay-%s-%dx%d.png",DateUtils.timeStamp(),w,h));
  println("saving hires: "+path);
  gfx.save(path);
  open(path);
}
