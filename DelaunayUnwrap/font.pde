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
public class VectorFont {

  HashMap<Character, float[][]> chars = new HashMap<Character, float[][]>();

  float size;
  float spacing = 0.1f;

  DXFWriter dxf;

  public boolean isCentered = true;

  public VectorFont(DXFWriter dxf, int size) {
    this.dxf = dxf;
    this.size = size;
    createMap();
  }

  private void createMap() {
    chars.put('0', new float[][] { 
      { 
        1, 0
      }
      , { 
        0, 0
      }
      , { 
        0, 1
      }
      , { 
        1, 1
      }
      , 
      { 
        1, 0
      }
      , { 
        0, 1
      }
    }
    );
    chars.put('1', new float[][] { 
      { 
        0, 0.25f
      }
      , { 
        0.5f, 0
      }
      , { 
        0.5f, 1
      }
    }
    );
    chars.put('2', new float[][] { 
      { 
        0, 0
      }
      , { 
        1, 0
      }
      , { 
        1, 0.25f
      }
      , 
      { 
        0, 1
      }
      , { 
        1, 1
      }
    }
    );
    chars.put('3', new float[][] { 
      { 
        0, 0
      }
      , { 
        1, 0
      }
      , { 
        0.25f, 0.5f
      }
      , 
      { 
        1, 0.5f
      }
      , { 
        1, 1
      }
      , { 
        0, 1
      }
    }
    );
    chars.put('4', new float[][] { 
      { 
        0.75f, 1
      }
      , { 
        0.75f, 0
      }
      , { 
        0, 0.5f
      }
      , 
      { 
        1, 0.5f
      }
    }
    );
    chars.put('5', new float[][] { 
      { 
        1, 0
      }
      , { 
        0, 0
      }
      , { 
        0, 0.5f
      }
      , 
      { 
        1, 0.5f
      }
      , { 
        1, 1
      }
      , { 
        0, 1
      }
    }
    );
    chars.put('6', new float[][] { 
      { 
        1, 0
      }
      , { 
        0, 0.5f
      }
      , { 
        0, 1
      }
      , 
      { 
        1, 1
      }
      , { 
        1, 0.5f
      }
      , { 
        0, 0.5f
      }
    }
    );
    chars.put('7', new float[][] { 
      { 
        0, 0
      }
      , { 
        1, 0
      }
      , { 
        0, 1
      }
    }
    );
    chars.put('8', new float[][] { 
      { 
        0, 0
      }
      , { 
        1, 1
      }
      , { 
        0, 1
      }
      , { 
        1, 0
      }
      , 
      { 
        0, 0
      }
    }
    );
    chars.put('9', new float[][] { 
      { 
        0, 1
      }
      , { 
        1, 0.5f
      }
      , { 
        1, 0
      }
      , 
      { 
        0, 0
      }
      , { 
        0, 0.5f
      }
      , { 
        1, 0.5f
      }
    }
    );
    chars.put('.', new float[][] { 
      { 
        0.4f, 1
      }
      , { 
        0.6f, 1
      }
      , 
      { 
        0.6f, 0.8f
      }
      , { 
        0.4f, 0.8f
      }
      , { 
        0.4f, 1
      }
    }
    );
  }

  public void text(String txt, Vec2D pos, int colID, ReadonlyTColor col) {
    if (isCentered) {
      pos.x -= txt.length() * size / 2;
    }
    for (int i = 0, len = txt.length(); i < len; i++) {
      float[][] path = chars.get(txt.charAt(i));
      if (path != null) {
        for (int j = 1; j < path.length; j++) {
          Vec2D a = new Vec2D(path[j - 1][0], path[j - 1][1])
            .scaleSelf(size).addSelf(pos);
          Vec2D b = new Vec2D(path[j][0], path[j][1]).scaleSelf(size)
            .addSelf(pos);
          dxf.line(a, b, colID, col);
        }
        pos.x += size * (1 + spacing);
      }
    }
  }
}

