export interface WinCondition {
  type: 'time' | 'noErrors';
  limit?: number; // Time in seconds
  value?: boolean; // For noErrors
}

export interface Level {
  levelId: string;
  levelName: string;
  shape?: boolean[][]; // For irregular boards
  mineLayout: { row: number, col: number }[];
  winConditions: WinCondition[];
  rows: number; // Add rows for grid creation
  cols: number; // Add cols for grid creation
}
