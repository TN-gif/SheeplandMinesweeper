/**
 * 字体管理工具类
 * 
 * 提供全局字体配置和访问方法。
 * 统一管理应用中使用的自定义字体和备用字体。
 * 
 * 使用说明：
 * 1. 自定义字体已在EntryAbility中注册
 * 2. 在Text组件中使用：.fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
 * 3. 如果自定义字体加载失败，会自动降级到备用字体
 */

export class FontManager {
  /**
   * 自定义字体族名称
   * 
   * 使用"木瑶软笔"字体营造温馨可爱的视觉风格。
   * 对应在EntryAbility中通过font.registerFont()注册的familyName。
   */
  static readonly CUSTOM_FONT_FAMILY: string = 'Muyao-Softbrush';

  /**
   * 自定义字体文件路径
   * 
   * 字体文件位于rawfile目录中的相对路径。
   */
  static readonly CUSTOM_FONT_PATH: string = 'fonts/Muyao-Softbrush.ttf';

  /**
   * 获取自定义字体族名称
   * 
   * 用于Text组件的.fontFamily()属性。
   * 
   * @returns {string} 字体族名称
   * 
   * @example
   * ```
   * Text('示例文字')
   *   .fontFamily(FontManager.getFontFamily())
   * ```
   */
  static getFontFamily(): string {
    return FontManager.CUSTOM_FONT_FAMILY;
  }

  /**
   * 获取备用字体族名称
   * 
   * 当自定义字体加载失败或不包含某些字符时，使用HarmonyOS系统字体作为降级方案。
   * 
   * @returns {string} 备用字体族名称
   * 
   * @example
   * ```
   * Text('示例文字')
   *   .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
   * ```
   */
  static getFallbackFont(): string {
    return 'HarmonyOS Sans';
  }
}
