class ColoredTriangle extends Triangle2D {

  TColor colA;
  TColor colB;
  TColor colC;
  ReadonlyTColor colAverage;

  TriangleMesh mesh;

  List<Triangle2D> unwrapped;
  Rect unwrappedBounds;

  int materialID;

  ColoredTriangle(Triangle2D t) {
    super(t.a, t.b, t.c);
    if (!isClockwise()) {
      flipVertexOrder();
    }
  }

  void buildMesh() {
    mesh=new TriangleMesh();
    Vec3D d=computeCentroid().to3DXY();
    d.z=abs(getArea())*0.005+10;
    mesh.addFace(a.to3DXY(), d, b.to3DXY());
    mesh.addFace(b.to3DXY(), d, c.to3DXY());
    mesh.addFace(c.to3DXY(), d, a.to3DXY());
  }

  void unwrap() {
    if (mesh==null) {
      buildMesh();
    }
    unwrapped=unwrapCone(this);
  }
}

