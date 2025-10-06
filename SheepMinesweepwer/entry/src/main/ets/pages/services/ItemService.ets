import { Item } from '../model/Item';
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import { getContext } from '@ohos.abilityAccessCtrl';

const ITEM_PREFS_FILE = 'item_data';
const INVENTORY_KEY = 'player_inventory';

class ItemService {
  private inventory: Item[] = [
    { id: 'magnifying_glass', name: '慢羊羊的放大镜', description: '探测一个格子是否安全', quantity: 3 },
    { id: 'iron_fist', name: '沸羊羊的铁拳', description: '安全地砸开一个格子', quantity: 1 }
  ];
  private preferences: dataPreferences.Preferences | null = null;

  async init(): Promise<void> {
    try {
      const context = getContext(this);
      this.preferences = await dataPreferences.getPreferences(context, ITEM_PREFS_FILE);
      await this.loadInventory();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize ItemService: ${error.message}, code: ${error.code}`);
    }
  }

  private async loadInventory(): Promise<void> {
    if (!this.preferences) return;
    try {
      const savedInventoryJson = await this.preferences.get(INVENTORY_KEY, '[]') as string;
      const savedInventory: Item[] = JSON.parse(savedInventoryJson);

      if (savedInventory.length > 0) {
        this.inventory.forEach(item => {
          const savedItem = savedInventory.find(si => si.id === item.id);
          if (savedItem) {
            item.quantity = savedItem.quantity;
          }
        });
      }
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to load inventory: ${error.message}, code: ${error.code}`);
    }
  }

  private async saveInventory(): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(INVENTORY_KEY, JSON.stringify(this.inventory));
      await this.preferences.flush();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to save inventory: ${error.message}, code: ${error.code}`);
    }
  }

  public getInventory(): Item[] {
    return this.inventory;
  }

  public useItem(itemId: 'magnifying_glass' | 'iron_fist'): boolean {
    const item = this.inventory.find(i => i.id === itemId);
    if (item && item.quantity > 0) {
      item.quantity--;
      this.saveInventory();
      return true; // Item was used successfully
    }
    return false; // Not enough items
  }
}

export const itemService = new ItemService();
