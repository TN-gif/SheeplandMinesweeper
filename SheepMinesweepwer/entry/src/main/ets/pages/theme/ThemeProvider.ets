/**
 * 全局主题管理系统
 * 
 * 提供基于6个小羊角色的多主题系统，支持动态切换。
 * 每个主题包含独立的配色方案、视觉资源和音频资源。
 * 
 * 设计要点：
 * - 使用单例模式确保全局统一的主题状态
 * - 主题数据结构化，便于扩展新角色主题
 * - 支持响应式UI更新（@Observed装饰器）
 * - 全局色彩常量复用，保持视觉一致性
 */

/**
 * 主题配色接口
 * 
 * 定义一个主题的所有颜色值。
 */
export interface ThemeColors {
  /** 主色调，用于按钮、重要元素 */
  primary: string;
  
  /** 次要色，用于辅助元素 */
  secondary: string;
  
  /** 强调色，用于高亮和点缀 */
  accent: string;
  
  /** 背景色 */
  background: string;
  
  /** 卡片背景色 */
  cardBg: string;
  
  /** 主要文本颜色 */
  textPrimary: string;
  
  /** 次要文本颜色（提示、说明文字） */
  textSecondary: string;
}

/**
 * 主题视觉资源接口
 * 
 * 定义一个主题的所有图片资源。
 */
export interface ThemeAssets {
  /** 角色头像 */
  avatar: Resource;
  
  /** 地雷图标（灰太狼头像） */
  mineIcon: Resource;
  
  /** 旗帜图标（捕兽夹） */
  flagIcon: Resource;
  
  /** 草地图标 */
  grassIcon: Resource;
  
  /** 土地图标 */
  landIcon: Resource;
  
  /** 主题专属背景图片 */
  background: Resource;
}

/**
 * 主题音频资源接口
 * 
 * 定义一个主题的所有音频资源路径。
 * 注意：路径相对于rawfile目录。
 */
export interface ThemeAudio {
  /** 背景音乐文件路径 */
  bgm: string;
  
  /** 点击音效路径 */
  clickSound: string;
  
  /** 插旗音效路径 */
  flagSound: string;
  
  /** 胜利音效路径 */
  winSound: string;
  
  /** 失败音效路径 */
  loseSound: string;
}

/**
 * 主题完整定义接口
 * 
 * 整合颜色、视觉资源和音频资源。
 */
export interface Theme {
  /** 主题唯一标识 */
  id: string;
  
  /** 主题显示名称（角色名） */
  name: string;
  
  /** 主题配色方案 */
  colors: ThemeColors;
  
  /** 主题视觉资源 */
  assets: ThemeAssets;
  
  /** 主题音频资源 */
  audio: ThemeAudio;
}

/**
 * 全局色彩常量类
 * 
 * 定义在多个主题间复用的标准颜色值，确保视觉一致性。
 */
class GlobalColors {
  /** 活力绿 - 用于强调元素 */
  asparagus: string = '#67AA53';
  
  /** 天空蓝 - 用于次要元素 */
  pacificCyan: string = '#41A9CE';
  
  /** 阳光黄 - 用于点缀 */
  yellowGreen: string = '#B9C556';
  
  /** 浅青蓝 - 用于卡片背景 */
  lightBlue: string = '#B4D0D8';
  
  /** 森林绿 - 用于主要文本 */
  brunswickGreen: string = '#2D5645';
}

const GLOBAL_COLORS = new GlobalColors();

/**
 * 所有可用主题的配置数组
 * 
 * 包含6个小羊角色的完整主题配置。
 * 每个主题都有独特的配色、头像和背景图。
 */
