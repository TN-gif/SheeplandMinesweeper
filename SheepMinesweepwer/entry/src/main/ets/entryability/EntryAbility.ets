import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, font } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import { FontManager } from '../pages/utils/FontManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 将context保存到AppStorage供全局使用
    AppStorage.setOrCreate('context', this.context);
    
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      
      // 设置沉浸式状态栏
      try {
        windowStage.getMainWindow((err, windowClass) => {
          if (err && err.code) {
            hilog.error(DOMAIN, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
            return;
          }
          
          // 设置窗口全屏模式，状态栏内容延伸到状态栏区域（使用新API）
          try {
            windowClass.setWindowLayoutFullScreen(true);
            hilog.info(DOMAIN, 'testTag', '设置沉浸式状态栏成功');
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(DOMAIN, 'testTag', '设置全屏失败 code:%{public}d msg:%{public}s',
              err.code, err.message);
          }
          
          // 设置状态栏属性
          try {
            let systemBarProperties: window.SystemBarProperties = {
              statusBarColor: '#00000000',  // 透明状态栏
              statusBarContentColor: '#000000'  // 状态栏文字为黑色
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
      
      // 在 loadContent 回调中注册字体
      this.registerCustomFont().then(() => {
        hilog.info(DOMAIN, 'testTag', '字体注册流程完成');
      }).catch(() => {
        hilog.error(DOMAIN, 'testTag', '字体注册流程失败');
      });
      
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private async registerCustomFont(): Promise<void> {
    try {
      // 使用标准 API 注册字体
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