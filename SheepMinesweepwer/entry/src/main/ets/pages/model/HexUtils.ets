// Using Axial Coordinates as the primary logical representation for hexagons
export class AxialCoord {
  q: number;
  r: number;

  constructor(q: number, r: number) {
    this.q = q;
    this.r = r;
  }
}

export class Point {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

class FractionalAxialCoord {
  q: number;
  r: number;

  constructor(q: number, r: number) {
    this.q = q;
    this.r = r;
  }
}

export class HexCell {
  q: number;
  r: number;
  isMine: boolean = false;
  isRevealed: boolean = false;
  isFlagged: boolean = false;
  adjacentMines: number = 0;

  constructor(q: number, r: number) {
    this.q = q;
    this.r = r;
  }
}

/**
 * A utility class for handling hexagonal grid mathematics.
 * Based on the excellent guides from Red Blob Games.
 */
export class HexUtils {
  // Directions in axial coordinates
  private static directions: AxialCoord[] = [
    new AxialCoord(1, 0),
    new AxialCoord(1, -1),
    new AxialCoord(0, -1),
    new AxialCoord(-1, 0),
    new AxialCoord(-1, 1),
    new AxialCoord(0, 1)
  ];

  static getNeighbor(hex: AxialCoord, direction: number): AxialCoord {
    const dir: AxialCoord = HexUtils.directions[direction];
    const neighbor: AxialCoord = new AxialCoord(hex.q + dir.q, hex.r + dir.r);
    return neighbor;
  }

  static getNeighbors(hex: AxialCoord): AxialCoord[] {
    const neighbors: AxialCoord[] = [];
    for (let i: number = 0; i < HexUtils.directions.length; i++) {
      neighbors.push(HexUtils.getNeighbor(hex, i));
    }
    return neighbors;
  }

  /**
   * Converts pixel coordinates (from a touch event) to axial coordinates.
   * This is the most critical function for interactivity.
   * @param x The x pixel coordinate.
   * @param y The y pixel coordinate.
   * @param size The radius of a hexagon in pixels.
   * @param origin The center pixel of the hex grid's origin (0,0).
   */
  static pixelToAxial(x: number, y: number, size: number, origin: Point): AxialCoord {
    const pt: Point = new Point((x - origin.x) / size, (y - origin.y) / size);
    const q: number = (Math.sqrt(3) / 3) * pt.x - (1 / 3) * pt.y;
    const r: number = (2 / 3) * pt.y;
    const frac: FractionalAxialCoord = new FractionalAxialCoord(q, r);
    return HexUtils.axialRound(frac);
  }

  /**
   * Converts axial coordinates to the center pixel of a hexagon.
   * @param hex The axial coordinate.
   * @param size The radius of a hexagon in pixels.
   * @param origin The center pixel of the hex grid's origin (0,0).
   */
  static axialToPixel(hex: AxialCoord, size: number, origin: Point): Point {
    const x: number = size * (Math.sqrt(3) * hex.q + (Math.sqrt(3) / 2) * hex.r);
    const y: number = size * ((3 / 2) * hex.r);
    const pixel: Point = new Point(x + origin.x, y + origin.y);
    return pixel;
  }

  // Helper function to round floating-point axial coordinates to the nearest integer hex coordinate.
  private static axialRound(frac: FractionalAxialCoord): AxialCoord {
    const q: number = Math.round(frac.q);
    const r: number = Math.round(frac.r);
    const s: number = Math.round(-frac.q - frac.r);

    const q_diff: number = Math.abs(q - frac.q);
    const r_diff: number = Math.abs(r - frac.r);
    const s_diff: number = Math.abs(s - (-frac.q - frac.r));

    let roundedQ: number = q;
    let roundedR: number = r;

    if (q_diff > r_diff && q_diff > s_diff) {
      roundedQ = -r - s;
    } else if (r_diff > s_diff) {
      roundedR = -q - s;
    }

    return new AxialCoord(roundedQ, roundedR);
  }
}