export const THEMES: Theme[] = [
  // 喜羊羊主题：蓝色调，代表聪明勇敢
  {
    id: 'xiyangyang',
    name: '喜羊羊',
    colors: {
      primary: '#193B85',
      secondary: GLOBAL_COLORS.pacificCyan,
      accent: GLOBAL_COLORS.yellowGreen,
      background: '#E8F8F0',
      cardBg: GLOBAL_COLORS.lightBlue,
      textPrimary: GLOBAL_COLORS.brunswickGreen,
      textSecondary: '#5A7D6E',
    },
    assets: {
      avatar: $rawfile('images/avatar/喜羊羊.jpg'),
      mineIcon: $rawfile('images/icon/灰太狼.jpg'),
      flagIcon: $rawfile('images/icon/捕兽夹.png'),
      grassIcon: $rawfile('images/icon/草地.png'),
      landIcon: $rawfile('images/icon/土地.png'),
      background: $rawfile('images/background/喜羊羊.jpg'),
    },
    audio: {
      bgm: 'music/Background/主页面背景音乐.mp3',
      clickSound: 'music/Sound_Effects/羊叫声.mp3',
      flagSound: 'music/Sound_Effects/插旗声.mp3',
      winSound: 'music/Sound_Effects/欢呼声.mp3',
      loseSound: 'music/Sound_Effects/游戏失败.mp3',
    },
  },
  {
    id: 'meiyangyang',
    name: '美羊羊',
    colors: {
      primary: '#9E2550',
      secondary: '#FFB6D9',
      accent: GLOBAL_COLORS.yellowGreen,
      background: '#FFF0F7',
      cardBg: '#FFE6F2',
      textPrimary: GLOBAL_COLORS.brunswickGreen,
      textSecondary: '#8B5A7D',
    },
    assets: {
      avatar: $rawfile('images/avatar/美羊羊.jpg'),
      mineIcon: $rawfile('images/icon/灰太狼.jpg'),
      flagIcon: $rawfile('images/icon/捕兽夹.png'),
      grassIcon: $rawfile('images/icon/草地.png'),
      landIcon: $rawfile('images/icon/土地.png'),
      background: $rawfile('images/background/美羊羊.jpg'),
    },
    audio: {
      bgm: 'music/Background/主页面背景音乐.mp3',
      clickSound: 'music/Sound_Effects/羊叫声.mp3',
      flagSound: 'music/Sound_Effects/插旗声.mp3',
      winSound: 'music/Sound_Effects/欢呼声.mp3',
      loseSound: 'music/Sound_Effects/游戏失败.mp3',
    },
  },
  {
    id: 'lanyangyang',
    name: '懒羊羊',
    colors: {
      primary: '#925713',
      secondary: '#FFD699',
      accent: GLOBAL_COLORS.yellowGreen,
      background: '#FFF8E6',
      cardBg: '#FFEFC2',
      textPrimary: GLOBAL_COLORS.brunswickGreen,
      textSecondary: '#7D6A4D',
    },
    assets: {
      avatar: $rawfile('images/avatar/懒羊羊.jpg'),
      mineIcon: $rawfile('images/icon/灰太狼.jpg'),
      flagIcon: $rawfile('images/icon/捕兽夹.png'),
      grassIcon: $rawfile('images/icon/草地.png'),
      landIcon: $rawfile('images/icon/土地.png'),
      background: $rawfile('images/background/懒羊羊.jpg'),
    },
    audio: {
      bgm: 'music/Background/主页面背景音乐.mp3',
      clickSound: 'music/Sound_Effects/羊叫声.mp3',
      flagSound: 'music/Sound_Effects/插旗声.mp3',
      winSound: 'music/Sound_Effects/欢呼声.mp3',
      loseSound: 'music/Sound_Effects/游戏失败.mp3',
    },
  },
  {
    id: 'feiyangyang',
    name: '沸羊羊',
    colors: {
      primary: '#944A1B',
      secondary: '#CD950C',
      accent: GLOBAL_COLORS.yellowGreen,
      background: '#F5F0E6',
      cardBg: '#E8DCC2',
      textPrimary: GLOBAL_COLORS.brunswickGreen,
      textSecondary: '#5A4D3D',
    },
    assets: {
      avatar: $rawfile('images/avatar/沸羊羊.jpg'),
      mineIcon: $rawfile('images/icon/灰太狼.jpg'),
      flagIcon: $rawfile('images/icon/捕兽夹.png'),
      grassIcon: $rawfile('images/icon/草地.png'),
      landIcon: $rawfile('images/icon/土地.png'),
      background: $rawfile('images/background/沸羊羊.jpg'),
    },
    audio: {
      bgm: 'music/Background/主页面背景音乐.mp3',
      clickSound: 'music/Sound_Effects/羊叫声.mp3',
      flagSound: 'music/Sound_Effects/插旗声.mp3',
      winSound: 'music/Sound_Effects/欢呼声.mp3',
      loseSound: 'music/Sound_Effects/游戏失败.mp3',
    },
  },
  {
    id: 'nuanyangyang',
    name: '暖羊羊',
    colors: {
      primary: '#9E2574',
      secondary: '#FF9EC5',
      accent: GLOBAL_COLORS.yellowGreen,
      background: '#FFF0F5',
      cardBg: '#FFE0EC',
      textPrimary: GLOBAL_COLORS.brunswickGreen,
      textSecondary: '#8B4D6A',
    },
    assets: {
      avatar: $rawfile('images/avatar/暖羊羊.jpg'),
      mineIcon: $rawfile('images/icon/灰太狼.jpg'),
      flagIcon: $rawfile('images/icon/捕兽夹.png'),
      grassIcon: $rawfile('images/icon/草地.png'),
      landIcon: $rawfile('images/icon/土地.png'),
      background: $rawfile('images/background/暖羊羊.jpg'),
    },
    audio: {
      bgm: 'music/Background/主页面背景音乐.mp3',
      clickSound: 'music/Sound_Effects/羊叫声.mp3',
      flagSound: 'music/Sound_Effects/插旗声.mp3',
      winSound: 'music/Sound_Effects/欢呼声.mp3',
      loseSound: 'music/Sound_Effects/游戏失败.mp3',
    },
  },
  {
    id: 'manyangyang',
    name: '慢羊羊',
    colors: {
      primary: '#B77448',
      secondary: '#A8D8B9',
      accent: GLOBAL_COLORS.yellowGreen,
      background: '#F0F8F0',
      cardBg: '#E0F2E9',
      textPrimary: GLOBAL_COLORS.brunswickGreen,
      textSecondary: '#5A6D5E',
    },
    assets: {
      avatar: $rawfile('images/avatar/慢羊羊.jpg'),
      mineIcon: $rawfile('images/icon/灰太狼.jpg'),
      flagIcon: $rawfile('images/icon/捕兽夹.png'),
      grassIcon: $rawfile('images/icon/草地.png'),
      landIcon: $rawfile('images/icon/土地.png'),
      background: $rawfile('images/background/慢羊羊.jpg'),
    },
    audio: {
      bgm: 'music/Background/主页面背景音乐.mp3',
      clickSound: 'music/Sound_Effects/羊叫声.mp3',
      flagSound: 'music/Sound_Effects/插旗声.mp3',
      winSound: 'music/Sound_Effects/欢呼声.mp3',
      loseSound: 'music/Sound_Effects/游戏失败.mp3',
    },
  },
];

