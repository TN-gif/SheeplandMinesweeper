/**
 * 字体工具类
 * 提供自定义字体的名称常量
 * 
 * 注意：字体需要在 EntryAbility.onWindowStageCreate 中注册后才能使用
 */

export class FontManager {
  /**
   * 自定义字体族名称
   * 对应在 EntryAbility 中注册的 familyName
   */
  static readonly CUSTOM_FONT_FAMILY: string = 'Muyao-Softbrush';

  /**
   * 自定义字体文件路径（在 rawfile 中）
   */
  static readonly CUSTOM_FONT_PATH: string = 'fonts/Muyao-Softbrush.ttf';

  /**
   * 获取自定义字体族名称
   * 用于 .fontFamily() 属性
   */
  static getFontFamily(): string {
    return FontManager.CUSTOM_FONT_FAMILY;
  }

  /**
   * 获取备用字体族名称
   */
  static getFallbackFont(): string {
    return 'HarmonyOS Sans';
  }
}
