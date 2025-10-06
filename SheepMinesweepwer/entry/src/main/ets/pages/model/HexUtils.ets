// Using Axial Coordinates as the primary logical representation for hexagons
export interface AxialCoord {
  q: number;
  r: number;
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
    { q: 1, r: 0 }, { q: 1, r: -1 }, { q: 0, r: -1 },
    { q: -1, r: 0 }, { q: -1, r: 1 }, { q: 0, r: 1 }
  ];

  static getNeighbor(hex: AxialCoord, direction: number): AxialCoord {
    const dir = HexUtils.directions[direction];
    return { q: hex.q + dir.q, r: hex.r + dir.r };
  }

  static getNeighbors(hex: AxialCoord): AxialCoord[] {
    return HexUtils.directions.map((dir, i) => HexUtils.getNeighbor(hex, i));
  }

  /**
   * Converts pixel coordinates (from a touch event) to axial coordinates.
   * This is the most critical function for interactivity.
   * @param x The x pixel coordinate.
   * @param y The y pixel coordinate.
   * @param size The radius of a hexagon in pixels.
   * @param origin The center pixel of the hex grid's origin (0,0).
   */
  static pixelToAxial(x: number, y: number, size: number, origin: { x: number, y: number }): AxialCoord {
    const pt = { x: (x - origin.x) / size, y: (y - origin.y) / size };
    const q = (Math.sqrt(3) / 3) * pt.x - (1 / 3) * pt.y;
    const r = (2 / 3) * pt.y;

    return this.axialRound({ q, r });
  }

  /**
   * Converts axial coordinates to the center pixel of a hexagon.
   * @param hex The axial coordinate.
   * @param size The radius of a hexagon in pixels.
   * @param origin The center pixel of the hex grid's origin (0,0).
   */
  static axialToPixel(hex: AxialCoord, size: number, origin: { x: number, y: number }): { x: number, y: number } {
    const x = size * (Math.sqrt(3) * hex.q + (Math.sqrt(3) / 2) * hex.r);
    const y = size * ((3 / 2) * hex.r);
    return { x: x + origin.x, y: y + origin.y };
  }

  // Helper function to round floating-point axial coordinates to the nearest integer hex coordinate.
  private static axialRound(frac: AxialCoord): AxialCoord {
    const q = Math.round(frac.q);
    const r = Math.round(frac.r);
    const s = Math.round(-frac.q - frac.r);

    const q_diff = Math.abs(q - frac.q);
    const r_diff = Math.abs(r - frac.r);
    const s_diff = Math.abs(s - (-frac.q - frac.r));

    if (q_diff > r_diff && q_diff > s_diff) {
      return { q: -r - s, r };
    } else if (r_diff > s_diff) {
      return { q, r: -q - s };
    } else {
      return { q, r };
    }
  }
}
