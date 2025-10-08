/**
 * 设置界面
 * 允许用户调整音效、震动等设置
 */
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';
import { audioManager } from '../services/AudioManager';
import { HapticFeedbackUtils } from '../utils/HapticFeedbackUtils';

@Component
export struct SettingsScreen {
  @ObjectLink provider: ThemeProvider;
  @State bgmEnabled: boolean = true;
  @State soundEnabled: boolean = true;
  @State hapticEnabled: boolean = true;
  @State bgmVolume: number = 0.5;
  @State soundVolume: number = 0.7;
  onBack: () => void = () => {};

  aboutToAppear(): void {
    // 从AudioManager获取当前设置
    this.bgmEnabled = true; // 默认值，实际应该从存储中读取
    this.soundEnabled = true;
    this.hapticEnabled = true;
    this.bgmVolume = 0.5;
    this.soundVolume = 0.7;
  }

  private async playBGMSafely(): Promise<void> {
    try {
      await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
    } catch (error) {
      console.error('Failed to play BGM:', error);
    }
  }

  build() {
    Column() {
      // 标题
      Text('⚙️ 游戏设置 ⚙️')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .margin({ top: 40, bottom: 30 })
        .textShadow({ radius: 3, color: '#00000030', offsetX: 2, offsetY: 2 });

      // 设置选项列表
      Column({ space: 20 }) {
        // 背景音乐设置
        this.SettingCard('🎵 背景音乐', () => {
          this.bgmEnabled = !this.bgmEnabled;
          audioManager.setBGMEnabled(this.bgmEnabled);
          if (this.bgmEnabled) {
            this.playBGMSafely();
          }
        }, this.bgmEnabled);

        // 音效设置
        this.SettingCard('🔊 游戏音效', () => {
          this.soundEnabled = !this.soundEnabled;
          audioManager.setSoundEnabled(this.soundEnabled);
        }, this.soundEnabled);

        // 触觉反馈设置
        this.SettingCard('📳 震动反馈', () => {
          this.hapticEnabled = !this.hapticEnabled;
          HapticFeedbackUtils.setEnabled(this.hapticEnabled);
          if (this.hapticEnabled) {
            HapticFeedbackUtils.vibrate('light');
          }
        }, this.hapticEnabled);

        // 音量滑块
        this.VolumeSlider('🎵 背景音乐音量', this.bgmVolume, (value: number) => {
          this.bgmVolume = value;
          audioManager.setBGMVolume(value);
        });

        this.VolumeSlider('🔊 音效音量', this.soundVolume, (value: number) => {
          this.soundVolume = value;
          audioManager.setSoundVolume(value);
        });
      }
      .width('90%')
      .padding({ bottom: 40 });

      // 返回按钮
      Button('返回菜单')
        .width('85%')
        .height(55)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#FF9800')
        .borderRadius(15)
        .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
        .margin({ top: 20, bottom: 30 })
        .onClick(this.onBack);
    }
    .width('100%')
    .height('100%')
    .backgroundImage(this.provider.currentTheme.assets.background)
    .backgroundImageSize(ImageSize.Cover);
  }

  @Builder
  SettingCard(title: string, onToggle: () => void, isEnabled: boolean) {
    Row() {
      Text(title)
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .layoutWeight(1);

      // 开关按钮
      Button(isEnabled ? '开启' : '关闭')
        .width(80)
        .height(40)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(isEnabled ? 
          this.provider.currentTheme.colors.primary : 
          '#D0D0D0')
        .fontColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => {
          onToggle();
        });
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.provider.currentTheme.colors.cardBg)
    .borderRadius(15)
    .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 });
  }

  @Builder
  VolumeSlider(title: string, value: number, onValueChange: (value: number) => void) {
    Column({ space: 10 }) {
      Row() {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.provider.currentTheme.colors.textPrimary);
        
        Blank();
        
        Text(`${Math.round(value * 100)}%`)
          .fontSize(16)
          .fontColor(this.provider.currentTheme.colors.textSecondary);
      }
      .width('100%');

      Slider({
        value: value * 100,
        min: 0,
        max: 100,
        step: 10,
        style: SliderStyle.OutSet
      })
        .trackColor('#E0E0E0')
        .selectedColor(this.provider.currentTheme.colors.primary)
        .blockColor(this.provider.currentTheme.colors.primary)
        .width('100%')
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode === SliderChangeMode.End || mode === SliderChangeMode.Moving) {
            onValueChange(value / 100);
          }
        });
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.provider.currentTheme.colors.cardBg)
    .borderRadius(15)
    .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 });
  }
}
