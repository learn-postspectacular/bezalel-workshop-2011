// adapted from flatworld library:

List<Triangle2D> unwrapCone(ColoredTriangle colTri) {
  // list of flattened triangles (the results of this function)
  List<Triangle2D> faces = new LinkedList<Triangle2D>();
  // list of points for bounding box calculation
  List<Vec2D> fpoints=new ArrayList<Vec2D>();
  Triangle2D prev = null;
  for (Face f : colTri.mesh.getFaces()) {
    // compute matrix to rotate triangle into 2D XY plane
    Matrix4x4 mat = Quaternion.getAlignmentQuat(Vec3D.Z_AXIS, f.normal).toMatrix4x4();
    // add translation vector so that triangle will be centred
    mat.translateSelf(f.getCentroid().getInverted());
    // scale to physical size
    mat.scaleSelf(PHYS_SCALE);
    // create 2D triangle from transformed 3D points
    Triangle2D t = new Triangle2D(
      mat.applyTo(f.a).to2DXY(),
      mat.applyTo(f.b).to2DXY(),
      mat.applyTo(f.c).to2DXY()
    );
    // align triangle to shared edge with previous
    if (prev != null) {
      float thetaPrevBC = prev.c.sub(prev.b).heading();
      float thetaBA = t.a.sub(t.b).heading();
      float delta = thetaPrevBC - thetaBA;
      t.a.rotate(delta);
      t.b.rotate(delta);
      t.c.rotate(delta);
      Vec2D offset = prev.b.sub(t.b);
      t.b.set(prev.b);
      t.a.addSelf(offset);
      t.c.addSelf(offset);
    }
    // add to list
    faces.add(t);
    prev = t;
    // add flattened points for bounding box calculation
    fpoints.add(t.a);
    fpoints.add(t.b);
    fpoints.add(t.c);
  }
  // compute 2D bounding rect of unwrapped mesh
  Rect bounds=Rect.getBoundingRect(fpoints);
  colTri.unwrappedBounds=bounds;
  // center all triangles as unit
  Vec2D centroid=bounds.getCentroid().invert();
  for (Triangle2D f : faces) {
    f.a.addSelf(centroid);
    f.b.addSelf(centroid);
    f.c.addSelf(centroid);
  }
  // update bounds
  bounds.x+=centroid.x;
  bounds.y+=centroid.y;
  if (max(bounds.width, bounds.height)>max(PHYS_SHEET_BOUNDS.width, PHYS_SHEET_BOUNDS.height) || bounds.getArea()>PHYS_SHEET_BOUNDS.getArea()) {
    println("***DANGER!***: "+bounds);
  } 
  return faces;
}

void drawUnrwapped() {
  dxf.newFrame();
  Vec2D offset=new Vec2D(10, 10);
  int idx=0;
  float maxHeight=0;
  for (int j=0; j<triangles.size(); j++) {
    ColoredTriangle t = triangles.get(j);
    dxf.translate(offset.add(t.unwrappedBounds.width/2, t.unwrappedBounds.height/2));
    for (int i=0; i<3; i++) {
      Triangle2D ft=t.unwrapped.get(i);
      if (i==0) {
        dxf.line(ft.a, ft.b, 0, TColor.BLACK);
      } 
      else {
        dxf.line(ft.a, ft.b, 1, TColor.RED);
      }
      dxf.line(ft.a, ft.c, 1, TColor.RED);
      // glue flap for mounting on surface
      float theta=ft.c.sub(ft.a).angleBetween(ft.b.sub(ft.a),true);
      float shrink=max(1-sin(theta),0.5);
      Line2D glueLine=new Line2D(ft.a.copy(), ft.c.copy());
      float len=glueLine.getLength();
      glueLine.offsetAndGrowBy(len*0.005+GLUE_FLAP, -len*shrink, ft.computeCentroid());
      if (glueLine.a.distanceTo(ft.a)>glueLine.a.distanceTo(ft.b)) {
        Vec2D swap=glueLine.a;
        glueLine.a=glueLine.b;
        glueLine.b=swap;
      }
      dxf.line(ft.a, glueLine.a, 0, TColor.BLACK);
      dxf.line(glueLine, 0, TColor.BLACK);
      dxf.line(glueLine.b, ft.c, 0, TColor.BLACK);
      if (i==2) {
        dxf.line(ft.b, ft.c, 1, TColor.RED);
        // glue flap
        Vec2D d=ft.b.interpolateTo(ft.c, 0.66666);
        // get perpendicular vector to edge and scale to length 10
        Vec2D n=ft.c.sub(ft.b).perpendicular().normalizeTo(GLUE_FLAP);
        // move to be relative to D
        n.addSelf(d);
        dxf.line(ft.c, n, 0, TColor.BLACK);
        dxf.line(ft.b, n, 0, TColor.BLACK);
      }
    }
    //dxf.polygon2D(t.unwrappedBounds.toPolygon2D(),2,TColor.GREEN);
    vfont.text(""+j, t.unwrappedBounds.getBottomLeft().add(0, 10), 0, TColor.BLACK);
    maxHeight=max(maxHeight, t.unwrappedBounds.height);
    idx++;
    if (idx<8) {
      offset.x+=t.unwrappedBounds.width+GAP;
    } 
    else {
      offset.x=0;
      offset.y+=maxHeight+GAP;
      maxHeight=0;
      idx=0;
    }
  }
  dxf.endFrame();
  if (doExport) {
    dxf.save(sketchPath("dxf-"+DateUtils.timeStamp()+".dxf"));
    doExport=false;
  }
}

