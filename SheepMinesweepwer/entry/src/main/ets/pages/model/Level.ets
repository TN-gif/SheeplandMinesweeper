
export class Level {
  levelId: string;
  name: string;
  rows: number;
  cols: number;
  mines: number;
  timeLimit?: number;
  isUnlocked: boolean;

  constructor(
    levelId: string,
    name: string,
    rows: number,
    cols: number,
    mines: number,
    isUnlocked: boolean,
    timeLimit?: number
  ) {
    this.levelId = levelId;
    this.name = name;
    this.rows = rows;
    this.cols = cols;
    this.mines = mines;
    this.isUnlocked = isUnlocked;
    this.timeLimit = timeLimit;
  }
}
