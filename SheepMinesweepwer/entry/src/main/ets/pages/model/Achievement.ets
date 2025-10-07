export class Achievement {
  id: string;
  name: string;
  description: string;
  unlocked: boolean;

  constructor(id: string, name: string, description: string, unlocked: boolean = false) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.unlocked = unlocked;
  }
}
