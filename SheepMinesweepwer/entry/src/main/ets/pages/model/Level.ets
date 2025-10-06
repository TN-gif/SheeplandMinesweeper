
export interface Level {
  levelId: string;
  name: string;
  rows: number;
  cols: number;
  mines: number;
  timeLimit?: number;
  isUnlocked: boolean;
}
