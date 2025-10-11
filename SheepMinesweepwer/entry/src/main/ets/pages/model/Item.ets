export class Item {
  id: 'magnifying_glass';
  name: string;
  description: string;
  quantity: number;

  constructor(id: 'magnifying_glass', name: string, description: string, quantity: number) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.quantity = quantity;
  }
}
