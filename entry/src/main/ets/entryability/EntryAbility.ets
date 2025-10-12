/**
 * 应用入口能力类
 * 
 * 负责应用生命周期管理，包括：
 * - 全局Context初始化和共享
 * - 主题颜色模式配置
 * - 窗口沉浸式状态栏设置
 * - 自定义字体注册
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, font } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import { FontManager } from '../pages/utils/FontManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  /**
   * 应用创建时的生命周期回调
   * 
   * 在此阶段完成以下初始化工作：
   * - 将UIAbilityContext保存到AppStorage，使其在整个应用中可访问
   * - 配置颜色模式为系统默认，确保主题由应用内部控制
   * 
   * @param {Want} want - 启动应用的Intent信息
   * @param {AbilityConstant.LaunchParam} launchParam - 启动参数
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 将context保存到AppStorage供全局使用
    // 原因：Services和组件需要context来访问资源管理器和持久化存储
    AppStorage.setOrCreate('context', this.context);
    
    try {
      // 设置颜色模式为未设置状态，允许应用内部的ThemeProvider完全控制主题
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  /**
   * 应用销毁时的生命周期回调
   * 
   * 用于释放资源，清理全局状态
   */
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /**
   * 窗口舞台创建时的生命周期回调
   * 
   * 在此阶段完成以下工作：
   * - 加载主页面（Index）
   * - 配置沉浸式状态栏以提升视觉体验
   * - 注册自定义字体以支持品牌化UI
   * 
   * @param {window.WindowStage} windowStage - 窗口舞台对象，用于管理窗口
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      
      // 配置沉浸式状态栏
      // 原因：让应用内容延伸到状态栏区域，提供更好的视觉沉浸感
      try {
        windowStage.getMainWindow((err, windowClass) => {
          if (err && err.code) {
            hilog.error(DOMAIN, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
            return;
          }
          
          // 启用全屏布局模式，允许内容绘制到状态栏下方
          try {
            windowClass.setWindowLayoutFullScreen(true);
            hilog.info(DOMAIN, 'testTag', '设置沉浸式状态栏成功');
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(DOMAIN, 'testTag', '设置全屏失败 code:%{public}d msg:%{public}s',
              err.code, err.message);
          }
          
          // 设置透明状态栏背景，保持状态栏文字可见性
          try {
            let systemBarProperties: window.SystemBarProperties = {
              statusBarColor: '#00000000',  // 完全透明，让背景图显示
              statusBarContentColor: '#000000'  // 黑色文字以确保在浅色背景上可读
            };
            windowClass.setWindowSystemBarProperties(systemBarProperties);
            hilog.info(DOMAIN, 'testTag', '设置状态栏属性成功');
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(DOMAIN, 'testTag', '设置状态栏属性失败 code:%{public}d msg:%{public}s',
              err.code, err.message);
          }
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(DOMAIN, 'testTag', '设置沉浸式状态栏失败 code:%{public}d msg:%{public}s',
          err.code, err.message);
      }
      
      // 注册自定义字体以支持品牌化的UI设计
      // 原因：项目使用"木瑶软笔"字体营造温馨可爱的氛围
      this.registerCustomFont().then(() => {
        hilog.info(DOMAIN, 'testTag', '字体注册流程完成');
      }).catch(() => {
        hilog.error(DOMAIN, 'testTag', '字体注册流程失败');
      });
      
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  /**
   * 窗口舞台销毁时的生命周期回调
   * 
   * 用于释放UI相关资源
   */
  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  /**
   * 应用切换到前台时的生命周期回调
   * 
   * 可在此恢复音乐播放、刷新数据等
   */
  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  /**
   * 应用切换到后台时的生命周期回调
   * 
   * 可在此暂停音乐、保存状态等
   */
  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 注册自定义字体到系统
   * 
   * 使用木瑶软笔字体为应用提供独特的视觉风格。
   * 注册后，可在整个应用中通过fontFamily属性使用。
   * 
   * @returns {Promise<void>} 注册完成的Promise
   * 
   * @example
   * ```
   * Text('示例文字')
   *   .fontFamily(FontManager.getFontFamily())
   * ```
   */
  private async registerCustomFont(): Promise<void> {
    try {
      await font.registerFont({
        familyName: FontManager.CUSTOM_FONT_FAMILY,
        familySrc: $rawfile(FontManager.CUSTOM_FONT_PATH)
      });
      hilog.info(DOMAIN, 'testTag', '字体注册成功: %{public}s', FontManager.CUSTOM_FONT_FAMILY);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', '字体注册失败 code:%{public}d msg:%{public}s', 
        err.code, err.message);
    }
  }
}