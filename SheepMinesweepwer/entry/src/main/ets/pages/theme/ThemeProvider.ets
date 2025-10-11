/**
 * 全局主题管理系统
 * 支持6个小羊角色主题的动态切换
 */

export interface ThemeColors {
  primary: string;        // 主色调
  secondary: string;      // 次要色
  accent: string;         // 强调色
  background: string;     // 背景色
  cardBg: string;        // 卡片背景
  textPrimary: string;   // 主要文本
  textSecondary: string; // 次要文本
}

export interface ThemeAssets {
  avatar: Resource;       // 角色头像
  mineIcon: Resource;     // 地雷图标（灰太狼）
  flagIcon: Resource;     // 旗帜图标（捕狼夹）
  grassIcon: Resource;    // 草地图标
  landIcon: Resource;     // 土地图标
  background: Resource;   // 背景图片
}

export interface ThemeAudio {
  bgm: string;           // 背景音乐
  clickSound: string;    // 点击音效
  flagSound: string;     // 插旗音效
  winSound: string;      // 胜利音效
  loseSound: string;     // 失败音效
}

export interface Theme {
  id: string;
  name: string;
  colors: ThemeColors;
  assets: ThemeAssets;
  audio: ThemeAudio;
}

// 全局色彩体系
class GlobalColors {
  asparagus: string = '#67AA53';      // 活力绿
  pacificCyan: string = '#41A9CE';    // 天空蓝
  yellowGreen: string = '#B9C556';    // 阳光黄
  lightBlue: string = '#B4D0D8';      // 浅青蓝
  brunswickGreen: string = '#2D5645'; // 森林绿
}

const GLOBAL_COLORS = new GlobalColors();

// 定义6个小羊主题
export const THEMES: Theme[] = [
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
      loseSound: 'music/Sound_Effects/羊叫声.mp3',
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
      loseSound: 'music/Sound_Effects/羊叫声.mp3',
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
      loseSound: 'music/Sound_Effects/羊叫声.mp3',
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
      loseSound: 'music/Sound_Effects/羊叫声.mp3',
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
      loseSound: 'music/Sound_Effects/羊叫声.mp3',
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
      loseSound: 'music/Sound_Effects/羊叫声.mp3',
    },
  },
];

@Observed
export class ThemeProvider {
  private static instance: ThemeProvider;
  currentTheme: Theme;

  private constructor() {
    this.currentTheme = THEMES[0]; // 默认喜羊羊主题
  }

  static getInstance(): ThemeProvider {
    if (!ThemeProvider.instance) {
      ThemeProvider.instance = new ThemeProvider();
    }
    return ThemeProvider.instance;
  }

  setTheme(themeId: string): void {
    const theme = THEMES.find(t => t.id === themeId);
    if (theme) {
      this.currentTheme = theme;
    }
  }

  getTheme(): Theme {
    return this.currentTheme;
  }

  getAllThemes(): Theme[] {
    return THEMES;
  }
}

// 导出单例
export const themeProvider = ThemeProvider.getInstance();