/**
 * 主题管理器（单例模式）
 * 
 * 全局管理当前激活的主题，支持动态切换。
 * 使用@Observed装饰器确保主题变化时自动触发UI更新。
 * 
 * 使用方法：
 * ```
 * // 获取实例
 * const provider = ThemeProvider.getInstance();
 * 
 * // 切换主题
 * provider.setTheme('meiyangyang');
 * 
 * // 在组件中使用主题颜色
 * Text('示例')
 *   .fontColor(provider.currentTheme.colors.primary)
 * ```
 */
@Observed
export class ThemeProvider {
  private static instance: ThemeProvider;
  
  /** 当前激活的主题 */
  currentTheme: Theme;

  private constructor() {
    // 默认使用喜羊羊主题
    this.currentTheme = THEMES[0];
  }

  /**
   * 获取ThemeProvider的单例实例
   * 
   * @returns {ThemeProvider} 主题管理器实例
   */
  static getInstance(): ThemeProvider {
    if (!ThemeProvider.instance) {
      ThemeProvider.instance = new ThemeProvider();
    }
    return ThemeProvider.instance;
  }

  /**
   * 切换到指定主题
   * 
   * 通过主题ID查找并激活对应的主题配置。
   * 切换会触发UI自动更新（因为使用了@Observed）。
   * 
   * @param {string} themeId - 主题ID（如'xiyangyang'）
   */
  setTheme(themeId: string): void {
    const theme = THEMES.find(t => t.id === themeId);
    if (theme) {
      this.currentTheme = theme;
    }
  }

  /**
   * 获取当前主题配置
   * 
   * @returns {Theme} 当前激活的主题
   */
  getTheme(): Theme {
    return this.currentTheme;
  }

  /**
   * 获取所有可用主题
   * 
   * @returns {Theme[]} 主题配置数组
   */
  getAllThemes(): Theme[] {
    return THEMES;
  }
}

/**
 * 导出主题管理器单例
 * 
 * 在应用中直接导入使用：
 * import { themeProvider } from './theme/ThemeProvider';
 */
export const themeProvider = ThemeProvider.getInstance();
