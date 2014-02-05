/*
 * This class is part of the flatworld 3D unwrapping library:
 * http://hg.postspectacular.com/flatworld/
 *
 * Copyright (c) 2010-2011 Karsten Schmidt
 * 
 * This library is free software; you can redistribute it and/or
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
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 */
public class DXFWriter {

  protected StringBuilder buf;
  protected ToxiclibsSupport gfx;
  protected Vec2D origin = new Vec2D();

  public int circleRes = 4;

  public DXFWriter(ToxiclibsSupport gfx) {
    this.gfx = gfx;
  }

  public void circle(Vec2D o, float r, int colID, ReadonlyTColor col) {
    Vec2D prev = null;
    for (int i = 0; i <= circleRes; i++) {
      Vec2D p = new Vec2D(r, i * MathUtils.TWO_PI / circleRes).toCartesian().addSelf(o);
      if (prev != null) {
        line(prev, p, colID, col);
      }
      prev = p;
    }
  }

  public void endFrame() {
    buf.append("0\nENDSEC\n0\nEOF\n");
  }

  public void line(Line2D l, int colID, ReadonlyTColor col) {
    line(l.a, l.b, colID, col);
  }

  public void line(Vec2D a, Vec2D b, int colID, ReadonlyTColor col) {
    buf.append("0\nLINE\n8\n0\n62\n");
    buf.append(colID);
    buf.append("\n");
    buf.append("10\n");
    buf.append(a.x + origin.x);
    buf.append("\n20\n");
    buf.append(a.y + origin.y);
    buf.append("\n30\n0\n11\n");
    buf.append(b.x + origin.x);
    buf.append("\n21\n");
    buf.append(b.y + origin.y);
    buf.append("\n31\n0\n");
    gfx.stroke(col);
    gfx.line(a.add(origin), b.add(origin));
  }

  public void newFrame() {
    buf = new StringBuilder();
    buf.append("0\nSECTION\n2\nENTITIES\n");
    origin.clear();
  }

  public void polygon2D(Polygon2D p, int colID, ReadonlyTColor col) {
    for (int i = 0, num = p.vertices.size(); i < num; i++) {
      line(p.vertices.get(i), p.vertices.get((i + 1) % num), colID, col);
    }
  }

  public void save(String path) {
    println("saving dxf: " + path);
    BufferedWriter writer = null;
    try {
      writer = FileUtils.createWriter(new File(path));
      writer.write(buf.toString());
      writer.flush();
    } 
    catch (IOException e) {
      println(e.getMessage());
    } 
    finally {
      if (writer != null) {
        try {
        writer.close();
        } catch(IOException e) { 
        }
      }
    }
    println("export done");
  }

  public void translate(Vec2D offset) {
    this.origin.set(offset);
  }
}

